# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/request_context'

RSpec.describe 'Auth Header Forwarding Integration' do
  let(:auth_token) { 'Bearer integration-test-token' }
  let(:graphql_url) { 'http://localhost:3000/graphql' }

  before do
    # Stub the GraphQL endpoint
    stub_request(:post, graphql_url)
      .with(headers: { 'Authorization' => auth_token })
      .to_return(
        status: 200,
        body: {
          'data' => {
            'character' => {
              'id' => 'test-id',
              'name' => 'Test Character',
              'alternateNames' => [],
              'tags' => [],
              'public' => true,
              'facts' => []
            }
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  it 'properly forwards auth headers through the request context' do
    # Simulate the middleware setting the auth header
    HivemindMCP::RequestContext.with_auth_header(auth_token) do
      # Create an authenticated connection (this is what tools would do)
      conn = HivemindMCP::RequestContext.authenticated_connection(graphql_url)

      # Make a request
      response = conn.post('') do |req|
        req.body = { query: 'test query' }
      end

      # Verify the request was made with the auth header
      expect(WebMock).to have_requested(:post, graphql_url)
        .with(headers: { 'Authorization' => auth_token })

      # Verify we got a successful response
      expect(response.status).to eq(200)
    end
  end

  it 'works without auth header when none is provided' do
    stub_request(:post, graphql_url)
      .to_return(
        status: 200,
        body: { 'data' => { 'character' => nil } }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # No auth header context
    conn = HivemindMCP::RequestContext.authenticated_connection(graphql_url)
    response = conn.post('') { |req| req.body = { query: 'test' } }

    # Should work without Authorization header
    expect(response.status).to eq(200)
    expect(WebMock).to have_requested(:post, graphql_url)
      .with { |req| !req.headers.key?('Authorization') }
  end
end
