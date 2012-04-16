class KoinController < ApplicationController
  before_filter :get_user_from_cookie, :only => [:download, :edit, :uploadFile, :show]
  before_filter :get_token, :only => :download
  before_filter :get_datafile_from_token, :only => :edit
  
  def get_user_from_cookie
    @user = Users.where("cookie_exp > date('now') and cookie = ?", cookies[:login])[0]
    @guest = true
    if @user != nil
      @guest = false
    else
      @user = Users.find_by_username('guest')
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

  def download
    logger.debug("In download")
    # Download a file by token
    @token = params[:token]
    @df = DataFile.where("digest LIKE ?", @token)[0]
    if @df && @df.digest.length == 32
      if (@df.p_only_creator && @user.id == @df.creator_id) ||
         (@df.p_any_logged_user && @user && @user.username != 'guest') ||
         (@df.p_upon_token_presentation && @df)
        send_file @df.path, :type => "application/octet-stream"
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
  def show
    unless @guest
      if @user.p_admin
        @files = DataFile.find(:all)
      else
        @files = DataFile.where("creator_id = ?", @user.id)
      end
      render :show
    else
      logger.debug("rendering as guest")
      render :index
    end
  end

  def uploadFile
    logger.debug("Hello, world!")
    @df = DataFile.new
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
    @df.capture_file(params[:upload])
    @df.save
    respond_to do |format|
      format.html {
        render :index
      }
    end
  end
end
