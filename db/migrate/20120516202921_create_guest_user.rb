class CreateGuestUser < ActiveRecord::Migration
  def up
    u = Users.new(:username => 'guest', :passwd => 'nopassword')
    u.save
  end

  def down
    Users.where(:username => 'guest').destroy
  end
end
