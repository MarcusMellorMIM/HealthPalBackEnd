class ApiController < ApplicationController

    def food
        if logged_in
            api= Nutritionixapi.new
            food=api.get_mealinfo(params[:detail])
            render json: food
        end
    end

    def exercise
        user = current_user
        if user
            api= Nutritionixapi.new
            exercise=api.get_exerciseinfo(params[:detail], user )
            render json: exercise
        end
    end
end