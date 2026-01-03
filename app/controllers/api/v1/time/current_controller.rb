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
#
# Features:
# - Returns current time for multiple countries
# - Detects user's timezone from IP address
# - Calculates time gap between user's location and requested countries

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
        # Response includes:
        #   - results: Array of country time information with gap data
        #   - userTimezone: Detected timezone info (if available)
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

          # Detect user's timezone from their IP address
          user_timezone = detect_user_timezone

          # Use the service to get the current time for each country
          service = TimezoneService.new
          results = service.get_current_time(countries, reference_timezone: user_timezone)

          # Build the response
          response = { results: results }

          # Add user timezone info if detected
          if user_timezone.present?
            response[:userTimezone] = {
              timezone: user_timezone[:timezone],
              offset: user_timezone[:offset_string],
              detectedFromIp: true
            }
          else
            response[:userTimezone] = {
              detectedFromIp: false,
              message: "Could not detect timezone from IP address"
            }
          end

          # Return the results as JSON
          render json: response
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

        # Detect user's timezone from their IP address
        #
        # @return [Hash, nil] Timezone info or nil if detection failed
        #
        def detect_user_timezone
          # Get the client's IP address
          # request.remote_ip handles proxies and X-Forwarded-For headers
          client_ip = request.remote_ip

          # Use the IP timezone service to detect timezone
          ip_service = IpTimezoneService.new
          ip_service.detect_timezone(client_ip)
        end
      end
    end
  end
end
