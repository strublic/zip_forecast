class ForecastFetcher
  def self.call(address)
    new(address).call
  end

  def initialize(address)
    @address = address
    @weather_client = Weather::Client.new
  end

  def call
    zip = Geocoding::AddressResolver.call(@address)
    weather = @weather_client.current(zip)

    {
      zip: zip,
      current_temp: weather.dig('current', 'temp_c'),
      high: weather.dig('forecast', 'forecastday', 0, 'day', 'maxtemp_c'),
      low: weather.dig('forecast', 'forecastday', 0, 'day', 'mintemp_c'),
      condition: weather.dig('current', 'condition', 'text'),
      from_cache: false
    }
  end
end
