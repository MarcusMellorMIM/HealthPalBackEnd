class UsersController < ApplicationController

    def show
        user = current_user
        if user
            render json: user
        end
    end

    def create
        user = User.create!(user_params)
        render json: user
    end

    def update
        user = current_user
        if current_user
            user.assign_attributes(user_params)
            if user.valid?
                user.save
            end
            render json: user
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