class ActivityDetail < ActiveRecord::Base
  belongs_to :activity
  has_one :user, through: :activity
  has_one :activity_type, through: :activity
end
