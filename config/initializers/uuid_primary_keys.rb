# Configure UUID as default primary key type for new migrations
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end
