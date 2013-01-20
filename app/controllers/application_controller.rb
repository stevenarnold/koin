class ApplicationController < ActionController::Base
  protect_from_forgery
  
  attr_accessor :ALLOW_GUEST
  
  def random_generator(upper)
    return (0...upper).map{(65 + rand(25)).chr}.join
  end
    
  def get_user_from_cookie
    @user = session[:user]
    @guest = true
    if @user
      @guest = false
    else
      @user = User.find_by_username('guest')
    end
  end
  
  def get_user_from_param_id
    @target_user = params[:id] ? User.find(params[:id]) : User.find(params[:users][:id]) 
  end
  
  def require_admin
    if !@user || !@user.is_admin
      session[:next_action] = "admin"
      redirect_to :controller => :login, :action => :index
    end
  end
end
