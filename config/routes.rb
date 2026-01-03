# frozen_string_literal: true

# Rails Routes Configuration
# =========================
# This file defines all API endpoints for the TimeStay application.
# All endpoints are versioned under /api/v1 for future compatibility.

Rails.application.routes.draw do
  # Health check endpoint for Docker/Kubernetes
  get "up" => "rails/health#show", as: :rails_health_check

  # API v1 namespace
  # All endpoints are grouped under /api/v1/...
  namespace :api do
    namespace :v1 do
      # Time endpoints
      # GET /api/v1/time/current?countries=Japan,China
      namespace :time do
        get "current", to: "current#index"
      end

      # Timezone endpoints
      # GET /api/v1/zones         - List all available timezones
      # GET /api/v1/zones/:zone   - Get details for a specific timezone
      resources :zones, only: [:index, :show], param: :zone
    end
  end
end
