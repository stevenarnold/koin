class ExpirationDate < ActiveRecord::Migration
  def up
    add_column :data_files, :expiration, :timestamp
  end

  def down
    remove_column :data_files, :expiration
  end
end
