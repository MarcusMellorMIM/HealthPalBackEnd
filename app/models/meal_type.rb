class MealType < ActiveRecord::Base
  has_many :meals
  has_many :users, through: :meals
  has_many :meal_details, through: :meals
end
