class Initial < ActiveRecord::Migration[5.2]
  def change

    create_table :users do |t|
      t.string :user_name
      t.string :password_digest
      t.string  :name
      t.datetime  :dob
      t.integer :height_cm
      t.string  :gender
      t.timestamps
    end

    create_table :weights do |t|
      t.integer :user_id
      t.float :weight_kg
      t.float :weight_units
      t.string :weight_uom
      t.datetime :weight_date
      t.timestamps
    end

    create_table :activity do |t|
      t.string :detail
      t.datetime :activity_date
      t.integer :user_id
      t.integer :activity_type_id
      t.timestamps
    end

    create_table :activity_details do |t|
      t.string   :name
      t.integer  :duration_min
      t.string   :photo_thumb    
      t.float    :unit_calories
      t.integer  :activity_id
      t.timestamps
    end

    create_table :inputs do |t|
      t.string :detail
      t.integer :user_id
      t.datetime :input_date
      t.integer :input_type_id
      t.timestamps
    end

    create_table :input_details do |t|
      t.string  :name
      t.integer :serving_unit
      t.integer :serving_qty
      t.integer :unit_grams   
      t.float   :unit_calories
      t.string  :photo_thumb
      t.integer :input_id
      t.timestamps
    end

    create_table :activity_types do |t|
      t.string :detail
      t.string :image
      t.timestamps
    end

    create_table :input_types do |t|
      t.string :detail
      t.string :image
      t.timestamps
    end
  end
end
