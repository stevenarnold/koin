class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def random_generator(upper)
    return (0...upper).map{(65 + rand(25)).chr}.join
  end
end
