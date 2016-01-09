module ApplicationHelper

	def rotations_since_launch(hero)
		hero.date_ranges.count
	end

	def rotation_percentage_since_launch(hero)
		(hero.date_ranges.count / DateRange.count.to_f * 100).round(2)
	end

	def rotations_since_release(hero)
		conditions = ['start >= :hero_date', {hero_date: hero.release_date}]
		hero.date_ranges.where(conditions).count
	end

	def rotation_percentage_since_release(hero)
		conditions = ['start >= :hero_date', {hero_date: hero.release_date}]
		(hero.date_ranges.where(conditions).count / DateRange.where(conditions).count.to_f * 100).round(2)
	end

	def rotations_since_newest_hero_release(hero)
		conditions = ['start >= :hero_date', {hero_date: Hero.newest.release_date}]
		hero.date_ranges.where(conditions).count
	end

	def rotation_percentage_since_newest_hero_release(hero)
		conditions = ['start >= :hero_date', {hero_date: Hero.newest.release_date}]
		(hero.date_ranges.where(conditions).count / DateRange.where(conditions).count.to_f * 100).round(2)
	end

end
