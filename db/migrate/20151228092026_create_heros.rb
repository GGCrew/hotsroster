class CreateHeros < ActiveRecord::Migration
  def change
    create_table :heros do |t|
			t.string	:name
			t.string	:title
			t.string	:slug

			t.integer	:role_id
			t.integer	:type_id
			t.integer	:franchise_id
			
      t.timestamps null: false
    end
  end
end
