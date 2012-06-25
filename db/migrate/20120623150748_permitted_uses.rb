class PermittedUses < ActiveRecord::Migration
  def up
    create_table :permitted_uses do |t|
      t.integer "user_id"
      t.integer "data_file_id"
    end
  end

  def down
    drop_table :permitted_uses
  end
end
