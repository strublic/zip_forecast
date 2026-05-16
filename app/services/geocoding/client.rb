module Geocoding
  class Client
    BASE_URL = 'https://nominatim.openstreetmap.org'.freeze

    def search(address)
      response = connection.get('/search') do |req|
        req.params['q'] = address
        req.params['format'] = 'json'
        req.params['addressdetails'] = 1
      end

      JSON.parse(response.body)
    end

    private

    def connection
      Faraday.new(url: BASE_URL) do |faraday|
        faraday.headers['User-Agent'] = 'zip-forecast-assessment'
        faraday.options.timeout = 5
      end
    end
  end
end
