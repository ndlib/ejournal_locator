class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :title
      t.integer :parent_id
      t.timestamps
    end

    add_index :categories, :parent_id
  end
end
