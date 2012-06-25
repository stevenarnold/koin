require 'digest/md5'

class LoginController < ApplicationController

  #FIXME neither a cookie nor an expiration are put here presently
  def auth
    # debugger
    user, pass = params[:user], params[:pass]
    # debugger
    if user && pass
      dbuser = User.find_by_username(user)
      # debugger
      if dbuser && Digest::MD5.hexdigest(pass + dbuser.salt) == dbuser.enc_passwd
        flash[:notice] = 'Login Successful!'
        session[:user] = @user = dbuser
        redirect_to '/koin/index'
      else
        flash[:notice] = 'Incorrect username or password'
        render 'index'
      end
    else
      render 'index'
    end
  end

end
