require 'rails_helper'

RSpec.describe AuthController, type: :request do
  let(:secret) { Rails.application.secret_key_base }
  let(:user)   { User.create!(name: 'tester', email: 'tester@example.com') }

  def jwt_for(u, exp: 1.hour.from_now)
    JWT.encode({ user_id: u.id, exp: exp.to_i }, secret, 'HS256')
  end

  describe 'POST /auth/github/callback' do
    let(:code) { 'oauth_code_123' }

    context 'when exchange succeeds and user info retrieved' do
      before do
        stub_request(:post, 'https://github.com/login/oauth/access_token')
          .with(body: hash_including(code: code))
          .to_return(status: 200, body: { access_token: 'gh_test_token', token_type: 'bearer', scope: 'user:email' }.to_json, headers: { 'Content-Type' => 'application/json' })

        stub_request(:get, 'https://api.github.com/user')
          .with(headers: { 'Authorization' => 'Bearer gh_test_token' })
          .to_return(status: 200, body: { id: 999, login: 'octotest', email: 'octo@example.com', avatar_url: 'http://example.com/a.png' }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'creates (or updates) user and returns JWT + user payload' do
        post '/auth/github/callback', params: { code: code }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['token']).to be_present
        expect(body['user']).to include('email' => 'octo@example.com', 'name' => 'octotest')
        expect(User.find_by(github_id: '999')).to be_present
      end
    end

    context 'when access token exchange fails' do
      before do
        stub_request(:post, 'https://github.com/login/oauth/access_token')
          .to_return(status: 200, body: { error: 'bad_verification_code' }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns unauthorized' do
        post '/auth/github/callback', params: { code: code }
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('Failed to obtain access token')
      end
    end

    context 'when code missing' do
      it 'returns bad_request' do
        post '/auth/github/callback'
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'POST /auth/mock/login' do
    it 'creates mock user (idempotent) and returns token & user' do
      post '/auth/mock/login'
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['token']).to be_present
      expect(body['user']).to include('email' => 'test@example.com')

      # second call should not create duplicate user
      expect { post '/auth/mock/login' }.not_to change { User.count }
    end

    it 'returns a JWT that decodes to the created user id' do
      post '/auth/mock/login'
      body = JSON.parse(response.body)
      token = body['token']
      decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
      expect(decoded.first['user_id']).to eq(User.find_by(email: 'test@example.com').id)
    end

    it 'returns 503 when database unavailable' do
      # Simulate DB connectivity issue
      allow(User).to receive(:find_or_create_by!).and_raise(ActiveRecord::NoDatabaseError.new('db missing'))
      post '/auth/mock/login'
      expect(response).to have_http_status(:service_unavailable)
      body = JSON.parse(response.body)
      expect(body['error']).to match(/Service temporarily unavailable/)
    end
  end

  describe 'GET /auth/me' do
    it '401 without token' do
      get '/auth/me'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns user with valid token' do
      token = jwt_for(user)
      get '/auth/me', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['user']).to include('id' => user.id, 'email' => user.email)
    end

    it '401 with expired token' do
      token = jwt_for(user, exp: 1.hour.ago)
      get '/auth/me', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
