class Exercise < ActiveRecord::Base
  belongs_to :user
  belongs_to :exercise_type
  has_many :exercise_details 
end
