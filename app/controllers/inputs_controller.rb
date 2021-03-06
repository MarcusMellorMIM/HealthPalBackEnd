class InputsController < ApplicationController
    
    def index
        user = current_user
        if user
            inputs = user.inputs
            render json: inputs, except: [:created_at],
                include: [ :input_details ]
        end
    end

    def show
        user = current_user
        if user
            if params[:id]=='last'
                input = user.inputs.all.last
            else 
                input = user.inputs.find(params[:id])
            end
            if input
                hash = input.getinteractivespeech
                input_hash=hash.merge(input.attributes)
                input_hash=input_hash.merge({ input_details:input.input_details.map {|id| id.attributes }})

                render json: input_hash
            end
        end
    end

    def create
# WORK TO DO -- FIGURE OUT HOW TO USE PERMIT PARAMS WITH A LARGE HASH ARRAY

        user = current_user
        if user
            detail=params[:detail][:detail]
            input_type_id=params[:detail][:input_type_id]
            input_date=get_date(params[:detail][:input_date_d], params[:detail][:input_date_t])

            # Just in case the person has not selected this -- its mandatory
            if input_type_id==nil || input_type_id==""
                input_type_id=1
            end

            # Now get the meal detail records from the super huuuuge hash depending on whether from 
            # website app or some other device which will not have seperated the process
            if params[:detail][:alexa]
                api= Nutritionixapi.new
                input_details=api.get_inputinfo(detail)    
            else
                input_details = params[:detail][:input_details]
            end

            # Now create the meal and associated details
            if input_details.length>0
                # Create the meal
                input = Input.create(user_id:user.id, 
                    detail:detail, 
                    input_type_id:input_type_id, 
                    input_date:input_date )
                # Create the meal details
                create_inputdetails( input, input_details )
                hash = input.getinteractivespeech
                input_hash=hash.merge(input.attributes)
                input_hash=input_hash.merge({ input_details:input.input_details.map {|id| id.attributes }})
                
            else
                input_hash = { salutation:"",
                    speechcongrats:"Oh dear,",
                    speechtext:"I could not calculate the calories for " + detail + ", please try again, by saying add meal "
                }      
            end
                        
            render json: input_hash



        end
    end

    def destroy
        user = current_user
        if user
            if params[:id]=="last"
                input=user.inputs.last
            else 
                input = user.inputs.find(params[:id]);
            end 

            if input
                input_hash=(input.attributes)
                input.input_details.destroy;
                input.destroy;
                hash = user.getinteractivespeech
                input_hash=input_hash.merge(hash)

                render json: input_hash
            end

        end
    end
    
    def update
        user = current_user        
        if user
            # Should be a shared helper as it is very similar to the insert
            input = user.inputs.find(params[:id])
            # If a real meal
            if input 
                detail=params[:detail][:detail]
                input_type_id=params[:detail][:input_type_id]
                input_date=get_date(params[:detail][:input_date_d], params[:detail][:input_date_t])

                # Just in case the person has not selected this -- its mandatory
                if input_type_id==nil
                    input_type_id=1
                end

                # Update the meal NOT BEEN TESTED YET ... SO BEWARE WHEN LINKING TO WEBSITE
                input.update( detail:detail, input_type_id:input_type_id, input_date:input_date )
                if input.valid?
                    input.input_details.destroy_all                   
                    create_inputdetails( input, params[:detail][:input_details] )
                    input.save            
                end

                render json: input, except: [:created_at],
                    include: :input_details

            end
        end
    end

private

    def create_inputdetails( input, input_details )
    # I want the total calories rendered in the input object ... the only way 
    # I can figure out how to do this at the moment, is to save in the db
    # If I can resolve the render ... I can get rid of this, and just use helpers

    calories=0
        # Just in case something goes wrong .. this prevents a crash
        if input_details.kind_of?(Array) 

            input_details.map { |f|
                calories+=(f[:serving_qty].to_f * f[:unit_calories].to_f).to_i
                inputdetail=InputDetail.create(
                    input_id:input.id,
                    name:f[:name],
                    unit_calories:f[:unit_calories],           
                    serving_unit:f[:serving_unit],
                    serving_qty:f[:serving_qty],
                    unit_grams:f[:unit_grams],
                    photo_thumb:f[:photo_thumb]
                )
            }

        end

        input.reload
        input.update(calories:calories)
        input.save

    end 

    def input_params
# WORK TO DO
# NEED TO ADD IN THE DETAILS SO THE CREATE WORKS
# CURRENTLY AN ISSUE AS DETAILS IS AN ARRAY, AND 
# PHOTO IS A HASH IN THE ARRAY
        params.require(:detail).permit(
            :id,
            :user_id,
            :detail,
            :input_date,
            :input_date_d,
            :input_date_t,
            :input_type_id,
            :totalCalories
            )
    end

end