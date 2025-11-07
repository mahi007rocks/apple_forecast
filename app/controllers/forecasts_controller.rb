class ForecastsController < ApplicationController
  def new
    @form = ForecastForm.new
  end

  def create
    @form = ForecastForm.new(forecast_params)
    if @form.valid?
      result = forecast_service.call(@form.address)
      @view_model = ForecastViewModel.new(result)
      flash.now[:notice] = t("forecasts.form.cache_notice") if @view_model.cached?
      render :show
    else
      flash.now[:alert] = t("forecasts.form.error")
      render :new, status: :unprocessable_entity
    end
  rescue Weather::ForecastService::Error => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def show
    render :show
  end

  private

  def forecast_params
    params.require(:forecast).permit(:address)
  end

  def forecast_service
    @forecast_service ||= Weather::ForecastService.new
  end
end
