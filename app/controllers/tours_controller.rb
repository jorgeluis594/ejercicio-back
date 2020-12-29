class ToursController < ApplicationController
  def index
    api_wrapper = Api::GetApiByCity.new
    @tours = api_wrapper.call('pucallpa')
    byebug
  end
end
