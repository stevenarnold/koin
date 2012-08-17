class SavedEncPasswd < ActiveRecord::Migration
  def up
    add_column :users, :saved_enc_passwd, :string
  end

  def down
    remove_columns :users, :saved_enc_passwd
  end
end
