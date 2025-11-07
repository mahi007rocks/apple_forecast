require "rails_helper"

RSpec.describe ForecastViewModel do
  let(:location) do
    Geocoding::AddressLookup::Result.new(
      latitude: 0,
      longitude: 0,
      postal_code: "95014",
      normalized_address: "Cupertino, CA",
      timezone: "America/Los_Angeles"
    )
  end

  let(:forecast_data) do
    {
      current_temperature: 68.25,
      high_temperature: 72.5,
      low_temperature: 55.4,
      daily: [
        { date: Date.new(2024, 5, 1), high: 72.5, low: 55.4 }
      ],
      fetched_at: Time.zone.parse("2024-05-01T10:00:00Z")
    }
  end

  let(:result) { Weather::ForecastService::Result.new(forecast: forecast_data, location: location, cached: true) }

  subject(:view_model) { described_class.new(result) }

  it "formats temperatures with units" do
    expect(view_model.current_temperature).to eq("68.3°F")
    expect(view_model.high_temperature).to eq("72.5°F")
    expect(view_model.low_temperature).to eq("55.4°F")
  end

  it "exposes cached flag" do
    expect(view_model.cached?).to be(true)
  end

  it "formats daily entries" do
    day = view_model.daily_forecast.first
    expect(day[:date]).to include("May")
  end

  it "renders the fetched timestamp in the location timezone" do
    expect(view_model.fetched_at).to include("PDT")
  end

  context "when the location timezone is unknown" do
    let(:location) do
      Geocoding::AddressLookup::Result.new(
        latitude: 0,
        longitude: 0,
        postal_code: "95014",
        normalized_address: "Cupertino, CA",
        timezone: "auto"
      )
    end

    it "falls back to the application timezone" do
      expect(view_model.fetched_at).to include("UTC")
    end
  end
end
