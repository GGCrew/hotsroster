class Chogall < ActiveRecord::Migration
  def up
		Hero.all.each{|hero| hero.update!(player_character_name: hero.name)}

		cho = Hero.find_by(slug: "chogall")
		if cho  # Hero model is empty unless "rails runner scripts/import_from_blizzard.rb" has already run
			gall = cho.dup

			cho.update!(player_character_name: 'Cho')

			if gall.respond_to?(:role_id)
				# If multiclass migration has not been applied
				gall.update!(player_character_name: 'Gall', role_id: Role.find_by(slug: 'assassin').id, typp_id: Typp.find_by(slug: 'ranged').id)
			end
			if gall.respond_to?(:hero_roles)
				# If multiclass migration has been applied
				gall.update!(player_character_name: 'Gall', typp_id: Typp.find_by(slug: 'ranged').id)
				gall.hero_roles.create!(role_id: Role.find_by(slug: 'assassin').id)
			end

		end
	end
	
	def down
		chogall = Hero.find_by(slug: "chogall")
		chogall.update!(player_character_name: "Cho'gall")
		Hero.where(slug: 'chogall').where.not(id: chogall.id).destroy_all
	end
end
