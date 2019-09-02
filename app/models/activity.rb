class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity_type
  has_many :activity_details 

   def getinteractivespeech

    # Looks at entered data, and will return speech to voice activated devices 

    salutation = "Hello " + self.user.name
    searchdate = self.activity_date
    bmr = self.user.bmr( searchdate )
    activity = self.user.activitydiarycalories( searchdate )
    activity_rate = activity.to_f / bmr.to_f

    speechtext = ", you have added " + self.detail + " to your activity diary totalling " + self.calories.to_s + " calories. "

    if activity_rate < 0.2
      speechcongrats = ["Well done", "Good job"].sample      
      speechtext += " This is a good start, but I know you can do more. At the moment I would class this as a light activity day "
    elsif activity_rate < 0.5
      speechcongrats = ["Brilliant", "Superb"].sample      
      speechtext += " This is becoming a good day for moving about. "
    else
      speechcongrats = ["Amazing", "Awesome"].sample
      speechtext += " Phew, this is an extra active day. "
    end

    speechtext += self.user.getinteractivespeech[:speechtext]

    returnHash = { salutation:salutation,
                  speechcongrats:speechcongrats,
                  speechtext:speechtext}

    returnHash

  end

end
