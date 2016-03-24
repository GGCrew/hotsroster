class Chogall < ActiveRecord::Migration
  def change
  	add_column	'heros', 'player_character_name', :string, after: 'name'

		reversible do |direction|
			direction.up do
				Hero.all.each{|hero| hero.update!(player_character_name: hero.name)}

				cho = Hero.find_by(slug: "chogall")
				gall = cho.dup

				cho.update!(player_character_name: 'Cho')
				gall.update!(player_character_name: 'Gall', role_id: Role.find_by(slug: 'assassin').id, typp_id: Typp.find_by(slug: 'ranged').id)
			end

			direction.down do
				chogall = Hero.find_by(slug: "chogall")
				chogall.update!(player_character_name: "Cho'gall")
				Hero.where(slug: 'chogall').where.not(id: chogall.id).destroy_all
			end
		end
	end
end
