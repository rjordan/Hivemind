class ApiController < ApplicationController
  # Skip frontend rendering for API controllers
  skip_before_action :authenticate_user!
  before_action :authenticate_api_user!

  private

  def authenticate_api_user!
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
