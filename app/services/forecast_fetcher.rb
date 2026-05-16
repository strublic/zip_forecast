class ForecastFetcher
  def self.call(address)
    new(address).call
  end

  def initialize(address)
    @address = address
  end

  def call
    zip = Geocoding::AddressResolver.call(@address)
    {
      zip: zip,
      current_temp: 22,
      high: 26,
      low: 18,
      condition: 'Sunny',
      from_cache: false
    }
  end
end
