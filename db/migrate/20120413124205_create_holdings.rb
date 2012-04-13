class CreateHoldings < ActiveRecord::Migration
  def change
    create_table :holdings do |t|
      t.integer :journal_id
      t.integer :provider_id
      t.string :additional_availability
      t.string :original_availability
      t.integer :start_year, :limit => 2
      t.integer :end_year, :limit => 2
      t.timestamps
    end
  end
end
