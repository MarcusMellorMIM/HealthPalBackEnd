class AuthController < ApplicationController

    def create
      user = User.find_by(user_name: params[:user_name])
      if user && user.authenticate(params[:password])
        payload = {user_id: user.id}
        token = issue_token(payload)
        hash=user.getinteractivespeech
        user_hash=hash.merge(user.attributes).slice!("password_digest")
        # render json: user_hash
        render json: { jwt: token, user: user_hash }
      else
        render json: { error: "Login failed." }
      end
    end
  
    def show
      if logged_in
            hash=current_user.getinteractivespeech
            user_hash=hash.merge(current_user.attributes).slice!("password_digest")
            render json: user_hash
      else 
        render json: {error: "Incorrect token."}
      end
    end
  end
  