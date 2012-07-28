class SubjectAndDescription < ActiveRecord::Migration
  def up
    add_column :data_files, :subject, :string
    add_column :data_files, :description, :string
  end

  def down
    remove_column :data_files, :subject
    remove_column :data_files, :description
  end
end
