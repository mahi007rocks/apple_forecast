require "rails_helper"

RSpec.describe Weather::ForecastService do
  subject(:service) do
    described_class.new(address_lookup: address_lookup, client: client, cache: cache)
  end

  let(:address_lookup) { instance_double(Geocoding::AddressLookup) }
  let(:client) { instance_double(Weather::ForecastClient) }
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:location) do
    Geocoding::AddressLookup::Result.new(
      latitude: 37.3349,
      longitude: -122.0090,
      postal_code: "95014",
      normalized_address: "1 Apple Park Way, Cupertino, CA 95014",
      timezone: "America/Los_Angeles"
    )
  end

  let(:forecast) do
    Weather::ForecastClient::Forecast.new(
      current_temperature: 68.3,
      high_temperature: 70.0,
      low_temperature: 60.0,
      daily: [
        { date: Date.new(2024, 5, 1), high: 70.0, low: 60.0 }
      ],
      fetched_at: Time.zone.parse("2024-05-01T17:00:00Z")
    )
  end

  describe "#call" do
    it "stores forecast results in the cache" do
      expect(address_lookup).to receive(:lookup).with("Cupertino").and_return(location)
      expect(client).to receive(:fetch).and_return(forecast)

      result = service.call("Cupertino")

      expect(result.cached).to be(false)
      expect(cache.read("weather-forecast/95014")).to include(:current_temperature)
    end

    it "reads from the cache on subsequent requests" do
      cache.write("weather-forecast/95014", { current_temperature: 68 })
      allow(address_lookup).to receive(:lookup).and_return(location)

      result = service.call("Cupertino")

      expect(result.cached).to be(true)
      expect(result.forecast[:current_temperature]).to eq(68)
    end

    it "surfaces geocoding errors" do
      allow(address_lookup).to receive(:lookup).and_raise(Geocoding::AddressLookup::Error, "boom")

      expect { service.call("bad") }.to raise_error(described_class::Error, "boom")
    end

    it "surfaces forecast errors" do
      allow(address_lookup).to receive(:lookup).and_return(location)
      allow(client).to receive(:fetch).and_raise(Weather::ForecastClient::Error, "down")

      expect { service.call("Cupertino") }.to raise_error(described_class::Error, "down")
    end
  end
end
