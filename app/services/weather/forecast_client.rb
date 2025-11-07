require "json"
require "faraday"

module Weather
  class ForecastClient
    API_ENDPOINT = "https://api.open-meteo.com/v1/forecast".freeze

    class Error < StandardError; end

    Forecast = Struct.new(
      :current_temperature,
      :high_temperature,
      :low_temperature,
      :daily,
      :fetched_at,
      keyword_init: true
    )

    def initialize(http: default_connection)
      @http = http
    end

    def fetch(latitude:, longitude:, timezone: "auto")
      response = http.get("", query(latitude, longitude, timezone))
      raise Error, "Weather service returned #{response.status}" unless response.success?

      payload = parse_body(response.body)
      Forecast.new(
        current_temperature: payload.dig("current", "temperature_2m"),
        high_temperature: payload.dig("daily", "temperature_2m_max")&.first,
        low_temperature: payload.dig("daily", "temperature_2m_min")&.first,
        daily: build_daily(payload),
        fetched_at: parse_time(payload.dig("current", "time"))
      )
    rescue Faraday::TimeoutError
      raise Error, "Weather service timed out"
    rescue Faraday::ConnectionFailed
      raise Error, "Weather service unavailable"
    rescue JSON::ParserError
      raise Error, "Weather service returned malformed data"
    end

    private

    attr_reader :http

    def default_connection
      endpoint = ENV.fetch("OPEN_METEO_ENDPOINT", API_ENDPOINT)
      Faraday.new(endpoint) do |config|
        config.options.timeout = 5
        config.adapter Faraday.default_adapter
      end
    end

    def query(latitude, longitude, timezone)
      {
        latitude: latitude,
        longitude: longitude,
        current: "temperature_2m",
        daily: "temperature_2m_max,temperature_2m_min",
        timezone: timezone
      }
    end

    def parse_body(body)
      JSON.parse(body)
    end

    def parse_time(raw_time)
      return Time.zone.now if raw_time.blank?

      Time.zone.parse(raw_time)
    rescue ArgumentError
      Time.zone.now
    end

    def build_daily(payload)
      times = payload.dig("daily", "time") || []
      highs = payload.dig("daily", "temperature_2m_max") || []
      lows = payload.dig("daily", "temperature_2m_min") || []
      times.each_with_index.map do |time, index|
        {
          date: Time.zone.parse(time).to_date,
          high: highs[index],
          low: lows[index]
        }
      rescue ArgumentError
        {
          date: time,
          high: highs[index],
          low: lows[index]
        }
      end
    end
  end
end
