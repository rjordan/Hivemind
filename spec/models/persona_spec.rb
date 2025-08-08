require 'rails_helper'

RSpec.describe Persona, type: :model do
  let(:user) { User.create!(username: 'persona_user', email: 'persona@example.com') }

  describe 'validations' do
    let(:persona) { user.personas.build(name: 'Test Persona', description: 'A test persona description') }

    it 'is valid with valid attributes' do
      expect(persona).to be_valid
    end

    it 'validates presence of name' do
      persona.name = nil
      expect(persona).not_to be_valid
      expect(persona.errors[:name]).to include("can't be blank")
    end

    it 'validates presence of description' do
      persona.description = nil
      expect(persona).not_to be_valid
      expect(persona.errors[:description]).to include("can't be blank")
    end

    it 'is invalid without a user' do
      persona = Persona.new(name: 'Test Persona', description: 'Test Description')
      expect(persona).not_to be_valid
      expect(persona.errors[:user]).to include("must exist")
    end
  end

  describe 'associations' do
    let(:persona) { user.personas.create!(name: 'Test Persona', description: 'A test persona description') }

    it 'belongs to a user' do
      expect(persona).to respond_to(:user)
      expect(Persona.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it 'returns the correct user' do
      expect(persona.user).to eq(user)
    end
  end

  describe 'database constraints' do
    it 'has UUID as primary key' do
      persona = user.personas.create!(name: 'Test Persona', description: 'A test persona description')
      expect(persona.id).to be_present
      expect(persona.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'references user with UUID foreign key' do
      persona = user.personas.create!(name: 'Test Persona', description: 'A test persona description')
      expect(persona.user_id).to eq(user.id)
      expect(persona.user_id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end
  end

  describe 'attributes' do
    let(:persona) { user.personas.create!(name: 'Test Persona', description: 'A test persona description', default: true) }

    it 'can have a default flag' do
      expect(persona.default).to be_truthy
    end

    it 'has timestamps' do
      expect(persona.created_at).to be_present
      expect(persona.updated_at).to be_present
    end
  end
end
