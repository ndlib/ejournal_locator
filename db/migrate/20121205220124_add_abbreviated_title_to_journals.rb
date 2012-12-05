class AddAbbreviatedTitleToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :abbreviated_titles, :text
    rename_column :journals, :alternate_title, :alternate_titles
    change_column :journals, :alternate_titles, :text
  end
end
