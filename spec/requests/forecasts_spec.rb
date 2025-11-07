require "rails_helper"

RSpec.describe "Forecast Flow", type: :request do
  describe "GET /" do
    it "renders the forecast form" do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("forecasts.new.title"))
    end
  end

  describe "POST /forecast" do
    context "with valid address" do
      let(:forecast_params) { { forecast: { address: "Cupertino" } } }
      
      before do
        mock_forecast_service(address: "Cupertino")
      end

      it "shows the forecast" do
        post forecast_path, params: forecast_params
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Cupertino, CA")
      end
    end

    context "with blank address" do
      let(:forecast_params) { { forecast: { address: "" } } }

      it "shows validation errors" do
        post forecast_path, params: forecast_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(I18n.t("forecasts.form.error"))
      end
    end

    context "when forecast service fails" do
      before do
        allow_any_instance_of(Weather::ForecastService).to receive(:call)
          .and_raise(Weather::ForecastService::Error, "Service unavailable")
      end

      it "shows service error" do
        post forecast_path, params: { forecast: { address: "Invalid" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Service unavailable")
      end
    end
  end
end
