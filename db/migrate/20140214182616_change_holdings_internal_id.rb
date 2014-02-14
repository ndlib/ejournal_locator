class ChangeHoldingsInternalId < ActiveRecord::Migration
  def up
    change_column(:holdings, :internal_id, :string)
  end

  def down
    change_column(:holdings, :internal_id, :integer)
  end
end
