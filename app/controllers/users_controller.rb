class UsersController < ApplicationController
  
  before_filter :get_user_from_cookie, :only => [:update]
  
  def update
  end
  
  def show
  end
  
  def edit
    @user = Users.find(params[:id])
  end
  
end
