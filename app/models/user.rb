class User < ActiveRecord::Base

  has_secure_password
  validates :user_name, uniqueness: { case_sensitive: false }


  has_many :weights
  has_many :activities
  has_many :activity_details, through: :activities
  has_many :activity_types, through: :activities
  has_many :inputs
  has_many :input_details, through: :inputs
  has_many :input_types, through: :inputs

  def age_years( date_entered=Date.current )
    # Calculate the age in years from today as default, or a date passed in
    # This isn't perfect, as it may be out my 1 depending on the date and birthdate.
    # We will come back to this, at a later date.
    if self.dob
      date_entered.year - self.dob.year
    end
  end

  def latest_weight_kg( date_entered=Date.current)
    # Get the last weight entered, on or prior to a given date's midnight
    weight=weights.where( "weight_date < ?", date_entered.end_of_day).last
    if weight
      weight_kg=weight.weight_kg
    end
  end

  def bmr( date = Date.current )
    # Calculate the Basal Metabolic Rate using a persons height, weight, gender and age
    bmr=0
    age = age_years( date )
    weight_kg = latest_weight_kg( date )
    height_cm = self.height_cm

    if age && weight_kg && height_cm
      if self.gender[0]=='M'
  # Using the Harris-Benedict BMR equation from
  # https://www.thecalculatorsite.com/articles/health/bmr-formula.php
          bmr= (66.47 + (13.75 * weight_kg) +(5.003 *height_cm) - (6.755 *age)).round(2)
      else
          bmr=(655.1 + (9.563 * weight_kg)+(1.85 * height_cm)-(4.676 * age)).round(2)
      end
    end
    bmr
  end

  def inputdiary( date= Date.current )
# Dates are a pain ... date = Date.new(YYYY,MM,DD,HH,MM) or just YYYY,MM,DD
# Returns all meals for a user for a given day
      inputs.where( :input_date => date.beginning_of_day..date.end_of_day)
  end

  def inputdiarycalories( date = Date.current )
    # We are mapping all of the meals on a day to get all of the meal meal_details
    # this returns an array of arrays .... so we need to flatten it to allow us
    # to get to the attributes/methods in the detail class.
    # MM 7/7/19 Modified to use the new attributes from the array as 
    # we now allow a user to change the serving_qty
    # inputdiary( date ).map {|m| m.input_details }.flatten.map {|md| md.unit_calories * md.unit_grams }.sum

    inputdiary( date ).sum {|i| i.calories ? i.calories : 0 }
  end

  def inputdiarytype( date = Date.current )
# Returns the worst meal type for a given day
# assumes the largest id is the worst
    inputdiary( date ).map {|i| i.input_type }.max_by {|mm| mm.id }
  end

  def activitydiary( date = Date.current )
    # Return all exercise class instances for a person on a given day
    activities.where( :activity_date => date.beginning_of_day..date.end_of_day)
  end

  def activitydiarycalories( date = Date.current )
    # returns the total calories spent exercising for a given day and user.
    activitydiary( date ).sum {|i| i.calories ? i.calories : 0 }

  end

  def activitydiarytype( date = Date.current )
# Returns the worst meal type for a given day
# assumes the largest id is the worst
    activitydiary( date ).map {|a| a.activity_type }.max_by {|ee| ee.id }
  end

  def bmrsummary ( date=Date.current-6, iterations=7 )
# Return an array of BMR calculations, from date, with each iteration being date+index
    return_array = []
    counter=0
    iterations.times do
      return_array << bmr( date + counter )
      counter+=1
    end
    return_array
  end

  def weightsummary( date=Date.current-6, iterations=7 )
