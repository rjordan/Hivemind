# frozen_string_literal: true

require 'faraday'

module HivemindMCP
  # Thread-local storage for request context, primarily auth headers
  class RequestContext
    class << self
      def with_auth_header(header_value)
        previous_value = Thread.current[:hivemind_auth_header]
        Thread.current[:hivemind_auth_header] = header_value
        yield
      ensure
        Thread.current[:hivemind_auth_header] = previous_value
      end

      def current_auth_header
        Thread.current[:hivemind_auth_header]
      end

      # Clear all request context (useful for cleanup)
      def clear!
        Thread.current[:hivemind_auth_header] = nil
      end

      # Helper method to create an authenticated Faraday connection
      def authenticated_connection(base_url)
        Faraday.new(url: base_url) do |conn|
          conn.request :json
          conn.response :json
          auth_header = current_auth_header
          conn.headers['Authorization'] = auth_header if auth_header
          yield(conn) if block_given?
        end
      end
    end
  end

  # Rack middleware to extract auth headers from incoming requests
  class AuthHeaderMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      auth_header = env['HTTP_AUTHORIZATION']

      if auth_header
        puts "[AUTH] Extracted Authorization header: #{auth_header[0..20]}..." if auth_header.length > 20
        RequestContext.with_auth_header(auth_header) do
          @app.call(env)
        end
      else
        @app.call(env)
      end
    end
  end
end
