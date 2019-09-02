class Input < ActiveRecord::Base
  belongs_to :user
  belongs_to :input_type
  has_many :input_details

  def total_calories 
    self.input_details.sum { |input| 
      input.serving_qty * input.unit_calories
    }
  end

  def getinteractivespeech

    # Looks at entered data, and will return speech to voice activated devices 

    salutation = "Hello " + self.user.name
    searchdate = self.input_date
    bmr = self.user.bmr( searchdate )
    input = self.user.inputdiarycalories( searchdate )
    activity = self.user.activitydiarycalories( searchdate )
    deficit = (input - bmr - activity).ceil(0)

    speechtext = ", you have added " + self.detail + " to your diary totalling " + self.total_calories.to_s + " calories. "

    if deficit < 0
      speechtext += "you can eat or drink " + (0-deficit).to_s + " more calories, and maintain your weight. "
    else
      speechtext += "you have eaten " + deficit.to_s + " more than you should have, if you want to maintain your weight. "
    end

    speechHash = self.user.getinteractivespeech
    speechtext += speechHash[:speechtext]
    speechcongrats = speechHash[:speechcongrats]
    returnHash = { salutation:salutation,
                  speechcongrats:speechcongrats,
                  speechtext:speechtext}
    
    returnHash

  end


end
