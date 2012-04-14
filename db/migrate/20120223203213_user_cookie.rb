class UserCookie < ActiveRecord::Migration
  def up
    add_column :users, :cookie, :string
    add_column :users, :cookie_exp, :datetime
  end

  def down
    remove_columns :users, :cookie, :cookie_exp
  end
end
