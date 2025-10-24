# Service class for fetching weather data from the Open-Meteo API
#
# == Usage
#   WeatherService.get_weather("123 Main St")
#   WeatherService.get_weather("90210", false) # Skip caching
#
# == Returns
# Hash containing:
# * :temperature - Current temperature in Fahrenheit
# * :high - Daily high temperature
# * :low - Daily low temperature
# * :forecast - 7-day forecast data
# * :postal_code - Location postal code if available
# * :cached - Whether result was from cache
# * :error - Error message if request failed
#
# == Errors
# Raises error if:
# * Address cannot be geocoded
# * Weather API request fails

class WeatherService
  WEATHER_API_URL = "https://api.open-meteo.com/v1/forecast?current=temperature_2m&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit&forecast_days=7"

  class << self
    def get_weather(address, with_cache = true)
      return nil if address.blank?

      error = nil
      cached = false

      begin
        # Get zip code first
        location = Geocoder.search(address).first
        raise "Geocoding Error: #{address} not found" if location.nil?

        postal_code = location.postal_code
        cache_key = if postal_code.present?
                      "weather:#{postal_code}"
        elsif location.latitude.present? && location.longitude.present?
                      "weather:#{location.latitude.round(2)}:#{location.longitude.round(2)}"
        else
          raise "Geocoding Error: #{address} not found with latitude and longitude"
        end


        # Try to fetch from cache (30 minute)
        if with_cache
          cached = Rails.cache.exist?(cache_key)
          weather_data = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
            fetch_weather_data(location)
          end
        else
          weather_data = fetch_weather_data(location)
        end
        weather_data.merge(address: address, cached: cached)
      rescue => e
        { error: "Weather API Error: #{e.message}", cached: false }
      end
    end

    private

    def fetch_weather_data(location)
      lat = location.latitude
      lon = location.longitude
      postal_code = location.postal_code

      url = "#{WEATHER_API_URL}&latitude=#{lat}&longitude=#{lon}"
      response = Net::HTTP.get_response(URI(url))

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        {
          postal_code: postal_code,
          temperature: data.dig("current", "temperature_2m"),
          high: data.dig("daily", "temperature_2m_max", 0),
          low: data.dig("daily", "temperature_2m_min", 0),
          forecast: data["daily"]
        }
      else
        raise "#{response.code} - #{response.message}"
      end
    end
  end
end
