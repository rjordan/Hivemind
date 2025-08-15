class ApplicationController < ActionController::Base
  # Skip CSRF for API requests
  protect_from_forgery with: :null_session

  before_action :authenticate_user!, except: [ :frontend ]

  def current_user
    token = request.headers["Authorization"]&.split(" ")&.last
    return nil unless token

    # Allow passing a fake token in dev
    if Rails.env.development? || Rails.env.test?
      if token == "FAKE_TOKEN"
        return @current_user ||= User.find_by(email: "rjordan01@gmail.com")
      end
    end

    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: "HS256" })
      @current_user ||= User.find(decoded[0]["user_id"])
    rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
      nil
    end
  end

  def frontend
    render file: Rails.public_path.join("index.html"), layout: false
  end

  private

  def authenticate_user!
    unless current_user
      if request.format.json?
        render json: { error: "Unauthorized" }, status: :unauthorized
      else
        redirect_to root_path
      end
    end
  end
end
