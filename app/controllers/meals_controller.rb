class MealsController < ApplicationController
    
    def index
        user = current_user
        if user
            meals = user.meals

            render json: meals, except: [:created_at],
                include: [ :meal_details ]
        end
    end

    def show
        if logged_in
            meal = Meal.find(params[:id])
            render json: meal
        end
    end

    def create
# WORK TO DO -- FIGURE OUT HOW TO USE PERMIT PARAMS WITH A LARGE HASH ARRAY
        user = current_user
        if user
            detail=params[:detail][:detail]
            meal_type_id=params[:detail][:meal_type_id]
            meal_date=params[:detail][:meal_date]
            meal_date_d=params[:detail][:meal_date_d]
            meal_date_t=params[:detail][:meal_date_t]

            # Probably long winded, but this allows for a null date
            # to default to today, and a null time to default to now.
            # So if a user enters a date, and no time ... time is set
            # if time and no date, the time goes against today etc etc
            if meal_date_d==nil
                meal_date_d=Date.current.to_s
            end
            if meal_date_t==nil
                meal_date_t=Time.current.strftime("%H:%M")
            end
            meal_date = (meal_date_d + ' ' + meal_date_t).to_datetime

            # Just in case the person has not selected this -- its mandatory
            if meal_type_id==nil
                meal_type_id=1
            end

            # Create the meal
            meal = Meal.create(user_id:user.id, detail:detail, meal_type_id:meal_type_id, meal_date:meal_date )

            # Now create the meal detail records from the super huuuuge hash
            params[:detail][:meal_details].map { |f|    
                mealdetail=MealDetail.create(
                    meal_id:meal.id,
                    food_name:f[:food_name],
                    unit_calories:f[:unit_calories],           
                    serving_unit:f[:serving_unit],
                    serving_qty:f[:serving_qty],
                    unit_grams:f[:unit_grams],
                    photo_thumb:f[:photo][:thumb]
                )
            }

            render json: meal, except: [:created_at],
                    include: :meal_details
        end
    end

    def destroy
        if logged_in
            meal = Meal.find(params[:id]);
            meal.meal_details.destroy;
            meal.destroy;
        end
    end
    
    def update        
        if logged_in
            # Should be a shared helper as it is very similar to the insert
            meal = Meal.find(params[:id])
            # If a real meal
            if meal 
                # WORKTODO DRY DRY DRY DRY GOD DAMMIT
                detail=params[:detail][:detail]
                meal_type_id=params[:detail][:meal_type_id]
                meal_date=params[:detail][:meal_date]
                meal_date_d=params[:detail][:meal_date_d]
                meal_date_t=params[:detail][:meal_date_t]
                if meal_date_d==nil
                    meal_date_d=Date.current.to_s
                end
                if meal_date_t==nil
                    meal_date_t=Time.current.strftime("%H:%M")
                end
                meal_date = (meal_date_d + ' ' + meal_date_t).to_datetime
                # Just in case the person has not selected this -- its mandatory
                if meal_type_id==nil
                    meal_type_id=1
                end

                # Update the meal
                meal.update( detail:detail, meal_type_id:meal_type_id, meal_date:meal_date )
                if meal.valid?
                    meal.save
                    meal.meal_details.destroy_all

                    params[:detail][:meal_details].map { |f|    
                        mealdetail=MealDetail.create(
                            meal_id:meal.id,
                            food_name:f[:food_name],
                            unit_calories:f[:unit_calories],           
                            serving_unit:f[:serving_unit],
                            serving_qty:f[:serving_qty],
                            unit_grams:f[:unit_grams],
                            photo_thumb:f[:photo_thumb]
                        )
                    }
            
                end

                render json: meal, except: [:created_at],
                    include: :meal_details

            end
        end
    end

private

    def meal_params
# WORK TO DO
# NEED TO ADD IN THE DETAILS SO THE CREATE WORKS
# CURRENTLY AN ISSUE AS DETAILS IS AN ARRAY, AND 
# PHOTO IS A HASH IN THE ARRAY
        params.require(:detail).permit(
            :id,
            :user_id,
            :detail,
            :meal_date,
            :meal_date_d,
            :meal_date_t,
            :meal_type_id,
            :totalCalories
            )
    end

end