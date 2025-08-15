# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'dotenv/load'
require 'fast_mcp'
require 'faraday'
 $LOAD_PATH.unshift(File.join(__dir__, 'lib')) unless $LOAD_PATH.include?(File.join(__dir__, 'lib'))
require_relative 'lib/db'
require_relative 'lib/models'

set :bind, ENV.fetch('BIND', '0.0.0.0')
set :port, ENV.fetch('PORT', 5678)

get '/health' do
  content_type :json
  {
    status: 'ok',
    service: 'hivemind-mcp',
    db_status: HivemindMCP::DB.connected? ? 'connected' : 'disconnected'
   }.to_json
end

# Configure and mount FastMcp Rack transport to expose MCP over HTTP/SSE

# Eager-load all tools and resources from dedicated directories
Dir[File.join(__dir__, 'tools', '**/*.rb')].sort.each { |f| require f }
Dir[File.join(__dir__, 'resources', '**/*.rb')].sort.each { |f| require f }

# Build MCP server and register discovered tools/resources
MCP_SERVER = FastMcp::Server.new(name: 'hivemind-mcp', version: '0.1.0')
HivemindMCP::DB.establish_connection!
if defined?(HivemindMCP)
  mod = HivemindMCP
  constants = mod.constants(false)
  tool_classes = []
  resource_classes = []
  constants.each do |const_name|
    klass = mod.const_get(const_name)
    next unless klass.is_a?(Class)
    if klass < FastMcp::Tool
      tool_classes << klass
    elsif klass < FastMcp::Resource
      resource_classes << klass
    end
  end
  puts "Registering Tools: #{tool_classes.map(&:name).join(', ')}"
  MCP_SERVER.register_tools(*tool_classes) if tool_classes.any?
  puts "Registering Resources: #{resource_classes.map(&:name).join(', ')}"
  MCP_SERVER.register_resources(*resource_classes) if resource_classes.any?
end

# Mount Rack transport for MCP endpoints
use FastMcp::Transports::RackTransport, MCP_SERVER, sse_path: '/mcp/sse', messages_path: '/mcp/messages'
