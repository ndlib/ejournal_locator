class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :title
      t.timestamps
    end

    add_index :providers, :title
  end
end
