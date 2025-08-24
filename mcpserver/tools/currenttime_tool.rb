# frozen_string_literal: true

module HivemindMCP
  class CurrentTimeTool < FastMcp::Tool
    description "Fetch the current server time"

    def call
      Time.now.utc.iso8601
    end
  end
end
