class ActivityDetail < ActiveRecord::Base
  belongs_to :activity
  has_many :users, through: :activity
  has_many :activity_types, through: :activity
end
