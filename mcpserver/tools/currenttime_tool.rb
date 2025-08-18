# frozen_string_literal: true

require_relative '../lib/db'
require_relative '../lib/models'

module HivemindMCP
  class CurrentTimeTool < FastMcp::Tool
    description "Fetch the current server time"

    def call
      Time.now.utc.iso8601
    end
  end
end
