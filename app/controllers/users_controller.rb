require 'json'
class UsersController < ApplicationController

    def show
        user = current_user
        if !user
            user=User.new
        end

        render json: user, except: [:password_digest]

    end

    def summary 
        user = current_user
        start_date=request.headers["startDate"]
        end_date=request.headers["startDate"]
        if user
            render json: request.headers["startDate"]
#            render json: user.caloriesummary
        end 
    end

    def create
        user = User.create!(user_params)
        render json: user, except: [:password_digest]
    end

    def update
        user = current_user
        if current_user
            user.assign_attributes(user_params)
            if user.valid?
                user.save
            end
            render json: user, except: [:password_digest]
        end
    end

private

    def user_params
        params.require(:detail).permit(
                    :user_name,
                    :email,
                    :name,
                    :dob,
                    :height_cm,
                    :password,
                    :weight,
                    :gender)
        end

end