require "rails_helper"

RSpec.describe "Forecasts", type: :request do
  describe "POST /forecast" do
    it "renders the forecast when the service succeeds" do
      allow_any_instance_of(Weather::ForecastService).to receive(:call).and_return(
        Weather::ForecastService::Result.new(
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
      )

      post "/forecast", params: { forecast: { address: "Cupertino" } }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cupertino, CA")
    end

    it "renders the form with errors when the address is blank" do
      post "/forecast", params: { forecast: { address: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(I18n.t("forecasts.form.error"))
    end
  end
end
