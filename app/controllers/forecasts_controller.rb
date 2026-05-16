class ForecastsController < ApplicationController
  def index
  end

  def create
    address = params[:forecast][:address]
    @forecast = ForecastFetcher.call(address)

    render :index
  rescue InvalidAddressError, ZipCodeNotFoundError => e
    @error = e.message
    render :index, status: :unprocessable_entity
  rescue ExternalServiceError
    @error = 'External service is temporarily unavailable. Please try again.'
    render :index, status: :service_unavailable
  end
end
