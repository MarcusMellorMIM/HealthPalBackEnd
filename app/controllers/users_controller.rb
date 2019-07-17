class UsersController < ApplicationController

    def show
        user = current_user
        # user = User.where(["user_name=?",params[:id]]).first
        if user
            render json: user
        end
       
        # Current design seperates the gets ... ?? best practice ??
        #     ,
        # include: [:weights]
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