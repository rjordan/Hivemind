class AuthController < ApiController
  skip_before_action :authenticate_api_user!, only: [:github_callback, :mock_login]
  # 'me' requires auth; don't skip authenticate_api_user!

  def me
    unless current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end

    render json: {
      user: {
        id: current_user.id,
        email: current_user.email,
        name: current_user.name,
        avatar_url: current_user.avatar_url
      }
    }
  end

  def github_callback
    code = params[:code]

    if code.blank?
      render json: { error: 'Authorization code not provided' }, status: :bad_request
      return
    end

    begin
      # Exchange code for access token
      Rails.logger.info "GitHub Client ID: #{ENV['GITHUB_CLIENT_ID']}"
      token_response = HTTParty.post(
        'https://github.com/login/oauth/access_token',
        body: {
          client_id: ENV['GITHUB_CLIENT_ID'],
          client_secret: ENV['GITHUB_CLIENT_SECRET'],
          code: code
        },
        headers: {
          'Accept' => 'application/json'
        }
      )
      Rails.logger.info "GitHub OAuth token response: #{token_response.parsed_response.inspect}"
      access_token = token_response.parsed_response['access_token']

      if access_token.blank?
        render json: { error: 'Failed to obtain access token' }, status: :unauthorized
        return
      end

      # Get user info from GitHub
      user_response = HTTParty.get(
        'https://api.github.com/user',
        headers: {
          'Authorization' => "Bearer #{access_token}",
          'Accept' => 'application/json'
        }
      )

      github_user = user_response.parsed_response

      if github_user['id'].blank?
        render json: { error: 'Failed to get user info from GitHub' }, status: :unauthorized
        return
      end

      # Find or create user
      user = User.find_by(github_id: github_user['id'])

      if user.nil?
        user = User.create!(
          github_id: github_user['id'],
          email: github_user['email'] || "#{github_user['login']}@github.local",
          name: github_user['name'] || github_user['login'],
          avatar_url: github_user['avatar_url']
        )
      else
        # Update user info
        user.update!(
          email: github_user['email'] || user.email,
          name: github_user['name'] || github_user['login'],
          avatar_url: github_user['avatar_url']
        )
      end

      # Generate JWT token
      payload = {
        user_id: user.id,
        exp: 30.days.from_now.to_i
      }

      jwt_token = JWT.encode(payload, Rails.application.secret_key_base, 'HS256')

      render json: {
        token: jwt_token,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          avatar_url: user.avatar_url
        }
      }

    rescue StandardError => e
      Rails.logger.error "GitHub OAuth error: #{e.message}"
      render json: { error: 'Authentication failed' }, status: :internal_server_error
    end
  end

  # Development-only mock login
  def mock_login
    unless Rails.env.development? || Rails.env.test?
      render json: { error: 'Mock login only available in development' }, status: :forbidden
      return
    end

    # Find or create a test user
    begin
      user = User.find_or_create_by!(email: 'test@example.com') do |u|
        u.name = 'Test User'
        u.github_id = 'mock_123'
        u.avatar_url = 'https://avatars.githubusercontent.com/u/12345?v=4'
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Mock login user creation failed: #{e.record.errors.full_messages.join(', ')}"
      render json: { error: 'Failed to create mock user' }, status: :internal_server_error and return
    rescue ActiveRecord::NoDatabaseError => e
      Rails.logger.error "Mock login failed - database unavailable: #{e.message}"
      render json: { error: 'Service temporarily unavailable (database)' }, status: :service_unavailable and return
    end

    # Generate JWT token
    payload = {
      user_id: user.id,
      exp: 30.days.from_now.to_i
    }

    jwt_token = JWT.encode(payload, Rails.application.secret_key_base, 'HS256')

    render json: {
      token: jwt_token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        avatar_url: user.avatar_url
      }
    }
  end
end
