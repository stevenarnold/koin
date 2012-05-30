require 'digest/md5'

class KoinController < ApplicationController
  layout "application"
  
  before_filter :setup
  before_filter :get_user_from_cookie, :only => [:download, :edit,
                      :uploadFile, :show, :index, :admin]
  before_filter :get_token, :only => :download
  before_filter :get_datafile_from_token, :only => :edit
  before_filter :get_action
  before_filter :require_logon
  
  def require_logon
    #debugger
    if ((!@user || @user.username == 'guest') && !Koin::Application::ALLOW_GUEST)
      redirect_to :controller => :login, :action => :index
    end
  end
  
  def get_action
    @action = "File Upload"
  end

  def initadmin
    if params[:admin_password] != params[:repeat_password]
      flash[:error] = "Passwords do not match."
      render :create_admin
      return
    end
    u = Users.new(:passwd => params[:admin_password])
    u.username = params[:admin_username]
    u.p_admin = 't'
    u.save!
    render :controller => :login, :action => :index
  end
 
  def setup
    session[:createadmin] ||= false
    if session[:createadmin]
      return
    elsif Users.where("p_admin = 't'").length == 0
      if params[:initial_password] == 'LetsGetSetup'
        @insetup = true
        session[:createadmin] = true
        render :setup_page
      else
        flash[:error] = "Incorrect password."
        render :create_admin
      end
    end
  end

  def get_token(token=false)
    @token = token || params[:token]
  end

  def get_datafile_from_token(token=false)
    get_token(token)
    begin
      @df = DataFile.where("digest LIKE ?", @token)[0]
    rescue
      @df = false
    end
  end
  
  def index
    case 
    when session[:next_action] == 'show'
      delete session[:next_action]
      render :show
    end
  end

  def download
    # Download a file by token
    @token = params[:token]
    @df = DataFile.where("token_id = ?", @token)[0]
    if @df && @df.digest.length == 32
      if @user.can_download(@df)
        send_file @df.path, :type => "application/octet-stream"
      else
        render :index
      end
    else
      respond_to do |format|
        format.html {
          render :index
        }
      end
    end
  end

  def edit
    # The user is requesting to edit the resource.  This is only
    # allowed if the user is the user who posted it, or an admin.
    if @df && (@user.is_admin || @user.owns_token(@token))
      respond_to do |format|
        format.html {
          render :edit
        }
      end
    else
      flash[:notice] = "Permission denied."
      respond_to do |format|
        format.html {
          render :index
        }
      end
    end
  end
  
  # Shows files tha the logged in user has permission to see.
  # If you're an admin, you have permission to view and delete all files.
  # If you're a guest, you don't have permission to view or delete any files.
  # If you're a logged-in user, you can:
  #   - View and delete any files you posted;
  #   - View any files posted by others users for logged-in users;
  #   - View any files posted by guests
  def show
    @action= "View Files"
    if !@user.p_admin && params[:user] && params[:user] != @user.username
      session[:next_action] = 'show'
      redirect_to :controller => :login, :action => :index
      return
    end
    unless @guest
      if @user.p_admin
        @files = DataFile.find(:all)
      else
        @files = DataFile.where("creator_id = ?", @user.id)
      end
      render :show
    else
      render :index
    end
  end

  def uploadFile
    # Figure out the available space for this user
    if (@user.quota != 0)
      available = @user.get_quota - @user.used_quota
    else
      available = nil
    end
    @df = DataFile.new
    upload = params[:upload]
    parm = params[:download_perms] || 'anyone'
    case parm
    when 'me'
      @df.p_only_creator = true
      @df.p_any_logged_user = false
      @df.p_upon_token_presentation = false
    when 'users'
      @df.p_only_creator = false
      @df.p_any_logged_user = true
      @df.p_upon_token_presentation = false
    when 'anyone'
      @df.p_only_creator = false
      @df.p_any_logged_user = false
      @df.p_upon_token_presentation = true
    end
    @df.creator_id = @user.id
    @df.capture_file(upload, available)
    @df.save
    respond_to do |format|
      format.html {
        render :index
      }
    end
  end
  
  def admin
    @users = Users.find_by_sql("SELECT    u.id, u.username, count(df.digest) AS num,
                                          sum(df.size) AS size, u.quota
                                FROM      users u
                                LEFT JOIN data_files df
                                ON        u.id = df.creator_id
                                UNION ALL
                                SELECT    u.id, u.username, 0 AS num, 0 AS size, u.quota
                                FROM      users u
                                WHERE     u.id NOT IN (SELECT    count(df.creator_id)
                                                       FROM      data_files df)
                                ORDER BY  u.username")
  end
end
