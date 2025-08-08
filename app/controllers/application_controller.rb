class ApplicationController < ActionController::API

  def current_user
    token = request.headers['Authorization']&.split(' ')&.last
    return nil unless token

  #   decoded = JWT.decode(token, Rails.application.secret_key_base)
  #   User.find(decoded[0]['user_id'])
  # rescue JWT::DecodeError
  #   nil
    @current_user ||= User.first #.find_by(username: 'rjordan'))
  end
end
