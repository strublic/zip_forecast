require 'rails_helper'

RSpec.describe 'Forecasts', type: :request do
  describe 'POST /forecasts' do
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

      post forecasts_path, params: {
        forecast: {
          address: 'Cherry Street'
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('10002')
    end

    it 'handles invalid address' do
      allow(ForecastFetcher)
        .to receive(:call)
        .and_raise(InvalidAddressError)

      post forecasts_path, params: {
        forecast: {
          address: 'bad address'
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
