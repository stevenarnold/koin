class PasswordForDataFiles < ActiveRecord::Migration
  def up
    add_column :data_files, :password, :string
  end

  def down
    remove_column :data_files, :password
  end
end
