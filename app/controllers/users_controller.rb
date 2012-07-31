require 'digest/md5'

class UsersController < ApplicationController
  layout "application"
  
  before_filter :get_user_from_param_id, :except => [:new, :create]
  before_filter :get_user_from_cookie
  before_filter :edit_action, :only => [:update, :show, :edit]
  before_filter :require_admin, :only => [:new, :create]
  
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
  
  def new
    @target_user = User.new
  end
  
  def create
    @target_user = User.new
    @target_user.username = params['user']['username']
    @target_user.passwd = params["password"]
    @target_user.quota = params['user']['quota']
    @target_user.p_search_all = params['user']['p_search_all']
    @target_user.p_admin = params['user']['p_admin']
    @target_user.save!
    flash[:notice] = "User created!"
    render :edit
  end
  
end
