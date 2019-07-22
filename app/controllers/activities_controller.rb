class ActivitiesController < ApplicationController

    def index
        user = current_user
        if user
            activities = user.activities

            render json: activities, except: [:created_at],
                    include: [ :activity_details ]
        end
    end

    def show
        user = current_user
        if user
            activity = user.activity.find(params[:id])

            render json: activity, except: [:created_at],
                    include: [ :activity_details ]

        end
    end

    def create
        user = current_user
        if user
            detail=params[:detail][:detail]
            activity_type_id=params[:detail][:activity_type_id]
            activity_date=get_date(params[:detail][:activity_date_d], params[:detail][:activity_date_t])

            # Just in case the person has not selected this -- its mandatory
            if activity_type_id==nil || activity_type_id==""
                activity_type_id=1
            end

            # Create the Exercise
            activity = Activity.create(user_id:user.id, 
                                    detail:detail, 
                                    activity_type_id:activity_type_id, 
                                    activity_date:activity_date )


            # Now create the meal detail records from the super huuuuge hash depending on whether from 
            # website app or some other device which will not have seperated the process
            if params[:detail][:alexa]
                api= Nutritionixapi.new
                activity_details=api.get_activityinfo(detail, user)    
            else
                activity_details = params[:detail][:activity_detail]
            end

            create_activitydetails( activity, activity_details )

            render json: activity, except: [:created_at],
                    include:  [ :activity_details ]
            
        end
    end

    def destroy
        user = current_user
        if user
            if params[:id]=="last"
                activity=user.activities.last
            else 
                activity = user.activities.find(params[:id]);
            end
            if activity
                result = {detail:activity.detail,
                        calories:activity.calories }
                activity.activity_details.destroy_all;
                activity.destroy;
            else
                result = {detail:"",
                    calories:0 }
            end 
            render json: result
        end
    end
    
    def update
        user = current_user
        activity = user.activity.find(params[:id]);
        if activity
            detail=params[:detail][:detail]
            activity_type_id=params[:detail][:activity_type_id]
            input_date=get_date(params[:detail][:activity_date_d], params[:detail][:activity_date_t])

            # Create the Activity
            activity = activity.update(user_id:user.id, 
                                    detail:detail, 
                                    activity_type_id:activity_type_id, 
                                    activity_date:activity_date);
            if activity.valid?
                activity.activity_details.destroy_all                   
                create_activitydetails( activity, params[:detail][:activity_details] )
                activity.save            
            end

            render json: activity, except: [:created_at],
                    include:  [ :activity_details ]

        end
    end

private

    def create_activitydetails( activity, activity_details )

        calories=0
        activity_details.map { |a| 
            calories+= (a[:duration_min].to_f * a[:unit_calories].to_f).to_i
            activitydetail=ActivityDetail.create(
                activity_id:activity.id,
                name:a[:name],
                unit_calories:a[:unit_calories],           
                duration_min:a[:duration_min],
                photo_thumb:a[:photo_thumb]
            )
        }
        
        activity.reload
        activity.update(calories:calories)
        activity.save
        
    end

    def exercise_params
# WORK TO DO
# NEED TO ADD IN THE DETAILS SO THE CREATE WORKS
# CURRENTLY AN ISSUE AS DETAILS IS AN ARRAY, AND 
# PHOTO IS A HASH IN THE ARRAY
        params.require(:detail).permit(
            :id,
            :user_id,
            :detail,
            :exercise_date,
            :exercise_date_d,
            :exercise_date_t,
            :exercise_type_id,
            :totalCalories
            )
    end

end