class Input < ActiveRecord::Base
  belongs_to :user
  belongs_to :input_type
  has_many :input_details

  def total_calories 
    self.input_details.sum { |input| 
      input.serving_qty * input.unit_calories
    }
  end

end
