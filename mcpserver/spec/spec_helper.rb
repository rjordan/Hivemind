# frozen_string_literal: true

require 'rspec'
require 'webmock/rspec'
require 'json'

ENV['RACK_ENV'] = 'test'
ENV['HIVEMIND_API_URL'] ||= 'http://localhost:3000/graphql'
ENV['HIVEMIND_API_TOKEN'] ||= 'dev-token'

# Disable real network connections during tests
WebMock.disable_net_connect!(allow_localhost: false)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Run focused tests when available
  config.filter_run_when_matching :focus

  # Use the documentation formatter for detailed output,
  # unless a formatter has already been configured
  config.default_formatter = 'doc' if config.files_to_run.one?

  # Run specs in random order to surface order dependencies
  config.order = :random
  Kernel.srand config.seed
end
