# frozen_string_literal: true

require 'active_record'

# Try to reuse Rails app models from ../app/models when available.
rails_models_dir = File.expand_path('../../app/models', __dir__)
if Dir.exist?(rails_models_dir)
  $LOAD_PATH.unshift(rails_models_dir) unless $LOAD_PATH.include?(rails_models_dir)
  concerns_dir = File.join(rails_models_dir, 'concerns')
  $LOAD_PATH.unshift(concerns_dir) if Dir.exist?(concerns_dir) && !$LOAD_PATH.include?(concerns_dir)
  begin
    require 'application_record'
    require 'character'
  rescue LoadError => e
    warn "Failed to load Rails models: #{e.class}: #{e.message}. Falling back to local models."
  end
end

module HivemindMCP
  if defined?(::Character)
    Character = ::Character
  else
    # Fallback minimal model if Rails models aren't available
    class Character < ActiveRecord::Base; end
  end
end
