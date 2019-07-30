class Modifyservingunit < ActiveRecord::Migration[5.2]
  def change
    change_column :input_details, :serving_unit, :string
  end
end
