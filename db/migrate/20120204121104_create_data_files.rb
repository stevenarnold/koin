class CreateDataFiles < ActiveRecord::Migration
  def change
    create_table :data_files do |t|
      t.string :digest
      t.string :path
      t.timestamps
    end
  end
end
