require 'digest/md5'
require 'zip/zip'

class KoinController < ApplicationController
  layout "application"
  
  before_filter :setup
  before_filter :get_user_from_cookie, :only => [:download, :edit,
                      :uploadFile, :show, :index, :admin]
  before_filter :get_token, :only => :download
  before_filter :get_datafile_from_token, :only => :edit
  before_filter :get_users #, :only => [:index, :show, :download, :edit, :uploadFile]
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
  
  def get_users
    # debugger
    @users = User.order(:username)
  end

  def initadmin
    if params[:admin_password] != params[:repeat_password]
      flash[:error] = "Passwords do not match."
      render :create_admin
      return
    end
    u = User.new(:passwd => params[:admin_password])
    u.username = params[:admin_username]
    u.p_admin = 't'
    u.save!
    render :controller => :login, :action => :index
  end
 
  def setup
    session[:createadmin] ||= false
    if session[:createadmin]
      return
    elsif User.where("p_admin = 't'").length == 0
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
    # debugger
    case 
    when session[:next_action] == 'show'
      delete session[:next_action]
      render :show
    end
  end

  def download
    # Download a file by token
    #debugger
    @token = params[:token]
    @path = params.fetch(:path, '') + '.' + params.fetch(:format, '')
    @df = DataFile.where("token_id = ?", @token)[0]
    if @df && @df.digest.length == 32
      if @user.can_download(@df, params[:pass])
        if @path && @df.path =~ /\.zip$/
          # Return the individual file requested from the zip
          Zip::ZipFile.open(@df.path) do |zipfile|
            filename = File.basename(@path)
            zipfile.get_output_stream(filename) do |f|
              send_data f.read, :filename => filename, :type => "application/octet-stream"
            end
          end
        else
          send_file @df.path, :type => "application/octet-stream"
        end
      else
        if @user.username == 'guest'
          session[:origpath] = request.fullpath
          render 'login/index'
        elsif @df.password
          render :template => "koin/file_password"
        else
          @error = "not found or permission not granted"
          render 'koin/index'
        end
      end
    else
      #debugger                       
      respond_to do |format|
        format.html {
          session[:origpath] = request.fullpath
          render 'login/index'
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
    # debugger
    @action= "View Files"
    if !@user.p_admin && params[:user] && params[:user] != @user.username
      session[:next_action] = 'show'
      redirect_to :controller => :login, :action => :index
      return
    end
    # debugger
    unless @guest
      if @user.p_admin
        @files = DataFile.find(:all)
      else
        # debugger
        @files = DataFile.where("creator_id = ? OR p_upon_token_presentation = 't'", @user.id)
      end
      render :show
    else
      render :index
    end
  end

  def uploadFile
    # Figure out the available space for this user
    available = @user.available
    @df = DataFile.new
    upload = params[:upload]
    parm = params[:download_perms] || 'anyone'
    #debugger
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
    when 'specific_users'
      @df.p_only_creator = false
      @df.p_any_logged_user = false
      @df.p_upon_token_presentation = false
      @df.viewers << @user
      params[:users][:selected].each do |id|
        # debugger
        @df.viewers << User.find(id.to_i)
      end
    end
    @df.creator_id = @user.id
    if params[:pass] != ""
      @df.password = params[:pass]
    end
    begin
      #debugger
      @df.capture_file(upload, available)
      @df.save!
    rescue DataFile::OverQuotaError => e
      @df = nil
      @error = "Can't upload file: Quota exceeded"
    end
    respond_to do |format|
      format.html {
        render :index
      }
    end
  end
  
  def admin
    @users = User.find_by_sql("SELECT    u.id, u.username, count(df.digest) AS num,
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
