class AddPlayerCharacterNameToHeroes < ActiveRecord::Migration
  def change
  	add_column	'heros', 'player_character_name', :string, after: 'name'
  end
end
