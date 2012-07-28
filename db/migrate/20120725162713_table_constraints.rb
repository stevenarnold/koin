class TableConstraints < ActiveRecord::Migration
  def up
    change_column :group_memberships, :parent_group_id, :integer, :null => false
    change_column :group_memberships, :child_group_id, :integer, :null => false
    change_column :users, :username, :string, :null => false
  end

  def down
    change_column :group_memberships, :parent_group_id, :integer, :null => true
    change_column :group_memberships, :child_group_id, :integer, :null => true
    change_column :users, :username, :string, :null => true
  end
end
