# frozen_string_literal: true

# IpTimezoneService
# =================
# This service detects the user's timezone based on their IP address.
# It uses the Geocoder gem to perform IP geolocation and extract timezone info.
#
# Why a separate service?
# -----------------------
# - Single Responsibility: Each service has one job
# - Testability: Easy to mock/stub in tests
# - Flexibility: Can swap out geolocation providers easily
#
class IpTimezoneService
  # Detect timezone from an IP address
  #
  # @param ip_address [String] The IP address to lookup
  # @return [Hash, nil] Timezone info or nil if detection failed
  #
  # Example:
  #   detect_timezone("203.0.113.50")
  #   # => { timezone: "Asia/Tokyo", utc_offset: 32400, offset_string: "+09:00" }
  #
  def detect_timezone(ip_address)
    return nil if ip_address.blank? || local_ip?(ip_address)

    # Use Geocoder to lookup the IP
    result = Geocoder.search(ip_address).first
    return nil unless result

    # Extract timezone from the geocoder result
    # Different geocoding services return timezone in different ways
    timezone_name = extract_timezone(result)
    return nil unless timezone_name

    # Get the ActiveSupport timezone
    timezone = find_timezone(timezone_name)
    return nil unless timezone

    {
      timezone: timezone.tzinfo.name,
      utc_offset: timezone.utc_offset,
      offset_string: format_offset(timezone.utc_offset)
    }
  end

  private

  # Check if the IP is a local/private IP
  #
  # @param ip [String] IP address to check
  # @return [Boolean] True if local/private IP
  #
  def local_ip?(ip)
    # Common local/private IP patterns
    ip.start_with?("127.", "10.", "192.168.", "172.16.", "172.17.",
                   "172.18.", "172.19.", "172.20.", "172.21.", "172.22.",
                   "172.23.", "172.24.", "172.25.", "172.26.", "172.27.",
                   "172.28.", "172.29.", "172.30.", "172.31.") ||
      ip == "::1" || ip == "0.0.0.0"
  end

  # Extract timezone from geocoder result
  # Handles different result formats from various providers
  #
  # @param result [Geocoder::Result] Geocoder result object
  # @return [String, nil] Timezone name or nil
  #
  def extract_timezone(result)
    # Try common methods to get timezone
    # Different geocoding services provide timezone differently

    # For ipinfo.io, ipapi, etc.
    if result.respond_to?(:data) && result.data.is_a?(Hash)
      timezone = result.data["timezone"] || result.data["time_zone"]

      # Handle nested timezone objects (like from some providers)
      if timezone.is_a?(Hash)
        timezone = timezone["id"] || timezone["name"]
      end

      return timezone if timezone.present?
    end

    # Try direct timezone method
    return result.timezone if result.respond_to?(:timezone) && result.timezone.present?

    # Try time_zone method
    return result.time_zone if result.respond_to?(:time_zone) && result.time_zone.present?

    nil
  end

  # Find ActiveSupport timezone by name
  #
  # @param timezone_name [String] Timezone name (e.g., "Asia/Tokyo")
  # @return [ActiveSupport::TimeZone, nil] Timezone or nil
  #
  def find_timezone(timezone_name)
    # Direct lookup
    zone = ActiveSupport::TimeZone[timezone_name]
    return zone if zone

    # Search through all zones by tzinfo name
    ActiveSupport::TimeZone.all.find do |z|
      z.tzinfo.name.downcase == timezone_name.downcase
    end
  end

  # Format UTC offset in human-readable form
  #
  # @param offset_seconds [Integer] Offset in seconds
  # @return [String] Formatted offset (e.g., "+09:00", "-05:00")
  #
  def format_offset(offset_seconds)
    hours, remainder = offset_seconds.abs.divmod(3600)
    minutes = remainder / 60
    sign = offset_seconds >= 0 ? "+" : "-"
    format("%s%02d:%02d", sign, hours, minutes)
  end
end
