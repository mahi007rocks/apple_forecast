require "rails_helper"

RSpec.describe Geocoding::AddressLookup do
  subject(:lookup_service) { described_class.new(geocoder: geocoder) }

  let(:geocoder) { class_double("Geocoder") }
  let(:location) { stub_geocoder_result }

  describe "#lookup" do
    it "returns structured location data" do
      allow(geocoder).to receive(:search).with("Cupertino").and_return([location])

      result = lookup_service.lookup("Cupertino")

      expect(result.postal_code).to eq("95014")
      expect(result.latitude).to eq(37.3349)
      expect(result.longitude).to eq(-122.0090)
      expect(result.timezone).to eq("America/Los_Angeles")
    end

    it "raises an error when the address cannot be geocoded" do
      allow(geocoder).to receive(:search).and_return([])

      expect { lookup_service.lookup("unknown") }.to raise_error(described_class::Error, /Unable to geocode/)
    end

    it "raises an error when no postal code is available" do
      allow(location).to receive(:postal_code).and_return(nil)
      allow(location).to receive(:data).and_return({})
      allow(geocoder).to receive(:search).and_return([location])

      expect { lookup_service.lookup("Cupertino") }.to raise_error(described_class::Error, /postal code/)
    end

    it "raises an error when the address is blank" do
      expect { lookup_service.lookup("") }.to raise_error(described_class::Error, /required/)
    end
  end
end
