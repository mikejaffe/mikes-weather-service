# Geocoder configuration
# SSL fix is handled in 00_openssl_fix.rb initializer

Geocoder.configure(
  # Geocoding options
  timeout: 3,                 # geocoding service timeout (secs)
  lookup: :nominatim,         # name of geocoding service (symbol)
  ip_lookup: :ipinfo_io,      # name of IP address geocoding service (symbol)
  language: :en,              # ISO-639 language code
  use_https: true,            # use HTTPS for lookup requests

  # HTTP options
  http_headers: { "User-Agent" => "WeatherApp/1.0" }, # Required by Nominatim

  # Cache configuration
  cache: nil,                 # cache object (must respond to #[], #[]=, and #del)

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  units: :mi                  # :km for kilometers or :mi for miles
)
