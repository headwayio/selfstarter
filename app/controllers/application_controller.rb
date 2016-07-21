class ApplicationController < ActionController::Base
  protect_from_forgery

  def port
    Rails.env.production? ? '' : ':3000'
  end
end
