class CreateRosters < ActiveRecord::Migration
  def change
    create_table :rosters do |t|
			t.integer	:hero_id
			t.integer	:date_range_id
			t.integer	:player_level

      t.timestamps null: false
    end
  end
end
