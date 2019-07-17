class Meal < ActiveRecord::Base
  belongs_to :user
  belongs_to :meal_type
  has_many :meal_details
end
