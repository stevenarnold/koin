module KoinHelper

  def is_authenticated?
    @user.username != 'guest'
  end

end
