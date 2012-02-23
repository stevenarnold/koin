class UsersTable < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username
      t.string :enc_passwd
      t.string :salt
      t.boolean :p_search_all, default: false
      t.boolean :p_admin, default: false
      t.integer :quota, default: 0
      t.timestamps
    end
    add_column :data_files, :p_only_creator, :boolean
    add_column :data_files, :p_any_logged_user, :boolean
    add_column :data_files, :p_upon_token_presentation, :boolean
    add_column :data_files, :token_id, :string
    add_column :data_files, :creator_id, :integer
    add_column :data_files, :size, :integer
  end

  def down
    drop_table :users
    remove_columns :data_files, :token_id, :creator_id
  end
end
