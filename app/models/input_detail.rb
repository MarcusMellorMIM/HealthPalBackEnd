class InputDetail < ActiveRecord::Base
  belongs_to :input
  has_one :user, through: :input
  has_one :input_type, through: :input
end
