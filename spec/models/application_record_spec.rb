require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  describe 'abstract class configuration' do
    it 'is configured as primary abstract class' do
      # ApplicationRecord is the abstract base class for all models in Rails
      expect(ApplicationRecord.abstract_class?).to be_truthy
    end

    it 'sets implicit_order_column to created_at' do
      expect(ApplicationRecord.implicit_order_column).to eq(:created_at)
    end
  end

  describe 'UUID primary key configuration' do
    # Test that models inheriting from ApplicationRecord use UUID primary keys
    let(:user) { User.create!(username: 'app_rec_user', email: 'app_rec@example.com') }
    let(:persona) { user.personas.create!(name: 'Test Persona', description: 'Test Description') }

    it 'generates UUID primary keys for inheriting models' do
      expect(user.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
      expect(persona.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'ensures primary keys are different for each record' do
      user1 = User.create!(username: 'user1', email: 'user1@example.com')
      user2 = User.create!(username: 'user2', email: 'user2@example.com')

      expect(user1.id).not_to eq(user2.id)
    end
  end

  describe 'timestamp behavior' do
    let(:user) { User.create!(username: 'timestamp_user', email: 'timestamp@example.com') }

    it 'automatically sets created_at and updated_at' do
      expect(user.created_at).to be_present
      expect(user.updated_at).to be_present
    end

    it 'updates updated_at when record is modified' do
      original_updated_at = user.updated_at
      sleep(0.001) # Ensure timestamp difference
      user.update!(username: 'updated_username')

      expect(user.updated_at).to be > original_updated_at
    end

    it 'uses created_at for implicit ordering' do
      # Create multiple users
      user1 = User.create!(username: 'user1', email: 'user1@example.com')
      sleep(0.001)
      user2 = User.create!(username: 'user2', email: 'user2@example.com')
      sleep(0.001)
      user3 = User.create!(username: 'user3', email: 'user3@example.com')

      # Default order should be by created_at
      users = User.where(id: [user1.id, user2.id, user3.id])
      expect(users.map(&:username)).to eq(['user1', 'user2', 'user3'])
    end
  end
end
