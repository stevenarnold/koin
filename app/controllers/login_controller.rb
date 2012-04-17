require 'digest/md5'

class LoginController < ApplicationController

  #FIXME neither a cookie nor an expiration are put here presently
  def auth
    user, pass = params[:user], params[:pass]
    if user && pass
      dbuser = Users.find_by_username(user)
      if dbuser && Digest::MD5.hexdigest(pass + dbuser.salt) == dbuser.enc_passwd
        flash[:notice] = 'Login Successful!'
        session[:user] = @user = dbuser
        render 'koin/index'
      else
        flash[:notice] = 'Incorrect username or password'
        render 'index'
      end
    else
      render 'index'
    end
  end

end
