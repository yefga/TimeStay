# frozen_string_literal: true

# Api::V1::ZonesController
# ========================
# Handles requests for timezone information.
#
# Endpoints:
#   GET /api/v1/zones       - List all available timezones
#   GET /api/v1/zones/:zone - Get details for a specific timezone
#
# This controller follows RESTful conventions:
#   - index action for listing all resources
#   - show action for a single resource

module Api
  module V1
    class ZonesController < ApplicationController
      # GET /api/v1/zones
      #
      # Returns a list of all available timezones with their UTC offsets.
      # Useful for clients to discover what timezones are supported.
      #
      def index
        service = TimezoneService.new
        zones = service.list_all_zones

        render json: {
          count: zones.length,
          zones: zones
        }
      end

      # GET /api/v1/zones/:zone
      #
      # Returns details for a specific timezone including:
      # - Current time in that zone
      # - Countries that use this timezone
      #
      # The :zone parameter can be URL-encoded (e.g., "Asia%2FTokyo" for "Asia/Tokyo")
      #
      def show
        # URL decode the zone parameter (e.g., "Asia%2FTokyo" -> "Asia/Tokyo")
        zone_name = params[:zone]

        service = TimezoneService.new
        zone_details = service.get_zone_details(zone_name)

        if zone_details.nil?
          render json: {
            error: "Timezone not found",
            provided: zone_name,
            hint: "Use /api/v1/zones to see all available timezones"
          }, status: :not_found
          return
        end

        render json: zone_details
      end
    end
  end
end
