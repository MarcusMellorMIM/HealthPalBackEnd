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
    weight=latest_weight( date_entered )
    if weight
      weight_kg=weight.weight_kg
    end
  end

  def latest_weight( date_entered=Date.current)
    # Get the last weight entered, on or prior to a given date's midnight
    weights.where( "weight_date < ?", date_entered.end_of_day).last
  end

  def bmi( date = Date.current)
  # Calculate the Body Mass Index using a persons height in cm and weight in kg
    bmi=0
    weight_kg = latest_weight_kg( date )
    height_m = self.height_cm.to_f / 100

    if weight_kg && height_cm
      bmi = weight_kg / ( height_m * height_m)
    end
    bmi.ceil(1)
  end

  def bmi_range( date=Date.current )
    bmi = bmi(date)
    bmi_str = bmi.to_s
    resultHash={}
    resultHash["BMI"]=bmi
    if bmi < 18.5
      suggested_weight=deconstruct_bmi( bmi * 1.1 );
      resultHash["range"]="Underweight"
      resultHash["suggestion1"]="Your BMI is " + bmi_str + ", for this reason, you could do with putting on a bit of weight."
      resultHash["suggestion2"]="Your BMI is " + bmi_str + ", if you get your weight to " + deconstruct_bmi(18.5).to_s + " kilos, you will then be in the normal weight range. " 
      resultHash["suggestion3"]="Maybe set a target to increase your weight to " + suggested_weight.to_s
    elsif bmi < 25 
      suggested_weight=deconstruct_bmi( 22 );
      resultHash["range"]="Normal"
      resultHash["suggestion1"]="Good job, your BMI is " + bmi_str + ", which means your weight is within normal range."
      resultHash["suggestion2"]=""
      resultHash["suggestion3"]=""
    elsif bmi < 30
      suggested_weight=deconstruct_bmi( bmi * 0.9 );
      resultHash["range"]="Overweight"
      resultHash["suggestion1"]="Your BMI is " + bmi_str + ", which means you are a little overweight. Maybe lose a little ? "
      resultHash["suggestion2"]="You are a little overweight, maybe set a goal to get your weight down to " + suggested_weight.to_s 
      resultHash["suggestion3"]="Your BMI is " + bmi_str + ", if you get your weight to " + deconstruct_bmi(25).to_s + " kilos, you will then just be in the normal range. " 
    else
      suggested_weight=deconstruct_bmi( bmi * 0.9 );
      resultHash["range"]="Obese"
      resultHash["suggestion1"]="Your BMI is " + bmi_str + ", for health reasons, I would urge you to lose some weight."
      resultHash["suggestion2"]="Your BMI suggests you are overweight. Please try and get your weight down a little. How about trying for  " + suggested_weight.to_s + " kilos."
      resultHash["suggestion3"]="Your BMI is " + bmi_str + ", if you get your weight to " + deconstruct_bmi(30).to_s + " kilos, you will then be well on your way to reducing your increased health risks. " 
    end
    resultHash["suggestedtargetweight"]=suggested_weight

    resultHash

  end

  def deconstruct_bmi( bmi )

    height_m = self.height_cm.to_f / 100  
    weight_kg = (bmi * ( height_m * height_m)).ceil(1)

    weight_kg

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
    bmr.to_i
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
      # insight = getinsight(date,bmr,input,activity,deficit)
      speechtext = getspeechtext(searchdate,bmr,input,activity,deficit)

      if searchdate==Date.current
        bmr = (bmr * (Time.current.strftime("%H").to_f / 24.0 ).to_f).ceil(1)
      end

      summaryhash = {
        :search_date => searchdate.to_s,
        :bmr => bmr,
        :input => input,
        :activity => activity,
        :deficit => deficit,
        # :insight => insight,
        :speechtext => speechtext
      }
      returnarray << summaryhash
      counter+=1
    end

    returnarray

  end

  # def getinsight( date,bmr,input,activity,deficit )
  #   # Will return a bit of insight into what is going on with you
  #   # This should look at historical data, do stsatistical analysis etc
  #   # Possibly extend the use of the API to get recommended calorie intakes
  #   # For now, will be pretty basic

  #   if bmr == 0
  #     insight = "Please check age, sex and weight is recorded so I can calculate your daily calorie requirement. "
  #   elsif input == 0 && activity == 0
  #     insight = "Please add an activity and some food to get an insight. "
  #   elsif deficit > (bmr*0.2)
  #     insight = "Phew, you sure are eating, maybe slow down a little. "
  #   elsif deficit > (bmr*0.1)
  #     insight = "Not too bad, but either eat less, or exercise more. "
  #   elsif deficit > (0-(bmr*0.1))
  #     insight = "You are keeping it steady, well done. "
  #   elsif deficit > (0-(bmr*0.2))
  #     insight = "You must be feeling hungry, maybe eat a little more. "
  #   else
  #     insight = "Are you a monk on bread and water ? please eat ! "
  #   end
  # end

  def getspeechtext( date,bmr,input,activity,deficit )
    # Will return a written version of the calory calculation

    speechtext="";
    today=false;
    is_was="was";
    have_did="did";
    record_ed="record";

    today = false; 

    if date == Date.current
      speechtext="Today, ";
      today=true;
      is_was="is";
      have_did="have"
      record_ed="recorded"
    elsif date == Date.current - 1 
      speechtext="Yesterday, "
    elsif date == Date.current - 7
      speechtext="Last week, "
    else
      #Will say the day
      speechtext = "On " + date.strftime("%A") + ", "  
    end

    if bmr > 0 
        speechtext += "Your resting calorie requirement " + is_was + " " + bmr.to_s + " calories. "
    end 

    if input == 0 && activity == 0
      speechtext = speechtext + "You " + have_did + " not " + record_ed + " any food, drinks or activities. "
    end

    if input == 0 && activity != 0
      speechtext = speechtext + "You " + have_did + " not " + record_ed + " any food or drinks. "
    elsif input != 0
      speechtext = speechtext + "Your food and drink intake " + is_was + " " + input.to_s + " calories. " 
    end

    if activity == 0 && input != 0
      speechtext = speechtext + "You " + have_did + " not " + record_ed + " any activities. "
    elsif activity != 0
      speechtext = speechtext + "You burnt " + activity.to_s + " calories through exercise. "
    end


    if (deficit > (bmr*0.05)) && (input > 0 || activity > 0)
        if today 
          speechtext = speechtext + "You need to burn off " + deficit.to_s + " calories, if you want to maintain your current weight. "
        else
          speechtext = speechtext + "Your intake was " + deficit.to_s + " calories greater than you needed, possibly leading to weight gain."
        end 
    elsif (deficit < (0-(bmr*0.05))) && (input > 0 || activity > 0)
        if today 
          speechtext = speechtext + "You can eat or drink " + (0-deficit).to_s + " calories more, and maintain your current weight."
        else   
          speechtext = speechtext + "You burnt " + (0-deficit).to_s + " calories more than you needed, possibly leading to weight loss. "
        end 
    end

    if input>0 && activity>0
      speechtext = speechtext + " Well done using Evos, your health pal. "
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
    screentext=""
    navlink=""
    input_req_today=true
    activity_req_today=true
    latest_weight=self.latest_weight
    last_input_entry=self.inputs.last      
    last_activity_entry=self.activities.last

    if last_input_entry
      if last_input_entry.input_date>=Date.current
        input_req_today=false
      end
    end 

    if last_activity_entry
      if last_activity_entry.activity_date>=Date.current
        activity_req_today=false
      end 
    end

    if dob==nil || gender==nil || height_cm==nil || !latest_weight || input_req_today || activity_req_today
      if !latest_weight
        speechtext += ", I need your weight in kilograms to calculate your daily BMR. Please say add weight. "
        screentext = "I need your weight in kilograms to calculate your daily BMR. Please enter your latest weight to get the most out of your health pal. Click on smart navigation to help you on your way."
        navlink="Weight"
      elsif height_cm==nil
        speechtext += ", I need your height in centimetres to calculate your daily BMR. Please say add height. "
        screentext = "I need your height in centimetres to calculate your daily BMR. Please enter your height to get the most out of your healthg pal.  Click on smart navigation to get to where you need to be."
        navlink="Account"
      elsif gender==nil || gender==""
        speechtext += ", I need your physical gender to calculate your BMR. Please say add gender. "
        screentext = "I need your physical gender to calculate your BMR. Please add your gender to get the most out of your health pal.  Click on smart navigation to open the right page."
        navlink="Account"
      elsif dob==nil
        speechtext += ", I need to know how old you are to calculate your BMR. Please say add age. "
        screentext = "I need to know how old you are to calculate your BMR. Please add your age to get the most out of your health pal.  Click on smart navigation to show how many years young you are."
        navlink="Account"
      elsif input_req_today
        speechtext += ", You haven't recorded any food or drinks today. Please say add food. "
        screentext = "You haven't recorded any food or drinks today. Please record food and/or drinks to get the most out of your health pal.  Click on smart navigation to record those calories."
        navlink="Input"
      elsif activity_req_today
        speechtext += ", You haven't recorded any activities today. Please say add activity. "
        screentext = "You haven't recorded any activities today. Please record all of your activities as they happen, to get the most out of your health pal.  Click on smart navigation to store your activities."
        navlink="Activity"
      elsif latest_weight.weight_date < Date.current-7
        speechtext += ", You haven't recorded your weight for a while. Please say add weight. "
        screentext = "You haven't recorded your weight for a while. Please add your latest weight so we can make sure your daily calory burn is accurate.  Click on smart navigation to record your weight."
        navlink="Weight"
      end 
    else 
      # All has been entered ... so now onto the insights
      bmiHash=self.bmi_range
      speechtext = [bmiHash["suggestion1"],bmiHash["suggestion2"],bmiHash["suggestion3"]," don't forget to say HELP as a reminder of all you can do with me. ",", don't forget to say goodbye when you are done",""].sample
      speechtext += " , What would you like to do ? "
      screentext = [bmiHash["suggestion1"],bmiHash["suggestion2"],bmiHash["suggestion3"]].sample
    end

    returnHash = { salutation:salutation,
                  speechcongrats:["Well done","Awesome", "Good job", "Amazing", "Woop woop"].sample,
                  speechtext:speechtext,
                  screentext:screentext,
                  navlink:navlink}

    returnHash

  end

end
