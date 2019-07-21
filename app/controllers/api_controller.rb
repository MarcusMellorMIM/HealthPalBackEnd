class ApiController < ApplicationController

    def input
        if logged_in
            api= Nutritionixapi.new
            input=api.get_inputinfo(params[:detail])
            render json: input
        end
    end

    def activity
        user = current_user
        if user
            api= Nutritionixapi.new
            activity=api.get_activityinfo(params[:detail], user )
            render json: activity
        end
    end
end