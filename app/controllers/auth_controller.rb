class AuthController < ApplicationController
    def create
      user = User.find_by(user_name: params[:user_name])
      if user && user.authenticate(params[:password])
        payload = {user_id: user.id}
        token = issue_token(payload)
        render json: { jwt: token, user: user }
      else
        render json: { error: "Login failed." }
      end
    end
  
    def show
      if logged_in
        render json: current_user
      else 
        render json: {error: "Incorrect token."}
      end
    end
  end
  