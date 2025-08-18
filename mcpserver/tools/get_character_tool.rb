# frozen_string_literal: true

require 'erb'
require 'fast_mcp'

require_relative '../lib/db'
require_relative '../lib/models'

module HivemindMCP
  class GetCharacterTool < ::FastMcp::Tool
    description "Fetch a character by ID (uses DB when configured, otherwise GraphQL)"

    arguments do
      required(:id).filled(:string).description("Character ID")
    end

    def call(id:)
      record = Character.find_by(id: id_extracted(id))
      return "" unless record
      serialize_character(record)
    end

    private

    def id_extracted(id)
      # handle both raw UUID and Rails Global ID formats
      if id.to_s.include?('gid://')
        id.split('/').last
      else
        id
      end
    end

    def serialize_character(record)
      id = "gid://hivemind/Character/#{record.id}"
      name = record.name
      alternate_names = Array(record.alternate_names).map(&:to_s)
      tags = Array(record.tags).map(&:to_s)
      public_flag = !!record.public
      facts = Array(record.respond_to?(:facts) ? record.facts : [])
                .map { |f| f.respond_to?(:fact) ? f.fact : f.to_s }

      template = <<~ERB
      ===== Character =====
      ID: <%= id %>
      Name: <%= name %>
      Alternate Names: <%= alternate_names.join(", ") %>
      Tags: <%= tags.join(", ") %>
      Public: <%= public_flag ? "Yes" : "No" %>
      Facts:
      <% if facts.empty? %>
        - (none)
      <% else %>
      <% facts.each do |fact| %>
        - <%= fact %>
      <% end %>
      <% end %>
      =====================
      ERB

      ERB.new(template, trim_mode: '-').result(binding)
    end
  end
end
