require 'rails_helper'

RSpec.describe WeatherService do
  describe '.get_weather' do
    let(:mock_location) do
      double(
        latitude: 40.7127753,
        longitude: -74.0059728,
        postal_code: "10007"
      )
    end

    let(:mock_weather_response) do
      {
        "current" => {
          "temperature_2m" => 72.5
        },
        "daily" => {
          "temperature_2m_max" => [ 75.2, 74.1, 73.8, 72.9, 74.3, 75.0, 73.6 ],
          "temperature_2m_min" => [ 62.1, 61.8, 60.9, 61.2, 62.4, 61.7, 60.8 ],
          "time" => [ "2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04", "2024-01-05", "2024-01-06", "2024-01-07" ]
        }
      }.to_json
    end

    before do
      allow(Geocoder).to receive(:search).with("New York, NY").and_return([ mock_location ])

      stub_request(:get, /api.open-meteo.com/)
        .to_return(status: 200, body: mock_weather_response)
    end

    it 'returns weather data for a valid address' do
      result = WeatherService.get_weather("New York, NY")

      expect(result[:postal_code]).to eq("10007")
      expect(result[:temperature]).to eq(72.5)
      expect(result[:high]).to eq(75.2)
      expect(result[:low]).to eq(62.1)
      expect(result[:forecast]).to be_present
      expect(result[:error]).to be_nil
    end

    it 'uses cache when available' do
      allow(Rails.cache).to receive(:exist?).with("weather:10007").and_return(true)
      allow(Rails.cache).to receive(:fetch).with("weather:10007", expires_in: 30.minutes).and_return(
        {
          postal_code: "10007",
          temperature: 72.5,
          high: 75.2,
          low: 62.1,
          forecast: JSON.parse(mock_weather_response)["daily"]
        }
      )

      result = WeatherService.get_weather("New York, NY")
      expect(result[:cached]).to be true
    end

    it 'returns error when geocoding fails' do
      allow(Geocoder).to receive(:search).with("Invalid Address").and_return([])

      result = WeatherService.get_weather("Invalid Address")
      expect(result[:error]).to include("Geocoding Error")
    end

    it 'returns error when weather API fails' do
      stub_request(:get, /api.open-meteo.com/)
        .to_return(status: 500, body: "Server Error")

      result = WeatherService.get_weather("New York, NY")
      expect(result[:error]).to include("Weather API Error")
    end

    it 'returns nil for blank address' do
      expect(WeatherService.get_weather("")).to be_nil
    end
  end
end
