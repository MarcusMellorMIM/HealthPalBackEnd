class Addtotalcalories < ActiveRecord::Migration[5.2]
  def change
    add_column :inputs, :calories, :integer
  end
end
