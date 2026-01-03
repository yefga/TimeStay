# frozen_string_literal: true

# TimezoneService
# ===============
# This service handles all timezone-related business logic.
# It loads country mappings from YAML and provides methods to:
# - Get the current time for countries
# - List all available timezones
# - Find countries within a specific timezone
#
# Why a Service Object?
# ---------------------
# Service objects keep business logic separate from controllers.
# Controllers should only handle HTTP concerns (params, responses).
# Services handle the "how" of the business logic.

class TimezoneService
  # Load the country-to-timezone mappings from YAML file
  # This is loaded once when the class is first used
  COUNTRY_MAPPINGS = YAML.load_file(
    Rails.root.join("config", "timezone_mappings.yml")
  ).freeze

  # Get the current time for a list of countries
  #
  # @param countries [Array<String>] List of country names
  # @return [Array<Hash>] Array of results with country, timezone, and current time
  #
  # Example:
  #   get_current_time(["Japan", "China"])
  #   # => [
  #   #      { country: "Japan", timezone: "Asia/Tokyo", current_time: "..." },
  #   #      { country: "China", timezone: "Asia/Shanghai", current_time: "..." }
  #   #    ]
  #
  def get_current_time(countries)
    countries.map do |country|
      timezone_name = COUNTRY_MAPPINGS[country]

      if timezone_name.nil?
        # Country not found in our mappings
        {
          country: country,
          error: "Country not found"
        }
      else
        # Get the timezone object from ActiveSupport
        timezone = ActiveSupport::TimeZone[timezone_name]

        if timezone.nil?
          # Timezone exists in YAML but not recognized by Rails
          {
            country: country,
            error: "Timezone not available"
          }
        else
          # Success! Return the country info with current time
          {
            country: country,
            timezone: timezone_name,
            current_time: timezone.now.iso8601
          }
        end
      end
    end
  end

  # Get a list of all available timezones
  #
  # @return [Array<Hash>] Array of timezone info
  #
  # Example:
  #   list_all_zones
  #   # => [
  #   #      { name: "Pacific/Midway", offset: "-11:00", utc_offset: -39600 },
  #   #      ...
  #   #    ]
  #
  def list_all_zones
    ActiveSupport::TimeZone.all.map do |zone|
      {
        name: zone.tzinfo.name,
        offset: format_offset(zone.utc_offset),
        utc_offset: zone.utc_offset
      }
    end.uniq { |z| z[:name] }.sort_by { |z| z[:utc_offset] }
  end

  # Get details for a specific timezone
  #
  # @param zone_name [String] The timezone name (e.g., "Asia/Tokyo")
  # @return [Hash, nil] Zone details or nil if not found
  #
  # Example:
  #   get_zone_details("Asia/Tokyo")
  #   # => {
  #   #      name: "Asia/Tokyo",
  #   #      offset: "+09:00",
  #   #      current_time: "2026-01-03T13:00:00+09:00",
  #   #      countries: ["Japan"]
  #   #    }
  #
  def get_zone_details(zone_name)
    # Try to find the timezone
    # We need to search through all zones since the name might be formatted differently
    zone = find_zone(zone_name)

    return nil if zone.nil?

    # Find all countries that use this timezone
    countries_in_zone = COUNTRY_MAPPINGS.select { |_country, tz| tz == zone.tzinfo.name }.keys

    {
      name: zone.tzinfo.name,
      offset: format_offset(zone.utc_offset),
      current_time: zone.now.iso8601,
      countries: countries_in_zone
    }
  end

  private

  # Find a timezone by name (handles various input formats)
  #
  # @param zone_name [String] The timezone name
  # @return [ActiveSupport::TimeZone, nil] The timezone or nil
  #
  def find_zone(zone_name)
    # First, try direct lookup
    zone = ActiveSupport::TimeZone[zone_name]
    return zone if zone

    # Try to find by tzinfo name in all zones
    ActiveSupport::TimeZone.all.find do |z|
      z.tzinfo.name.downcase == zone_name.downcase
    end
  end

  # Format UTC offset in human-readable form
  #
  # @param offset_seconds [Integer] Offset in seconds
  # @return [String] Formatted offset (e.g., "+09:00", "-05:00")
  #
  def format_offset(offset_seconds)
    hours, minutes = offset_seconds.abs.divmod(3600)
    minutes = minutes / 60
    sign = offset_seconds >= 0 ? "+" : "-"
    format("%s%02d:%02d", sign, hours, minutes)
  end
end
