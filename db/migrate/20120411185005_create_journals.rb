class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals do |t|
      t.string :sfx_id, :limit => 20
      t.string :issn, :limit => 8
      t.string :alternate_issn, :limit => 8
      t.string :title
      t.string :alternate_title
      t.string :display_title
      t.string :publisher_name
      t.string :publisher_place
      t.timestamps
    end

    add_index :journals, :sfx_id
  end
end
