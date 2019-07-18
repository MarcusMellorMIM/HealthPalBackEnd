class WeightsController < ApplicationController

    def index
        user = current_user
        if user
            weights = user.weights
            render json: weights
        end
    end

    def show
        if logged_in
            weight = Weight.find(params[:id])
        else
            weight = Weight.new
        end
        render json: weight
    end

    def create
    # As we want to manipulate weight_date ... using the permitted params method
    # seems to cause issues - ideally I would like to set the date, and use weight_params
        user=current_user;
        if user
            weight_kg=params[:detail][:weight_kg]
        # Dodgy method of sorting out the date
            weight_date_d=params[:detail][:weight_date_d];
            weight_date_t=params[:detail][:weight_date_t];
            if weight_date_d==nil || weight_date_d==""
                weight_date_d=Date.current.to_s
            end
            if weight_date_t==nil || weight_date_t==""
                weight_date_t=Time.current.strftime("%H:%M")
            end        
            weight_date = (weight_date_d + ' ' + weight_date_t).to_datetime

            weight = Weight.create( user_id:user.id,
                        weight_kg:weight_kg,
                        weight_date:weight_date)

        else
            weight = Weight.new
        end 

        render json: weight

    end

    def destroy
        if logged_in
            weight = Weight.find(params[:id]);
            weight.destroy;
        end
    end
    
    def update
# Really dodgy method of dealing with dates ... there has to be a better way
        if logged_in
            weight = Weight.find(params[:detail][:id])
            weight_kg = params[:detail][:weight_kg]
            weight_date_d = params[:detail][:weight_date_d]
            weight_date_t = params[:detail][:weight_date_t]
            if weight_date_d==nil || weight_date_d==""
                weight_date_d=Date.current.to_s
            end
            if weight_date_t==nil || weight_date_t==""
                weight_date_t=Time.current.strftime("%H:%M")
            end        
            weight_date = (weight_date_d + ' ' + weight_date_t).to_datetime

            weight.assign_attributes( weight_kg:weight_kg,
                        weight_date:weight_date)

            if weight.valid?
                weight.save
            end
            render json: weight
        end
    end

private

    def weight_params
        params.require(:detail).permit(:id,
            :user_id,
            :weight_kg,
            :weight_date)
    end

end