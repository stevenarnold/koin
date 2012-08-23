require 'digest/md5'
require 'zip/zip'
require 'fileutils'

class KoinController < ApplicationController
  layout "application"
  
  before_filter :setup
  before_filter :get_user_from_cookie, :only => [:download, :edit,
                      :uploadFile, :show, :index, :admin]
  before_filter :get_token, :only => [:download, :zipindex]
  before_filter :get_datafile_from_token, :only => [:edit]
  before_filter :get_users #, :only => [:index, :show, :download, :edit, :uploadFile]
  before_filter :get_action
  before_filter :require_logon
  before_filter :require_admin, :only => [:admin]
  before_filter :updateFile, :only => [:uploadFile]
  before_filter :get_file_elements, :only => [:zipindex, :download]
  
  class ZipFileStub
    attr_accessor :to_s, :size
    
    def initialize(name)
      @to_s = name.to_s
      @size = 0
    end
    
    def name_is_directory?
      true
    end
  end
  
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
    @user = User.new(:passwd => params[:admin_password])
    @user.username = params[:admin_username]
    @user.p_admin = 't'
    @user.save!
    @df = DataFile.new
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
    @token = token || params[:token] || params[:data_file][:token_id] || @token
  end

  def get_datafile_from_token(token=false)
    #debugger
    get_token(token)
    begin
      @df = DataFile.where("token_id LIKE ?", @token)[0]
    rescue
      @df = false
    end
  end
  
  def index
    # debugger
    @df = DataFile.new
    case session[:next_action]
    when 'show'
      session.delete(:next_action)
      render :show
    when 'admin'
      session.delete(:next_action)
      admin
      render :admin
    end
  end
  
  def get_file_elements
    @token = params[:token]
    if params[:path]
      @path = params.fetch(:path, '') + '.' + params.fetch(:format, '')
    else
      @path = nil
    end
    @df = DataFile.where("token_id = ?", @token)[0]
  end
  
  def is_leaf?(root, path)
    #debugger
    return false if root == path
    return false if root.length > path.length
    path = path[root.length, path.length] if path.start_with?(root)
    return false if not path
    numslashes = path.scan(/\//).length
    return false if numslashes > 1
    return true if numslashes == 0
    return false if path[-1] != "/"
    return true
  end
  
  def zipindex
    @path = params.fetch(:path, '')
    @path = @path + "/" if @path != "" && @path[-1] != "/"
    @action = "Viewing '#{File.basename(@df.path)}'"
    @zipfiles = []
    @updir, base = File.split(@path)
    #debugger
    # Get all files beginning with @path
    Zip::ZipFile.foreach(@df.path) do |file|
      fullpath = file.to_s
      #debugger
      if is_leaf?(@path, fullpath)
        @zipfiles << file 
      end
    end
    # link = @zipfiles.min_by{|a| a.to_s.size}
    # @zipfiles.delete(link)
    # parent, base = File.split(link.to_s)
    # if parent == "."
    #   item = link
    # else
    #   item = parent
    # end
    # @zipfiles.unshift(ZipFileStub.new(item))
    
    # # We want the parent of the original path, so we can go up
    # if File.split(@path) != '.'
    #   @zipfiles << ZipFileStub.new("#{File.split(@path)[0]}/")
    # end
    # Zip::ZipFile.foreach(@df.path) do |file|
    #   # Rule: Remove the @path from the beginning of the string, then
    #   # include any files that do not contain '/' except as the final
    #   # character
    #   item = orig = file.to_s
    #   item.slice!(/^#{@path}\/?/)
    #   debugger
    #   if item == orig
    #     parent = @path
    #     while true
    #       parent, base = File.split(parent)
    #       parent = "\\." if parent == "."
    #       item.slice!(/^#{parent}\/?/)
    #       break if parent == "\\." || item != orig
    #     end
    #   end
    #   debugger
    #   if item == "" && orig.include?(@path)
    #     num_slashes = item.scan(/\//).length
    #     if num_slashes == 1 && item[-1] == "/"
    #       @zipfiles << file
    #     elsif num_slashes == 0 && item.length > 0
    #       @zipfiles << file
    #     end
    #   end
    # end
  end

  def not_found
    @error = "not found or permission not granted"
    render 'koin/index'
  end
  
  def download
    # Download a file by token
    # debugger
    if @df && @df.digest.length == 32
      #debugger
      case @user.can_download(@df, params[:pass])
      when :permission_granted
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
      when :permission_denied
        if @user.username == 'guest'
          session[:origpath] = request.fullpath
          render 'login/index'
        else
          not_found
        end
      when :wrong_password
        render :template => "koin/file_password"
      when :file_expired
        # Remove the database entry and delete the token directory
        FileUtils.rm_rf(File.dirname(@df.path))
        @df.destroy
        not_found
      else
        not_found
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
    #debugger
    updateFile unless request.get?
    get_data_file_from_token unless @df
    @action = "Edit File"
    # debugger
    if @df && (@user.is_admin || @user.owns_token(@token)) && @df.save!
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
    #debugger
    @action = "View Files"
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
  
  def updateFile
    #debugger
    @available = @user.available
    @upload = params[:data_file]
    if @upload
      @df = DataFile.new
    else
      get_datafile_from_token
    end
    #debugger
    parm = params[:data_file][:p_permissions] ||'anyone'
    password = params.fetch(:data_file, {}).delete(:pass)
    @df.password = password if password != ""
    # debugger
    if @df.update_attributes(params[:data_file])
      # @df.subject = params[:subject]
      # @df.description = params[:description]
      @df.creator_id ||= @user.id
    else
      flash[:error] = "File data could not be saved."
      render :index
      return
    end
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
    # if params[:expiration] != ""
    #   @df.expiration = params[:expiration]
    # end
  end

  def uploadFile
    # Figure out the available space for this user
    #debugger
    if @upload
      begin
        #debugger
        @df.capture_file(@upload, @available)
        @df.save!
      rescue DataFile::OverQuotaError => e
        @df = DataFile.new
        @error = "Can't upload file: Quota exceeded"
      end
      respond_to do |format|
        format.html {
          render :index
        }
      end
    else
      @df.save!
      respond_to do |format|
        format.html {
          @action = "Edit File"
          flash[:notice] = "File data saved successfully."
          render :edit
        }
      end
    end
    #debugger
  end
  
  def admin
    # debugger
    @users = User.user_files
  end
end
