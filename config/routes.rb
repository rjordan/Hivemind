Rails.application.routes.draw do
  # API routes
  post "/graphql", to: "graphql#execute"

  # Auth API routes
  post "/auth/github/callback", to: "auth#github_callback"
  get "/auth/me", to: "auth#me"

  # Development-only mock auth (remove in production)
  if Rails.env.development? || Rails.env.test?
    post "/auth/mock/login", to: "auth#mock_login"
  end

  namespace :api do
    resources :conversations
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Catch-all route for SPA (must be last)
  # This serves the frontend for all non-API routes
  get "*path", to: "application#frontend", constraints: ->(req) {
    !req.xhr? && req.format.html?
  }

  # Root route
  root "application#frontend"
end
