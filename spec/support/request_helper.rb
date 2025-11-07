module RequestHelper
  def mock_forecast_service(address: "Cupertino", result: nil)
    result ||= Weather::ForecastService::Result.new(
      forecast: {
        current_temperature: 68.3,
        high_temperature: 70.0,
        low_temperature: 60.0,
        daily: [],
        fetched_at: Time.zone.now
      },
      location: Geocoding::AddressLookup::Result.new(
        latitude: 0,
        longitude: 0,
        postal_code: "95014",
        normalized_address: "Cupertino, CA",
        timezone: "America/Los_Angeles"
      ),
      cached: false
    )

    allow_any_instance_of(Weather::ForecastService).to receive(:call)
      .with(address)
      .and_return(result)
  end
end

RSpec.configure do |config|
  config.include RequestHelper, type: :request
end