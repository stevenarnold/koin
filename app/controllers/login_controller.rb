require 'digest/md5'

class LoginController < ApplicationController

  #FIXME neither a cookie nor an expiration are put here presently
  def auth
    #debugger
    user, pass = params[:user], params[:pass]
    # debugger
    if user && pass
      dbuser = User.find_by_username(user)
      dbuser.logged_in = false
      # debugger
      if dbuser && Digest::MD5.hexdigest(pass + dbuser.salt) == dbuser.enc_passwd
        flash[:notice] = 'Login Successful!'
        session[:user] = @user = dbuser
        @user.logged_in = true
        # debugger
        if session[:origpath]
          path = session[:origpath]
          session.delete(:origpath)
          redirect_to path
        else
          redirect_to '/koin/index'
        end
      else
        flash[:notice] = 'Incorrect username or password'
        render 'index'
      end
    else
      render 'index'
    end
  end
  
  def logout
    session.delete(:user)
    render 'login'
  end

end
