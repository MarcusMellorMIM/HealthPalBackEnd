class ApplicationController < ActionController::API

  # Token methods used by all controllers
    def issue_token(payload)
        JWT.encode(payload, ENV['HEALTHPAL_SECRET'])
      end 
      
      def decode_token(token)     
        JWT.decode(token, ENV['HEALTHPAL_SECRET'])[0]
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

    # Generic helpers used by more than one controller


    def get_date( input_date_d, input_date_t)
        # Probably long winded, but this allows for a null date
        # to default to today, and a null time to default to now.
        # So if a user enters a date, and no time ... time is set
        # if time and no date, the time goes against today etc etc
      if input_date_d==nil || input_date_d==""
        input_date_d=Date.current.to_s
      end
      if input_date_t==nil || input_date_t == ""
        input_date_t=Time.current.strftime("%H:%M")
      end
      # Now return the full date
      (input_date_d + ' ' + input_date_t).to_datetime
    end

end
