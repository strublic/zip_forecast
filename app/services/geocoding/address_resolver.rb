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

      raise 'Address not found' unless result

      zip = result.dig('address', 'postcode')

      raise 'ZIP code not found' if zip.blank?

      zip
    end
  end
end
