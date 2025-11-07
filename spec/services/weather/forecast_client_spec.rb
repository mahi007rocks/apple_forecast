require "rails_helper"
require "json"

RSpec.describe Weather::ForecastClient do
  subject(:client) { described_class.new(http: http) }

  let(:http) { instance_double(Faraday::Connection) }

  describe "#fetch" do
    it "parses the response body" do
      response_body = {
        "current" => { "temperature_2m" => 68.3, "time" => "2024-05-01T10:00" },
        "daily" => {
          "time" => ["2024-05-01", "2024-05-02"],
          "temperature_2m_max" => [70.0, 72.5],
          "temperature_2m_min" => [60.0, 58.5]
        }
      }.to_json
      response = instance_double(Faraday::Response, success?: true, status: 200, body: response_body)
      expect(http).to receive(:get).and_return(response)

      forecast = client.fetch(latitude: 37.3349, longitude: -122.0090)

      expect(forecast.current_temperature).to eq(68.3)
      expect(forecast.high_temperature).to eq(70.0)
      expect(forecast.low_temperature).to eq(60.0)
      expect(forecast.daily.length).to eq(2)
    end

    it "raises an error when the service fails" do
      response = instance_double(Faraday::Response, success?: false, status: 500)
      allow(http).to receive(:get).and_return(response)

      expect do
        client.fetch(latitude: 0, longitude: 0)
      end.to raise_error(described_class::Error, /Weather service returned 500/)
    end

    it "raises an error when JSON is invalid" do
      response = instance_double(Faraday::Response, success?: true, status: 200, body: "not-json")
      allow(http).to receive(:get).and_return(response)

      expect { client.fetch(latitude: 0, longitude: 0) }.to raise_error(described_class::Error, /malformed/)
    end
  end
end
