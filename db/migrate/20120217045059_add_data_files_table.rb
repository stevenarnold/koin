class AddDataFilesTable < ActiveRecord::Migration
  def up
    create_table :data_files do |t|
      t.string :digest
      t.string :path
      t.timestamps
    end
  end

  def down
    drop_table :data_files
  end
end
