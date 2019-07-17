class ExerciseType < ActiveRecord::Base
  has_many :exercises
  has_many :users, through: :exercises
  has_many :exercise_details, through: :exercises
end
