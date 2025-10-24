class HomeController < ApplicationController
  def index
    @weather = WeatherService.get_weather(params[:address])
  end
end
