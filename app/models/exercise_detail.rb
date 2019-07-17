class ExerciseDetail < ActiveRecord::Base
  belongs_to :exercise
  has_many :users, through: :exercise
  has_many :exercise_types, through: :exercise
end
