module Weather
  class ForecastService
    Result = Struct.new(:forecast, :location, :cached, keyword_init: true)

    CACHE_TTL = 30.minutes

    class Error < StandardError; end

    def initialize(address_lookup: Geocoding::AddressLookup.new,
                   client: ForecastClient.new,
                   cache: Rails.cache)
      @address_lookup = address_lookup
      @client = client
      @cache = cache
    end

    def call(address)
      location = address_lookup.lookup(address)
      cache_key = cache_key_for(location.postal_code)

      cached_payload = cache.read(cache_key)
      return Result.new(forecast: cached_payload, location: location, cached: true) if cached_payload.present?

      forecast = client.fetch(latitude: location.latitude, longitude: location.longitude, timezone: location.timezone)
      payload = serialize_forecast(forecast)
      cache.write(cache_key, payload, expires_in: CACHE_TTL)

      Result.new(forecast: payload, location: location, cached: false)
    rescue Geocoding::AddressLookup::Error => e
      raise Error, e.message
    rescue ForecastClient::Error => e
      raise Error, e.message
    end

    private

    attr_reader :address_lookup, :client, :cache

    def cache_key_for(postal_code)
      "weather-forecast/#{postal_code}"
    end

    def serialize_forecast(forecast)
      {
        current_temperature: forecast.current_temperature,
        high_temperature: forecast.high_temperature,
        low_temperature: forecast.low_temperature,
        daily: forecast.daily,
        fetched_at: forecast.fetched_at
      }
    end
  end
end