# Return an array of weight entries, returning the latest entered prior to a date
    return_array = []
    counter=0
    iterations.times do
      return_array << latest_weight_kg( date + counter )
      counter+=1
    end
    return_array
  end

  def inputsummary( date=Date.current-6, iterations=7 )
  # Return an array of Input entries, summarised by type,
  # for a range of dates starting with date
    returnarray = []
    counter=0
    iterations.times do
      searchdate=date+counter
      inputhash = {
        :date => searchdate,
        :type => inputdiarytype( searchdate ),
        :calories => inputdiarycalories( searchdate )
      }
      returnarray << inputhash
      counter+=1
    end
    returnarray
  end

  def activitysummary( date=Date.current-6, iterations=7 )
  # Return an array of Activity entries, summarised by type,
  # for a range of dates starting with date
    returnarray = []
    counter=0
    iterations.times do
      searchdate=date+counter
      activityhash = {
        :date => searchdate,
        :type => activitydiarytype( searchdate ),
        :calories => activitydiarycalories( searchdate )
      }
      returnarray << activityhash
      counter+=1
    end
    returnarray
  end

  def caloriesummary( date=Date.current-2, iterations=3 )
  # Return an array of exercise entries, summarised by type,
  # for a range of dates starting with date
    returnarray = []
    counter=0
    iterations.times do
      searchdate=date+counter
      bmr = bmr( searchdate )
      input = inputdiarycalories( searchdate )
      activity = activitydiarycalories( searchdate )
      deficit = input - bmr - activity
      insight = getinsight(date,bmr,input,activity,deficit)
      speechtext = getspeechtext(date,bmr,input,activity,deficit)

      if searchdate==Date.current
        bmr = (bmr * (Time.current.strftime("%H").to_f / 24.0 ).to_f).ceil(1)
      end

      summaryhash = {
        :search_date => searchdate.to_s,
        :bmr => bmr,
        :input => input,
        :activity => activity,
        :deficit => deficit,
        :insight => insight,
        :speechtext => speechtext
      }
      returnarray << summaryhash
      counter+=1
    end

    returnarray

  end

  def getinsight( date,bmr,input,activity,deficit )
    # Will return a bit of insight into what is going on with you
    # This should look at historical data, do stsatistical analysis etc
    # Possibly extend the use of the API to get recommended calorie intakes
    # For now, will be pretty basic

    if bmr == 0
      insight = "Data issue, please check age, sex and weight is recorded. "
    elsif input == 0 && activity == 0
      insight = "Please add an activity and some food to get an insight. "
    elsif deficit > (bmr*0.2)
      insight = "Phew, you sure are eating, maybe slow down a little. "
    elsif deficit > (bmr*0.1)
      insight = "Not too bad, but either eat less, or exercise more. "
    elsif deficit > (0-(bmr*0.1))
      insight = "You are keeping it steady, well done. "
    elsif deficit > (0-(bmr*0.2))
      insight = "You must be feeling hungry, maybe eat a little more. "
    else
      insight = "Are you a monk on bread and water ? please eat ! "
    end
  end

  def getspeechtext( date,bmr,input,activity,deficit )
    # Will return a written version of the calory calculation

    if input == 0 
      speechtext = "You have not recorded any food or drinks. "
    else
      speechtext = "Your intake was " + input.to_s + " calories. " 
    end

    if activity == 0 
      speechtext = speechtext + "You have not recorded any activities. "
    else  
      speechtext = speechtext + "You burnt " + activity.to_s + " calories. "
    end
    
    if input>0 && activity>0
      speechtext = speechtext + " Well done using Eloise, maybe consider adding a goal !!!"
    else  
      speechtext = speechtext + " To get the best out of me, please do make sure you use me every day." 
    end

    speechtext

  end

  def getinteractivespeech

    # Looks at entered data, and will return speec to 
    # guide the user to add more to the solution
    # In a sense, a mini user guide

    salutation = "Hello " + self.name
    speechtext=" "

    weight_kg=self.latest_weight_kg
    last_input_entry=self.inputs.last.input_date
    last_activity_entry=self.activities.last.activity_date
    if dob==nil || gender==nil || height_cm==nil || weight_kg==nil || last_input_entry==nil || last_activity_entry==nil
      if weight_kg==nil
        speechtext += ", I need your weight in kilograms to calculate your daily BMR. Please say add height. "
      elsif last_input_entry==nil
        speechtext += ", You haven't recorded any food or drinks. Please say add food. "
      elsif height_cm==nil
        speechtext += ", I need your height in cm to calculate your daily BMR. Please say add height. "
      elsif gender==nil || gender==""
        speechtext += ", I need your physical gender to calculate your BMR. Please say add gender. "
      elsif dob==nil
        speechtext += ", I need to know how old you are to calculate your BMR. Please say add age. "
      end
    else 
      speechtext += ", what would you like to do ? "
    end

    returnHash = { salutation:salutation,
                  speechtext:speechtext}

    returnHash

  end

end
