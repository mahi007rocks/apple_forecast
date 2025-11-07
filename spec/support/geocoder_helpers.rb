module GeocoderTestHelpers
  class MockGeocoderResult
    attr_reader :latitude, :longitude, :postal_code, :address, :data

    def initialize(options = {})
      defaults = {
        latitude: 37.3349,
        longitude: -122.0090,
        postal_code: "95014",
        address: "1 Apple Park Way, Cupertino, CA 95014",
        data: { "timezone" => "America/Los_Angeles" }
      }

      options = defaults.merge(options)
      @latitude = options[:latitude]
      @longitude = options[:longitude]
      @postal_code = options[:postal_code]
      @address = options[:address]
      @data = options[:data]
    end
  end

  def stub_geocoder_result(options = {})
    MockGeocoderResult.new(options)
  end
end

RSpec.configure do |config|
  config.include GeocoderTestHelpers
end