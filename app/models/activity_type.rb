class ActivityType < ActiveRecord::Base
  has_many :activities
  has_many :users, through: :activities
  has_many :activity_details, through: :activities
end
