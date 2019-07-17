class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity_type
  has_many :activity_details 
end
