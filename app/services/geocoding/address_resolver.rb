module Geocoding
  class AddressResolver
    def self.call(address)
      new(address).call
    end

    def initialize(address)
      @address = address
      @client = Client.new
    end

    def call
      result = @client.search(@address).first
      raise InvalidAddressError, 'Address could not be resolved' unless result

      zip = result.dig('address', 'postcode')
      raise ZipCodeNotFoundError, 'ZIP code not found for the provided address' if zip.blank?

      zip
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise ExternalServiceError, e.message
    end
  end
end
