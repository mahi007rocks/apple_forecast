require "rails_helper"

RSpec.describe ForecastForm do
  it "is invalid without an address" do
    form = described_class.new(address: "")

    expect(form).not_to be_valid
    expect(form.errors[:address]).to include("can't be blank")
  end

  it "is valid with an address" do
    form = described_class.new(address: "Cupertino")

    expect(form).to be_valid
  end
end
