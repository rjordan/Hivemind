# frozen_string_literal: true

require 'fast_mcp'
require_relative '../lib/request_context'

module HivemindMCP
  class AuthTestTool < ::FastMcp::Tool
    description "Test auth header forwarding - shows if auth header was received"

    def call
      auth_header = HivemindMCP::RequestContext.current_auth_header

      if auth_header
        # Only show first 20 characters for security
        preview = auth_header.length > 20 ? "#{auth_header[0..19]}..." : auth_header
        <<~TEXT
          ===== Auth Test =====
          Auth Header: Present
          Preview: #{preview}
          Length: #{auth_header.length} characters
          ======================
        TEXT
      else
        <<~TEXT
          ===== Auth Test =====
          Auth Header: Not present
          ======================
        TEXT
      end
    end
  end
end
