require 'digest/md5'

class UsersController < ApplicationController
  layout "application"
  
  before_filter :get_user_from_param_id
  before_filter :get_user_from_cookie
  before_filter :edit_action, :only => [:update, :show, :edit]
  
  def edit_action
    @action = "Edit User #{@target_user.username}"
  end
  
  def update
    if @user.is_admin
      @target_user.quota = params[:users][:quota].to_i
      @target_user.p_search_all = params[:users][:p_search_all]
      @target_user.p_admin = params[:users][:p_admin]
      if params[:password]
        @passwd = params[:password]
      end
      @target_user.save!
      flash[:notice] = "User information updated"
    else
      flash[:error] = "Permission denied"
    end
    render 'edit'
  end

  def show
    render 'edit'
  end
  
  def edit
  end
  
end
