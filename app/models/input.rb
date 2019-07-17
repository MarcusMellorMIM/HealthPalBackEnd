class Input < ActiveRecord::Base
  belongs_to :user
  belongs_to :input_type
  has_many :input_details
end
