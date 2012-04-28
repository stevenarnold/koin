module KoinHelper

  def logged_user
    @user ? @user.username : "guest"
  end
  
  def is_authenticated?
    @user ? @user.username != 'guest' : false
  end
  
  def is_admin?
    @user.p_admin ? true : false
  end

end
