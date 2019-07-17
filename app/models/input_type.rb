class InputType < ActiveRecord::Base
  has_many :inputs
  has_many :users, through: :inputs
  has_many :input_details, through: :inputs
end
