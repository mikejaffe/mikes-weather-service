require 'rails_helper'

RSpec.describe "Homes", type: :request do
  let(:mock_location) do
    double(
      latitude: 40.7128,
      longitude: -74.0060,
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

  describe "GET /index" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "returns weather data for a valid address" do
      allow(Geocoder).to receive(:search).with("New York, NY").and_return([ mock_location ])
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

      get root_path, params: { address: "New York, NY" }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("New York, NY")
      expect(response.body).to include("Temperature: 72.5°F")
      expect(response.body).to include("High: 75.2°F")
      expect(response.body).to include("Low: 62.1°F")
      expect(response.body).to include("Weekly Forecast:")
      expect(response.body).to include("Monday, January 01: High 75.2°F - Low 62.1°F")
      expect(response.body).to include("Tuesday, January 02: High 74.1°F - Low 61.8°F")
      expect(response.body).to include("Wednesday, January 03: High 73.8°F - Low 60.9°F")
      expect(response.body).to include("Thursday, January 04: High 72.9°F - Low 61.2°F")
      expect(response.body).to include("Friday, January 05: High 74.3°F - Low 62.4°F")
      expect(response.body).to include("Saturday, January 06: High 75.0°F - Low 61.7°F")
      expect(response.body).to include("Sunday, January 07: High 73.6°F - Low 60.8°F")
      expect(response.body).to include("Cached: Yes")
    end

    it "returns error when geocoding fails" do
      allow(Geocoder).to receive(:search).with("Invalid Address").and_return([])

      get root_path, params: { address: "Invalid Address" }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Geocoding Error")
    end

    it "returns error when weather API fails" do
      allow(Geocoder).to receive(:search).with("New York, NY").and_return([ mock_location ])
      stub_request(:get, /api.open-meteo.com/)
        .to_return(status: 500, body: "Server Error")

      get root_path, params: { address: "New York, NY" }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Weather API Error")
    end

    it "returns nil for blank address" do
      get root_path, params: { address: "" }
      expect(response).to have_http_status(:success)
      expect(response.body).not_to include("Weather API Error")
    end
  end
end
