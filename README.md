# Zip Forecast

A Ruby on Rails application that accepts an address, resolves its ZIP/postal code, retrieves weather forecast information, and caches forecast results for 30 minutes by ZIP code.

## Features

- Accepts a user-provided address
- Resolves ZIP/postal code via geocoding
- Retrieves current weather forecast
- Displays:
  - Current temperature
  - Daily high
  - Daily low
  - Weather condition
- Caches forecast data for 30 minutes by ZIP code
- Indicates whether the displayed result was served from cache
- Handles invalid addresses and external API failures gracefully
- Automated test coverage for core application flow

---

## Tech Stack

- Ruby 3.2.5
- Rails 7.1.5
- PostgreSQL
- Faraday
- RSpec
- Rails Memory Cache

---

## Architecture

The application follows a service-oriented design to keep controllers lean and responsibilities isolated.

## Service Responsibilities

### ForecastFetcher
Orchestrates the forecast retrieval flow:
- resolves ZIP code
- checks cache
- fetches weather data if cache miss
- normalizes response

### Geocoding::Client
Responsible for HTTP communication with the geocoding provider.

### Geocoding::AddressResolver
Extracts ZIP/postal code from geocoding responses.

### Weather::Client
Responsible for HTTP communication with the weather provider.

---
### Live Demo: https://zip-forecast-6rup.onrender.com/
Note: Cache behavior in the live demo may occasionally reset due to hosting platform restarts (free plan)

## Setup

### Clone repository

```bash
git clone https://github.com/strublic/zip_forecast.git
cd zip_forecast
```

---

### Install dependencies

```bash
bundle install
```

---

### Environment variables

Create:

```bash
cp .env.example .env
```

Set:

```env
WEATHER_API_KEY=your_api_key_here
```

Weather API provider:

https://www.weatherapi.com

---

### Database setup

```bash
rails db:create
```

---

### Run application

```bash
rails server
```

Open:

```text
http://localhost:3000
```

---

## Running tests

```bash
bundle exec rspec
```

---

## Caching Strategy

Forecast data is cached by ZIP code for 30 minutes:

```ruby
forecast:ZIP_CODE
```

Example:

```ruby
forecast:90210
```

This ensures repeated requests for the same ZIP avoid unnecessary weather API calls.

For simplicity, Rails in-memory caching is used.

In a production environment, Redis would be a more appropriate distributed cache solution.

---

## Error Handling

Handled scenarios:

- invalid address
- address without ZIP/postal code
- weather API failure
- geocoding API failure
- request timeout

User-friendly messages are displayed instead of generic server errors.

---

## Design Decisions / Trade-offs

### Why explicit HTTP clients instead of gems?
Using explicit Faraday clients provides:
- explicit timeout handling
- clearer error handling
- explicit API integration logic
- easier debugging
- simpler response normalization

### Why Rails memory cache?
Chosen as a lightweight caching solution to minimize infrastructure complexity.

A production implementation would likely use Redis.

### Why explicit geocoding integration?
An explicit integration with OpenStreetMap's Nominatim API via Faraday was chosen over higher-level abstractions to provide better control, reliability, and clearer error handling.

This approach provides:
- full control over request configuration
- explicit timeout handling
- predictable response parsing
- clearer debugging when external services behave unexpectedly

### Why WeatherAPI?
WeatherAPI offers:
- simple integration
- reliable ZIP/postal code forecast lookup
- clean response structure
- forecast and current weather support in a single endpoint

### Why ZIP-based caching?
Caching is performed by ZIP/postal code rather than raw address input because:
- multiple address variations can resolve to the same ZIP code
- it reduces unnecessary external API calls
- it aligns with the forecast lookup strategy

### Why no database persistence?
This project does not require historical storage or persistence of user data.

PostgreSQL is used only as the Rails application database dependency.

---

## Future Improvements

- Turbo-powered partial page updates
- Redis cache backend
- stronger API response validation
- loading states
- improved UI styling
- Docker support

---

## Assumptions

- A valid address should resolve to a ZIP/postal code
- Weather data is retrieved using ZIP-based lookup
- External APIs are available during execution
