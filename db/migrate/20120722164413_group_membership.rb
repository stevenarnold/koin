class GroupMembership < ActiveRecord::Migration
  def up
    create_table :group_memberships do |t|
      t.integer "parent_group_id"
      t.integer "child_group_id"
      t.timestamps
    end
  end

  def down
    drop_table :group_memberships
  end
end
