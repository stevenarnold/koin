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

end
