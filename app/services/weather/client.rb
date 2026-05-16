module Weather
  class Client
    BASE_URL = 'https://api.weatherapi.com'.freeze

    def current(zip)
      response = connection.get('/v1/forecast.json') do |req|
        req.params['key'] = ENV.fetch('WEATHER_API_KEY')
        req.params['q'] = zip
        req.params['days'] = 1
        req.params['aqi'] = 'no'
        req.params['alerts'] = 'no'
      end

      JSON.parse(response.body)
    end

    private

    def connection
      Faraday.new(url: BASE_URL) do |faraday|
        faraday.options.timeout = 5
      end
    end
  end
end
