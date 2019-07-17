class ApplicationController < ActionController::API

    def issue_token(payload)
        
        JWT.encode(payload, ENV['FITBOOK_SECRET'])
       
      end 
      
      def decode_token(token)
     
        JWT.decode(token, ENV['FITBOOK_SECRET'])[0]
        
      end

      def get_token
        request.headers["Authorization"]
      end

      def current_user
        token = get_token
        if token
          decoded_token = decode_token(token)
          user = User.find(decoded_token["user_id"])
          return user
        end
      end
      
      def logged_in
        !!current_user
      end
    
    
end
