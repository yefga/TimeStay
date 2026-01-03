# frozen_string_literal: true

# Geocoder Configuration
# ======================
# This file configures the Geocoder gem for IP-based timezone detection.
#
# The default lookup service is ipinfo.io, which provides:
# - Free tier with 50,000 requests/month
# - Timezone information included in responses
# - No API key required for basic usage
#
# For production with higher traffic, consider:
# - Adding an API key for higher rate limits
# - Using a different provider with an API key

Geocoder.configure(
  # IP address geocoding service
  # ipinfo_io provides timezone data in free tier
  ip_lookup: :ipinfo_io,

  # Timeout settings (in seconds)
  timeout: 3,

  # Cache settings (optional, but recommended for production)
  # Uncomment and configure if you want to cache results
  # cache: Redis.new,
  # cache_prefix: "geocoder:",

  # Use HTTPS for API requests
  use_https: true,

  # Units for distance calculations (not used for IP lookup, but good default)
  units: :km
)
