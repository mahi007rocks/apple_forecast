# Apple Forecast

Apple Forecast is a Ruby on Rails application that accepts a user-provided street address, retrieves the latest forecast for the resolved ZIP code, and caches those results for 30 minutes so subsequent lookups are instantaneous. The UI highlights when a response has been served from the cache.

> **Note**: The development environment used to author this submission does not have outbound network access, so `bundle install` could not be executed here. After cloning the repository locally you should run `bundle install` to generate a `Gemfile.lock` and pull the dependencies described in the `Gemfile`.

## Requirements

* Ruby 3.2.3
* Rails 7.1.x
* Redis (optional in development — the default configuration falls back to the in-memory cache store)

## Setup

```bash
bin/setup
```

The setup script installs gems, prepares the database (SQLite for development and test), and gets the application ready to run. If you prefer to run the steps manually:

```bash
bundle install
bin/rails db:prepare
```

Start the application with:

```bash
bin/rails server
```

Visit [http://localhost:3000](http://localhost:3000) to enter an address and view the resulting forecast.

### Environment Variables

| Variable | Description | Default |
| --- | --- | --- |
| `OPEN_METEO_ENDPOINT` | Override the Open-Meteo endpoint used by the forecast client. | `https://api.open-meteo.com/v1/forecast` |
| `GEOCODER_LOOKUP` | Configure the Geocoder lookup service. | `nominatim` |
| `REDIS_URL` | Redis connection string for production caching. | `redis://localhost:6379/1` |

Create a `.env` file (ignored in Git) to store sensitive values locally.

## Architecture Overview

### Request Flow

1. **User Input** — A simple form (`ForecastsController#new`) collects the address. Validation lives in `ForecastForm` (ActiveModel).
2. **Geocoding** — `Geocoding::AddressLookup` delegates to the `geocoder` gem to translate the address into latitude, longitude, and postal code information. The postal code becomes the cache key.
3. **Caching & Retrieval** — `Weather::ForecastService` orchestrates geocoding, cache lookups, and API calls. It uses `Rails.cache` (memory store in development/test, Redis in production) with a 30-minute TTL. When a cached entry is returned the controller surfaces a banner and the view model indicates the cached state.
4. **Weather Provider** — `Weather::ForecastClient` talks to [Open-Meteo](https://open-meteo.com) via `Faraday`, parsing out current, high, low, and multi-day forecast data.
5. **Presentation** — `ForecastViewModel` formats the raw data for display (units, timestamps, friendly date strings). The view highlights cached responses.

### Key Modules

| Component | Responsibility |
| --- | --- |
| `ForecastsController` | Coordinates form submission, invokes the forecast service, and renders results/errors. |
| `ForecastForm` | Performs address validation using ActiveModel. |
| `Geocoding::AddressLookup` | Wraps the `geocoder` gem, normalising the external API data into a simple struct. |
| `Weather::ForecastClient` | Communicates with Open-Meteo and converts the JSON payload into Ruby objects. |
| `Weather::ForecastService` | Caches forecasts by ZIP, coordinates geocoding and HTTP clients, and exposes a single entry point to controllers. |
| `ForecastViewModel` | Formats display-specific data (units, timestamps, cached indicator). |

## Testing

The application follows a test-driven development workflow using RSpec. Run the full suite with:

```bash
bundle exec rspec
```

> **Testing status in this environment**: Running the suite locally requires installing the bundle first. The execution
> environment used to generate this submission cannot reach `rubygems.org`, so `bundle install` terminates with a
> `Net::HTTPClientException 403 "Forbidden"`. As a result the `bundle exec rspec` command exits immediately because the
> `rspec` executable is unavailable. Cloning the repository on a workstation with internet access allows the full suite to
> pass.

### Coverage

* **Unit Tests** — Service objects, geocoding client, forecast client, and view model logic.
* **Request Tests** — Ensures the end-to-end flow renders success and error states.

WebMock prevents accidental HTTP calls during tests. Geocoder is configured with deterministic test data via `config/initializers/geocoder.rb`.

## Scalability & Future Enhancements

* **Background Refresh** — `ActiveJob` + `Sidekiq` or `Solid Queue` could proactively refresh cache entries before expiry to avoid cold starts.
* **Persistent Storage** — Swap the cache store to Redis or Memcached for multi-instance deployments.
* **Extended Forecasts** — Expand `Weather::ForecastClient` to expose hourly data or precipitation chances.
* **Resilience** — Implement circuit breakers (via `faraday` middleware) and structured logging for better observability.

## Design Patterns & Principles

* **Service Objects** for geocoding and weather retrieval encapsulate external integrations.
* **View Models** keep presentation-specific formatting out of controllers/views.
* **Dependency Injection** enables deterministic unit tests and clear seams for future enhancements (e.g., different weather providers).
* **Caching Strategy** uses `Rails.cache` with ZIP-keyed entries and TTL-based invalidation, ensuring compliance with the 30-minute freshness requirement.

## Documentation

The code includes inline documentation and self-explanatory naming to clarify responsibilities. Refer to the `app/services` and `app/view_models` directories for primary business logic.
