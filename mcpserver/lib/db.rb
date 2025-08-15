# frozen_string_literal: true

require 'active_record'

module HivemindMCP
  module DB
    module_function

    def configured?
      # Accept either a full URL or host+database pair
      ENV['HIVEMIND_DB_URL'] || ENV['DATABASE_URL'] || (ENV['HIVEMIND_DB_HOST'] && ENV['HIVEMIND_DB_DATABASE'])
    end

    def establish_connection!
      return unless configured?
      url = ENV['HIVEMIND_DB_URL'] || ENV['DATABASE_URL']
      if url && !url.empty?
        puts "Connecting to database via URL"
        ActiveRecord::Base.establish_connection(url)
      else
        config = {
          adapter: 'postgresql',
          host: ENV.fetch('HIVEMIND_DB_HOST', 'localhost'),
          database: ENV.fetch('HIVEMIND_DB_DATABASE', 'hivemind_dev'),
          username: ENV.fetch('HIVEMIND_DB_USER', 'postgres'),
          password: ENV.fetch('HIVEMIND_DB_PASSWORD', 'password'),
          encoding: 'unicode',
          pool: ENV.fetch('AR_POOL', 5)
        }
        puts "Connecting to database: #{config[:database]} at #{config[:host]}"
        ActiveRecord::Base.establish_connection(config)
      end
      # Eagerly verify the connection so status checks reflect reality
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.connection.execute('SELECT 1')
      end
    rescue StandardError => e
      warn "ActiveRecord connection failed: #{e.class}: #{e.message}"
    end

    def connected?
      return false unless configured?
      ActiveRecord::Base.connection_pool.with_connection do
        conn = ActiveRecord::Base.connection
        return true if conn.active?
        # Try a lightweight query to activate the connection
        conn.execute('SELECT 1')
        conn.active?
      end
    rescue StandardError
      false
    end
  end
end
