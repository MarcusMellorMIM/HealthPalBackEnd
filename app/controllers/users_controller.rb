require 'json'
class UsersController < ApplicationController

    def show
        user = current_user
        if !user
            user=User.new
            hash={salutation:"Invalid user",
                speechtext:"Invalid user"}
        else 
            hash=user.getinteractivespeech
        end
        # I want to add a helper method in the user hash
        # The following is the only way I could think of doing this ....
        user_hash=hash.merge(user.attributes).slice!("password_digest")
        render json: user_hash

    end

    def summary 
        user = current_user
        start_date=request.headers["startDate"].to_date
        end_date=request.headers["endDate"].to_date
        iterations = (end_date - start_date).to_i + 1

        if user
            render json: user.caloriesummary(start_date, iterations)
        end 
    end

    def create
        user = User.create!(user_params)
        render json: user, except: [:password_digest]
    end

    def update
        user = current_user

        if current_user
            updateHash=user_params
            if params[:detail]["age_years"]
                newHash={}
                newHash["dob"]=Date.new(Date.current.year-params[:detail]["age_years"].to_i)
                updateHash=updateHash.merge(newHash)
            end

            user.assign_attributes(updateHash)
            if user.valid?
                user.save
            end
            user.reload

            # Used to create interaction with speech enabled devices
            hash=user.getinteractivespeech
            user_hash=hash.merge(user.attributes).slice!("password_digest")
            render json: user_hash

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