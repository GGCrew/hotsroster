class ImportHeroRoleData < ActiveRecord::Migration
  def up
		Hero.all.each do |hero|
			attributes = {hero_id: hero.id, role_id: hero.role_id}
			hero_role = HeroRole.where(attributes).first
			HeroRole.create!(attributes) if hero_role.nil?
		end
  end

	def down
		Hero.all.each do |hero|
			hero_role = HeroRole.where(hero_id: hero.id).first
			hero.update!(role_id: hero_role.role_id) unless hero_role.nil?
		end
	end
end

