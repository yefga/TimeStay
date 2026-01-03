# frozen_string_literal: true

# Api::V1::Time::CurrentController
# ================================
# Handles requests for current time in different countries.
#
# Endpoint: GET /api/v1/time/current?countries=Japan,China
#
# This controller is namespaced under Api::V1::Time to:
# 1. Keep related endpoints organized
# 2. Allow for future versioning (V2, V3, etc.)
# 3. Follow RESTful conventions

module Api
  module V1
    module Time
      class CurrentController < ApplicationController
        # GET /api/v1/time/current
        #
        # Query Parameters:
        #   countries - Comma-separated list of country names
        #
        # Example: /api/v1/time/current?countries=Japan,China
        #
        def index
          # Parse the countries from query params
          # "Japan,China" becomes ["Japan", "China"]
          countries = parse_countries

          # Validate that at least one country was provided
          if countries.empty?
            render json: {
              error: "Please provide at least one country",
              example: "/api/v1/time/current?countries=Japan,China"
            }, status: :bad_request
            return
          end

          # Use the service to get the current time for each country
          service = TimezoneService.new
          results = service.get_current_time(countries)

          # Return the results as JSON
          render json: { results: results }
        end

        private

        # Parse countries from the query string
        #
        # @return [Array<String>] List of country names (trimmed)
        #
        def parse_countries
          countries_param = params[:countries].to_s
          countries_param.split(",").map(&:strip).reject(&:empty?)
        end
      end
    end
  end
end
