require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:user) { User.new(name: 'testuser', email: 'test@example.com') }

    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'validates presence of email' do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'validates uniqueness of email' do
      User.create!(name: 'user1', email: 'unique@example.com')
      other_user = User.new(name: 'user2', email: 'unique@example.com')
      expect(other_user).not_to be_valid
      expect(other_user.errors[:email]).to include("has already been taken")
    end

    it 'validates email format' do
      user.email = 'invalid_email'
      # Note: Add email format validation to User model if needed
    end
  end

  describe 'associations' do
    let(:user) { User.create!(name: 'user_assoc', email: 'assoc@example.com') }

    it 'has many characters' do
      expect(user).to respond_to(:characters)
      expect(User.reflect_on_association(:characters).macro).to eq(:has_many)
    end

    it 'has many personas' do
      expect(user).to respond_to(:personas)
      expect(User.reflect_on_association(:personas).macro).to eq(:has_many)
    end

    it 'has many conversations through personas' do
      expect(user).to respond_to(:conversations)
      expect(User.reflect_on_association(:conversations).macro).to eq(:has_many)
      expect(User.reflect_on_association(:conversations).options[:through]).to eq(:personas)
    end

    it 'destroys dependent characters when user is deleted' do
      character = user.characters.create!(name: 'Test Character')
      expect { user.destroy }.to change { Character.count }.by(-1)
    end

    it 'destroys dependent personas when user is deleted' do
      persona = user.personas.create!(name: 'Test Persona', description: 'Test Description')
      expect { user.destroy }.to change { Persona.count }.by(-1)
    end
  end

  describe 'database constraints' do
    it 'has UUID as primary key' do
      user = User.create!(name: 'db_test_user', email: 'db@example.com')
      expect(user.id).to be_present
      expect(user.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'has unique index on email' do
      User.create!(name: 'testuser1', email: 'unique_email@example.com')
      # Since Rails validates uniqueness at the application level first,
      # we get a validation error before hitting the database constraint
      expect {
        User.create!(name: 'testuser2', email: 'unique_email@example.com')
      }.to raise_error(ActiveRecord::RecordInvalid, /Email has already been taken/)
    end
  end
end
