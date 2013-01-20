class AdvancedWidgetsForUsers < ActiveRecord::Migration
  def up
    add_column :users, :advanced_state, :string, default: 'closed'
  end

  def down
    remove_column :users, :advanced_state
  end
end
