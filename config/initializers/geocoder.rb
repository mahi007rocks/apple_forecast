if defined?(Geocoder)
  Geocoder.configure(
    timeout: 5,
    lookup: ENV.fetch("GEOCODER_LOOKUP", :nominatim).to_sym,
    units: :mi
  )

  if Rails.env.test?
    Geocoder::Lookup::Test.set_default_stub([
      {
        "coordinates" => [37.3349, -122.0090],
        "address" => "1 Apple Park Way, Cupertino, CA 95014",
        "state" => "California",
        "state_code" => "CA",
        "country" => "United States",
        "country_code" => "US",
        "postal_code" => "95014"
      }
    ])
  end
end
