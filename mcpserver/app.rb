# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'dotenv/load'
require 'fast_mcp'
require 'faraday'
 $LOAD_PATH.unshift(File.join(__dir__, 'lib')) unless $LOAD_PATH.include?(File.join(__dir__, 'lib'))
require_relative 'lib/request_context'

set :bind, ENV.fetch('BIND', '0.0.0.0')
set :port, ENV.fetch('PORT', 5678)

# Add middleware to extract auth headers from requests
use HivemindMCP::AuthHeaderMiddleware

get '/health' do
  content_type :json
  {
    status: 'ok',
    service: 'hivemind-mcp'
  }.to_json
end

# Configure and mount FastMcp Rack transport to expose MCP over HTTP/SSE

# Eager-load all tools and resources from dedicated directories
Dir[File.join(__dir__, 'tools', '**/*.rb')].sort.each { |f| require f }
Dir[File.join(__dir__, 'resources', '**/*.rb')].sort.each { |f| require f }

# Build MCP server and register discovered tools/resources
MCP_SERVER = FastMcp::Server.new(name: 'hivemind-mcp', version: '0.1.0')
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
# By default, FastMcp RackTransport blocks non-localhost and unknown origins to prevent DNS rebinding.
# Relax this for development/testing or when calling from other hosts (e.g., n8n) via env overrides.
allowed_origins = if ENV['MCP_ALLOWED_ORIGINS']
  ENV['MCP_ALLOWED_ORIGINS'].split(',').map(&:strip)
else
  [] # empty array disables origin checks
end

localhost_only = ENV.key?('MCP_LOCALHOST_ONLY') ? ENV['MCP_LOCALHOST_ONLY'].to_s == 'true' : false

use FastMcp::Transports::RackTransport, MCP_SERVER,
    # keep defaults: path_prefix '/mcp', routes 'sse' and 'messages'
    allowed_origins: allowed_origins,
    localhost_only: localhost_only

# Catch-all OPTIONS handler to surface noisy preflight callers and allow CORS
options '*' do
  origin   = request.env['HTTP_ORIGIN']
  referer  = request.env['HTTP_REFERER']
  ua       = request.env['HTTP_USER_AGENT']
  acrh     = request.env['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']
  acm      = request.env['HTTP_ACCESS_CONTROL_REQUEST_METHOD']
  path     = request.path_info
  puts "[CORS-OPTIONS] path=#{path} origin=#{origin.inspect} referer=#{referer.inspect} ua=#{ua.inspect} acrh=#{acrh.inspect} acm=#{acm.inspect}"

  headers 'Access-Control-Allow-Origin' => (origin || '*'),
          'Vary' => 'Origin',
          'Access-Control-Allow-Methods' => 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
          'Access-Control-Allow-Headers' => (acrh || 'Content-Type, Authorization, Accept'),
          'Access-Control-Allow-Credentials' => 'true',
          'Access-Control-Max-Age' => '600'
  status 204
  body ''
end

get '/' do
  content_type :text
  body 'Welcome to the Hivemind MCP Server'
end

# Quiet and log telemetry proxy calls (likely from external UIs like n8n)
%w[post get put patch delete].each do |verb|
  telemetry_paths = [
    '/rest/telemetry/proxy/v1/track',
    '/rest/telemetry/proxy/v1/identify',
    '/rest/telemetry/proxy/v1/page'
  ]

  telemetry_paths.each do |path|
    send(verb, path) do
      origin   = request.env['HTTP_ORIGIN']
      referer  = request.env['HTTP_REFERER']
      ua       = request.env['HTTP_USER_AGENT']
      payload  = request.body.read rescue nil
      puts "[TELEMETRY-#{request.request_method}] path=#{request.path_info} origin=#{origin.inspect} referer=#{referer.inspect} ua=#{ua.inspect} bytes=#{payload ? payload.bytesize : 0}"

      headers 'Access-Control-Allow-Origin' => (origin || '*'),
              'Vary' => 'Origin',
              'Access-Control-Allow-Credentials' => 'true'
      status 204
      body ''
    end
  end
end
