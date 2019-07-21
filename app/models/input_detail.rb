class InputDetail < ActiveRecord::Base
  belongs_to :input
  has_one :user, through: :input
  has_many :input_types, through: :input
end
