module KoinHelper

  def logged_user
    @user ? @user.username : "guest"
  end
  
  def is_authenticated?
    @user ? @user.username != 'guest' : false
  end

end
