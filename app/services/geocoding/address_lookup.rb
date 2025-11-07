module Geocoding
  class AddressLookup
    Result = Struct.new(:latitude, :longitude, :postal_code, :normalized_address, :timezone, keyword_init: true)

    class Error < StandardError; end

    def initialize(geocoder: Geocoder)
      @geocoder = geocoder
    end

    def lookup(address)
      raise Error, "Address is required" if address.blank?

      location = geocoder.search(address).first
      raise Error, "Unable to geocode address" if location.nil?

      postal_code = location.postal_code || location.data["postal_code"]
      raise Error, "No postal code found for address" if postal_code.blank?

      Result.new(
        latitude: location.latitude,
        longitude: location.longitude,
        postal_code: postal_code,
        normalized_address: location.address,
        timezone: location.data["timezone"] || "auto"
      )
    rescue Timeout::Error
      raise Error, "Geocoding timed out"
    rescue StandardError => e
      raise Error, e.message
    end

    private

    attr_reader :geocoder
  end
end
