# frozen_string_literal: true

require 'time'

module HivemindMCP
  class TimeResource < FastMcp::Resource
    # Provides the current date/time.
    uri "mcp://hivemind/datetime"
    resource_name "current-datetime"
    mime_type "text/plain"
    description "Get current date and time"

  # The actual content generation, used by the server when reading this resource
    def content
      Time.now.utc.iso8601
    end
  end
end
