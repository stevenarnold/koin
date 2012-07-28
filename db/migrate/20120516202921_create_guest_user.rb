class CreateGuestUser < ActiveRecord::Migration
  def up
    u = User.new(:username => 'guest', :passwd => 'nopassword')
    u.save
  end

  def down
    User.where(:username => 'guest').destroy
  end
end
