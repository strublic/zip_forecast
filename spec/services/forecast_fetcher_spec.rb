require 'rails_helper'

RSpec.describe ForecastFetcher do
  let(:address) { 'Cherry Street' }
  let(:zip) { '10002' }

  let(:weather_response) do
    {
      'current' => {
        'temp_c' => 22,
        'condition' => {
          'text' => 'Sunny'
        }
      },
      'forecast' => {
        'forecastday' => [
          {
            'day' => {
              'maxtemp_c' => 26,
              'mintemp_c' => 18
            }
          }
        ]
      }
    }
  end

  before do
    Rails.cache.clear
  end

  describe '.call' do
    it 'returns fresh forecast on cache miss' do
      allow(Geocoding::AddressResolver)
        .to receive(:call)
        .with(address)
        .and_return(zip)

      weather_client = instance_double(Weather::Client)

      allow(Weather::Client)
        .to receive(:new)
        .and_return(weather_client)

      allow(weather_client)
        .to receive(:current)
        .with(zip)
        .and_return(weather_response)

      result = described_class.call(address)

      expect(result[:zip]).to eq(zip)
      expect(result[:current_temp]).to eq(22)
      expect(result[:high]).to eq(26)
      expect(result[:low]).to eq(18)
      expect(result[:condition]).to eq('Sunny')
      expect(result[:from_cache]).to eq(false)
    end

    it 'returns cached forecast on cache hit' do
      cached_data = {
        zip: zip,
        current_temp: 22,
        high: 26,
        low: 18,
        condition: 'Sunny'
      }

      allow(Geocoding::AddressResolver).to receive(:call).and_return(zip)

      Rails.cache.write("forecast:#{zip}", cached_data)

      result = described_class.call(address)

      expect(result[:from_cache]).to eq(true)
      expect(result[:zip]).to eq(zip)
    end

    it 'propagates invalid address errors' do
      allow(Geocoding::AddressResolver)
        .to receive(:call)
        .and_raise(InvalidAddressError)

      expect do
        described_class.call(address)
      end.to raise_error(InvalidAddressError)
    end

    it 'propagates weather API failures' do
      allow(Geocoding::AddressResolver)
        .to receive(:call)
        .and_return(zip)

      weather_client = instance_double(Weather::Client)

      allow(Weather::Client)
        .to receive(:new)
        .and_return(weather_client)

      allow(weather_client)
        .to receive(:current)
        .and_raise(ExternalServiceError)

      expect do
        described_class.call(address)
      end.to raise_error(ExternalServiceError)
    end
  end
end
