Rails.application.routes.draw do
  root "forecasts#new"
  resource :forecast, only: [:create, :show]
end
