require "date"

class ForecastViewModel
  attr_reader :address

  def initialize(result)
    @address = result.location.normalized_address
    @forecast = result.forecast
    @cached = result.cached
    @location_timezone = result.location.timezone
  end

  def cached?
    @cached
  end

  def current_temperature
    format_temperature(@forecast[:current_temperature])
  end

  def high_temperature
    format_temperature(@forecast[:high_temperature])
  end

  def low_temperature
    format_temperature(@forecast[:low_temperature])
  end

  def fetched_at
    timestamp = @forecast[:fetched_at]
    zoned_time(timestamp || Time.zone.now).strftime("%B %d, %Y %I:%M %p %Z")
  end

  def daily_forecast
    Array(@forecast[:daily]).map do |day|
      {
        date: format_date(day[:date]),
        high: format_temperature(day[:high]),
        low: format_temperature(day[:low])
      }
    end
  end

  private

  def format_temperature(value)
    return "–" if value.nil?

    format("%.1f°F", value)
  end

  def format_date(value)
    case value
    when Date
      value.strftime("%a, %b %d")
    when String
      begin
        Date.parse(value).strftime("%a, %b %d")
      rescue ArgumentError
        value
      end
    else
      value.to_s
    end
  end

  def zoned_time(time)
    zone = resolve_time_zone
    zone ? time.in_time_zone(zone) : time.in_time_zone
  end

  def resolve_time_zone
    return @resolved_time_zone if defined?(@resolved_time_zone)

    @resolved_time_zone = ActiveSupport::TimeZone[@location_timezone]
  end
end
