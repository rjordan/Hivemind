# frozen_string_literal: true

require 'spec_helper'
require 'time'
require 'fast_mcp'
require_relative '../../resources/time_resource'

RSpec.describe HivemindMCP::TimeResource do
  let(:resource) { described_class }
  let(:server) { FastMcp::Server.new(name: 'test', version: '0.0.1') }

  before { server.register_resource(resource) }

  it 'exposes the resource metadata via the server' do
  list = server.resources
  expect(list).to include(HivemindMCP::TimeResource)
  # verify class-level metadata
  klass = HivemindMCP::TimeResource
  expect(klass.uri).to eq('mcp://hivemind/datetime')
  expect(klass.resource_name).to eq('current-datetime')
  expect(klass.mime_type).to eq('text/plain')
  end

  it 'returns current datetime as an ISO8601 string' do
  value = described_class.new.content
    expect(value).to be_a(String)

    # parses as ISO8601 and is close to now (avoid strict timezone assumptions)
    parsed = Time.iso8601(value)
    expect(parsed).to be_a(Time)
    expect((Time.now - parsed).abs).to be < 10 # seconds
  end
end
