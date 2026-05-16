require 'rails_helper'

RSpec.describe 'Forecasts', type: :request do
  describe 'POST /forecasts' do
    let(:params) do
      {
        forecast: {
          address: 'Cherry Street'
        }
      }
    end
    it 'renders forecast result' do
      allow(ForecastFetcher).to receive(:call).and_return(
        {
          zip: '10002',
          current_temp: 22,
          high: 26,
          low: 18,
          condition: 'Sunny',
          from_cache: false
        }
      )
      post forecasts_path, params: params

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('10002')
      expect(response.body).to include('Sunny')
    end

    it 'handles invalid address' do
      allow(ForecastFetcher)
        .to receive(:call)
        .and_raise(InvalidAddressError,
                   'Address could not be resolved')

      post forecasts_path, params: params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Address could not be resolved')
    end

    it 'handles external service failure' do
      allow(ForecastFetcher)
        .to receive(:call)
        .and_raise(ExternalServiceError)

      post forecasts_path, params: params

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include('temporarily unavailable')
    end
  end
end
