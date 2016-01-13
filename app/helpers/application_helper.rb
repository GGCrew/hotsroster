module ApplicationHelper

	def rotations_since_launch(hero)
		hero.date_ranges.count
	end

	def rotation_percentage_since_launch(hero)
		(hero.date_ranges.count / DateRange.count.to_f * 100).round(2)
	end

	def rotations_since_latest_change_in_roster_size(hero)
		conditions = ['start >= :roster_date', {roster_date: Roster.date_of_latest_roster_size_change.start}]
		hero.date_ranges.where(conditions).count
	end

	def rotation_percentage_since_latest_change_in_roster_size(hero)
		conditions = ['start >= :roster_date', {roster_date: Roster.date_of_latest_roster_size_change.start}]
		(hero.date_ranges.where(conditions).count / DateRange.where(conditions).count.to_f * 100).round(2)
	end

	def rotations_since_release(hero)
		conditions = ['start >= :release_date', {release_date: hero.release_date}]
		hero.date_ranges.where(conditions).count
	end

	def rotation_percentage_since_release(hero)
		conditions = ['start >= :release_date', {release_date: hero.release_date}]
		(hero.date_ranges.where(conditions).count / DateRange.where(conditions).count.to_f * 100).round(2)
	end

	def rotations_since_newest_hero_release(hero)
		conditions = ['start >= :newest_hero_date', {newest_hero_date: Hero.newest.release_date}]
		hero.date_ranges.where(conditions).count
	end

	def rotation_percentage_since_newest_hero_release(hero)
		conditions = ['start >= :newest_hero_date', {newest_hero_date: Hero.newest.release_date}]
		(hero.date_ranges.where(conditions).count / DateRange.where(conditions).count.to_f * 100).round(2)
	end

	def format_date_range(date_range)
		return "#{date_range.start.to_s(:shortish)} — #{date_range.end.to_s(:shortish)}"
	end

	def count_of_heroes_in_franchise(heroes, franchise)
		return heroes.where(franchise: franchise).count
	end

	def percent_of_heroes_in_franchise(heroes, franchise)
		return ((heroes.where(franchise: franchise).count.to_f / heroes.count) * 100).round(2)
	end

	def count_of_heroes_by_role(heroes, role)
		return heroes.where(role: role).count
	end

	def percent_of_heroes_by_role(heroes, role)
		return ((heroes.where(role: role).count.to_f / heroes.count) * 100).round(2)
	end

	def count_of_heroes_by_typp(heroes, typp)
		return heroes.where(typp: typp).count
	end

	def percent_of_heroes_by_typp(heroes, typp)
		return ((heroes.where(typp: typp).count.to_f / heroes.count) * 100).round(2)
	end
end
