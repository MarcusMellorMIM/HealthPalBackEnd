class MealDetail < ActiveRecord::Base
  belongs_to :meal
  has_many :users, through: :meal
  has_many :meal_types, through: :meal
end
