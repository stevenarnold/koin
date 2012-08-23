module KoinHelper

  def logged_user
    begin
      @user ? @user.username : "guest"
    rescue
      "guest"
    end
  end
  
  def is_authenticated?
    begin
      @user ? @user.username != 'guest' : false
    rescue
      false
    end
  end
  
  def is_admin?
    begin
      @user.p_admin ? true : false
    rescue
      false
    end
  end
  
  def file_to_s(file)
    item = file.to_s
    item.slice!(/^#{@path}/)
    num_slashes = item .scan(/\//).length
    if num_slashes == 1 && item[-1] == "/"
      %|<a href="/token/index/#{@token}/#{@path}/#{item}">#{item}</a>|
    else
      %|<a href="/token/#{@token}/#{@path}#{item}">#{item}</a>|
    end
  end
  
  def file_type(file)
    file.name_is_directory? ? "Dir" : "File"
  end
  
  def file_size(file)
    size = file.size / 1024
    #debugger
    if size >= 1
      "#{size} KB"
    else
      "#{file.size} bytes"
    end
  end

end
