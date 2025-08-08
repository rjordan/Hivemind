class CreateExtensions < ActiveRecord::Migration[8.0]
  def change
    enable_extension "uuid-ossp" unless extension_enabled?("uuid-ossp")
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
  end
end
