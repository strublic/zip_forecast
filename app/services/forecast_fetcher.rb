class ForecastFetcher
  CACHE_TTL = 30.minutes

  def self.call(address)
    new(address).call
  end

  def initialize(address)
    @address = address
    @weather_client = Weather::Client.new
  end

  def call
    zip = Geocoding::AddressResolver.call(@address)
    cache_key = "forecast:#{zip}"

    cached = Rails.cache.read(cache_key)

    if cached.present?
      cached.merge(from_cache: true)
    else
      forecast = fetch_forecast(zip)

      Rails.cache.write(cache_key, forecast, expires_in: CACHE_TTL)

      forecast.merge(from_cache: false)
    end
  end

  private

  def fetch_forecast(zip)
    weather = @weather_client.current(zip)

    {
      zip: zip,
      current_temp: weather.dig('current', 'temp_c'),
      high: weather.dig('forecast', 'forecastday', 0, 'day', 'maxtemp_c'),
      low: weather.dig('forecast', 'forecastday', 0, 'day', 'mintemp_c'),
      condition: weather.dig('current', 'condition', 'text')
    }
  end
end
