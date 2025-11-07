class ForecastForm
  include ActiveModel::Model

  attr_accessor :address

  validates :address, presence: true
end
