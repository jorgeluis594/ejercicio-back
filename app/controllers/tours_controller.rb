class ToursController < ApplicationController
  def index
    api_wrapper = Api::GetApiByCity.new
    @tours = api_wrapper.call(params[:city] || 'pucallpa')
  end
end
