class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :title
      t.integer :parent_id
      t.timestamps
    end

    add_index :categories, :parent_id
    add_index :categories, :title
  end
end
