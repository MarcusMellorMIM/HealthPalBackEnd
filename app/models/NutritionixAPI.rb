require 'net/http'
require 'json'
require 'net/https'

class Nutritionixapi

  # Please note the NUTRIONIX_APIKEY and the NUTRIONIX_APPID need to be set 
# as environment variables, that you can get from nutrionix as part of their developer
# program

  def get_inputinfo(detail)
# Returns a hash of individual components of a free text get_meal
# using the nutrionix api

    @body = {
      "query" => detail,
      "timezone" => "US/Eastern"
    }.to_json

    uri = URI.parse("https://trackapi.nutritionix.com/v2/natural/nutrients")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, initheader = {'x-app-key' => ENV["NUTRIONIX_APIKEY"], 'x-app-id' =>  ENV["NUTRIONIX_APPID"], 'Content-Type' =>'application/json'})
    req.body = @body
    res = https.request(req)
    
    # Ok so this works simply with alexa and the web app allowing for user interaction etc
    # we need to manipuate the return data to be what we need, with appropriate names
    returnArray=[]
    returnJSON = JSON.parse(res.body)["foods"]


#    if returnJSON.length>0
    if returnJSON
      returnArray = returnJSON.map {|food|
        foodHash = {}
        foodHash[:name]=food["food_name"]
        foodHash[:unit_calories] = food["nf_calories"].to_f / food["serving_qty"].to_f
        foodHash[:serving_unit] = food["serving_unit"]
        foodHash[:unit_grams] = food["serving_weight_grams"].to_f / food["serving_qty"].to_f
        foodHash[:photo_thumb] = food["photo"]["thumb"]
        foodHash[:nf_calories] = food["nf_calories"]
        foodHash[:serving_weight_grams] = food["serving_weight_grams"]
        foodHash[:serving_qty] = food["serving_qty"]
        foodHash
      }
    # else 
    #   # Sometimes the interface does not find anything ... in which case, do this to prevent errors
    #   foodHash = {}
    #   foodHash[:name]="DEFAULT: " + detail,
    #   foodHash[:unit_calories] = 0
    #   foodHash[:serving_unit] = ""
    #   foodHash[:unit_grams] = 0
    #   foodHash[:photo_thumb] = ""
    #   foodHash[:nf_calories] = 0
    #   foodHash[:serving_weight_grams] = 0
    #   foodHash[:serving_qty] = 0
    #   returnArray << foodHash
    end

    returnArray
 
  end

  def get_activityinfo( detail, user )
# Returns details of free text exerise.
# It requires a persons details to calculate calorie burn

    @body = {
      "query" => detail,
      "gender" => user.gender ? user.gender : "M",
      "weight_kg" => user.latest_weight_kg ? user.latest_weight_kg : 80,
      "height_cm" => user.height_cm ? user.height_cm : 170 ,
      "age" => user.age_years ? user.age_years : 30
    }.to_json

    uri = URI.parse("https://trackapi.nutritionix.com/v2/natural/exercise")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, initheader = {'x-app-key' => 'c1c9449f86cac6f5c48e9da9eb390dc5', 'x-app-id' =>  '2d7f68ea', 'Content-Type' =>'application/json'})
    req.body = @body
    res = https.request(req)

    # Ok so this works simply with alexa and the web app allowing for user interaction etc
    # we need to manipuate the return data to be what we need, with appropriate names
    returnArray=[]
    returnJSON = JSON.parse(res.body)["exercises"]

    
    if returnJSON.length>0
      returnArray = returnJSON.map { |a|
        activityHash={}
        activityHash[:name]=a["name"]
        activityHash[:unit_calories]= a["nf_calories"].to_f / a["duration_min"].to_f
        activityHash[:duration_min]=a["duration_min"]
        activityHash[:photo_thumb]=a["photo"]["thumb"]
        activityHash
      }
    # else 
    #   activityHash={}
    #   activityHash[:name]="DEFAULT: " + detail
    #   activityHash[:unit_calories]= 0           
    #   activityHash[:duration_min]=0
    #   activityHash[:photo_thumb]=""
    #   returnArray << activityHash
    end

    returnArray

end

end