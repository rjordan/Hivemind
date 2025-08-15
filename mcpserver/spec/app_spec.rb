# frozen_string_literal: true

require 'spec_helper'
require_relative '../app'
require 'rack/test'

RSpec.describe 'Hivemind MCP App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'responds to /health' do
    get '/health'
    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body['status']).to eq('ok')
  end
end
