class ExercisesController < ApplicationController

    def index
        user = current_user
        if user
            exercises = user.exercises

            render json: exercises, except: [:created_at],
                    include: [ :exercise_details ]
        end
    end

    def show
        if logged_in
            exercise = Exercise.find(params[:id])
            render json: exercise
        end
    end

    def create
# WORK TO DO -- FIGURE OUT HOW TO USE PERMIT PARAMS WITH A LARGE HASH ARRAY
        user = current_user
        if user
            detail=params[:detail][:detail]
            exercise_type_id=params[:detail][:exercise_type_id]
            exercise_date=params[:detail][:exercise_date]
            exercise_date_d=params[:detail][:exercise_date_d]
            exercise_date_t=params[:detail][:exercise_date_t]

            # Probably long winded, but this allows for a null date
            # to default to today, and a null time to default to now.
            # So if a user enters a date, and no time ... time is set
            # if time and no date, the time goes against today etc etc
            if exercise_date_d==nil || exercise_date_d==""
                exercise_date_d=Date.current.to_s
            end
            if exercise_date_t==nil || exercise_date_t==""
                exercise_date_t=Time.current.strftime("%H:%M")
            end
            exercise_date = (exercise_date_d + ' ' + exercise_date_t).to_datetime

            # Just in case the person has not selected this -- its mandatory
            if exercise_type_id==nil || exercise_type_id==""
                exercise_type_id=1
            end

            # Create the Exercise
            exercise = Exercise.create(user_id:user.id, detail:detail, exercise_type_id:exercise_type_id, exercise_date:exercise_date )

            # Now create the meal detail records from the super huuuuge hash
            params[:detail][:exercise_details].map { |e|            
                exercisedetail=ExerciseDetail.create(
                    exercise_id:exercise.id,
                    name:e[:name],
                    unit_calories:e[:unit_calories],           
                    duration_min:e[:duration_min],
                    photo_thumb:e[:photo_thumb]
                )
            }

            render json: exercise
        end
    end

    def destroy
        if logged_in
            exercise = Exercise.find(params[:id]);
            exercise.exercise_details.destroy;
            exercise.destroy;
        end
    end
    
    def update
        # ?WORK TO DO
        # Currently just updates meal .... and does not do anything with meal_details 
        # May need to revisit to allow a change of meal_detail records
        if logged_in
            exercise = Exercise.find(params[:id])
            exercise.assign_attributes(exercise_params)
            if exercise.valid?
                exercise.save
            end
            render json: exercise
        end
    end

private

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