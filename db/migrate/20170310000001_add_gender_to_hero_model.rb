class AddGenderToHeroModel < ActiveRecord::Migration
  def change
  	add_column	'heros', 'gender', :string, after: 'player_character_name'
  end
end
