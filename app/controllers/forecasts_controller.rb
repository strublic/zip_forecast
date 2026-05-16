class ForecastsController < ApplicationController
  def index
  end

  def create
    address = params[:forecast][:address]
    @forecast = ForecastFetcher.call(address)

    render :index
  end
end
