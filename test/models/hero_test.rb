require 'test_helper'

class HeroTest < ActiveSupport::TestCase
	attributes = {
		name: 'Hero Name',
		slug: 'hero-slug',
		player_character_name: 'Player Character Name',
		franchise: Franchise.find_or_create_by(name: 'Hero Franchise Name', value: 'hero_franchise_value'),
		role: Role.find_or_create_by(name: 'Hero Role Name', slug: 'hero-role-slug'),
		typp: Typp.find_or_create_by(name: 'Hero Typp Name', slug: 'hero-typp-slug')
	}

	bogus_attributes = {
		name: 'Bogus Hero Name',
		slug: 'bogus-hero-slug',
		franchise: attributes[:franchise],
		role: attributes[:role],
		typp: attributes[:typp]
	}

	# Validation tests

	test "should not save hero without name" do
		hero = Hero.new attributes.reject{|k,v| k == :name}
		assert_not hero.save
	end

	test "should not save hero without slug" do
		hero = Hero.new attributes.reject{|k,v| k == :slug}
		assert_not hero.save
	end

	test "should not save hero without franchise" do
		hero = Hero.new attributes.reject{|k,v| k == :franchise}
		assert_not hero.save
	end

	test "should not save hero without role" do
		hero = Hero.new attributes.reject{|k,v| k == :role}
		assert_not hero.save
	end

	test "should not save hero without typp" do
		hero = Hero.new attributes.reject{|k,v| k == :typp}
		assert_not hero.save
	end

	test "show not save hero with duplicate name, slug, and player_character_name" do
		Hero.create! bogus_attributes.merge(name: attributes[:name], slug: attributes[:slug], player_character_name: attributes[:player_character_name])
		hero = Hero.new attributes
		assert_not hero.save
	end

	test "should save hero" do
		hero = Hero.new attributes
		assert hero.save
	end

	# Class method tests

	test 'should import from blizzard' do
		assert_instance_of Array, Hero.import_from_blizzard
	end

	test 'should return newest hero' do
		assert_instance_of Hero, Hero.newest
	end

	test 'should return percentage by franchise' do
		Franchise.all.each do |franchise|
			percentage = Hero.percentage_by_franchise(franchise)
			assert percentage.between?(0, 100)
		end
	end

	test 'should return percentage by role' do
		Role.all.each do |role|
			percentage = Hero.percentage_by_role(role)
			assert percentage.between?(0, 100)
		end
	end
	
	test 'should return percentage by typp' do
		Typp.all.each do |typp|
			percentage = Hero.percentage_by_typp(typp)
			assert percentage.between?(0, 100)
		end
	end

	test 'should return rotated heroes' do
		hero_ids = Roster.select(:hero_id).map(&:hero_id).uniq
		expected_heroes = Hero.find(hero_ids)
		assert_equal expected_heroes.count, Hero.rotated.count
		assert_empty expected_heroes - Hero.rotated
	end

	test 'should return unrotated heroes' do
		hero_ids = Roster.select(:hero_id).map(&:hero_id).uniq
		expected_heroes = Hero.all - Hero.find(hero_ids)
		assert_equal expected_heroes.count, Hero.unrotated.count
		assert_empty Hero.unrotated - expected_heroes
	end

	test 'should return launch heroes' do
		heroes = Hero.all
		min_release_date = heroes.map(&:release_date).min # Earliest release date will coincide with game launch
		expected_heroes = heroes.select{|hero| hero.release_date == min_release_date}
		assert_equal expected_heroes.count, Hero.launch_heroes.count
		assert_empty expected_heroes - Hero.launch_heroes
	end

	# Instance method tests

	test 'should return next hero' do
		heroes = Hero.distinct_heroes.order(:name)
		heroes.each_with_index do |hero, index|
			expected_index = index + 1
			expected_index = 0 if expected_index >= heroes.count
			expected_hero = heroes[expected_index]
			assert_equal hero.next, expected_hero
		end
	end

	test 'should return previous hero' do
		heroes = Hero.distinct_heroes.order(:name)
		heroes.each_with_index do |hero, index|
			expected_index = index - 1
			expected_index = (heroes.count - 1) if expected_index < 0
			expected_hero = heroes[expected_index]
			assert_equal hero.previous, expected_hero
		end
	end

	test 'should return hero\'s first rotation' do
		# Yes, this could be waaaay more efficient.
		# Intentionally doing a simple step-by-step Ruby-based process to test the (hopefully!) more efficient model code
		heroes = Hero.all
		heroes.each do |hero|
			rosters = Roster.where(hero: hero)
			unless rosters.empty?
				date_ranges = DateRange.find(rosters.map(&:date_range_id))

				# Omit any special events
				date_ranges.reject!{|i| i[:special_event]}

				unless date_ranges.empty?
					# Find the earliest start date and toss out any data with a more-recent start date
					min_start = date_ranges.map(&:start).min
					date_ranges.select!{|i| i[:start] == min_start}

					# Find the earliest end date within the subset
					min_end = date_ranges.map(&:end).min

					# Kludge for intermittent db:datetime-to-ruby:datetime-to-db:datetime bug
					expected_date_range = DateRange.find_by(start: min_start, end: min_end)
					expected_date_range = DateRange.find_by(start: min_start.to_date, end: min_end.to_date) unless expected_date_range

					assert_equal hero.first_rotation, expected_date_range
				else # date_ranges.empty?
					assert_nil hero.first_rotation
				end
			else # rosters.empty?
				assert_nil hero.first_rotation
			end
		end
	end

	test 'should return hero\'s most recent rotation' do
		# Yes, this could be waaaay more efficient.
		# Intentionally doing a simple step-by-step Ruby-based process to test the (hopefully!) more efficient model code
		heroes = Hero.all
		heroes.each do |hero|
			rosters = Roster.where(hero: hero)
			unless rosters.empty?
				date_ranges = DateRange.find(rosters.map(&:date_range_id))

				# Omit any special events
				date_ranges.reject!{|i| i[:special_event]}

				# Omit any future rotations
				date_ranges.reject!{|i| i[:start] > Date.today}

				unless date_ranges.empty?
					# Find the latest end date and toss out any data with an earlier end date
					max_end = date_ranges.map(&:end).max
					date_ranges.select!{|i| i[:end] == max_end}

					# Find the latest start date within the subset
					max_start = date_ranges.map(&:start).max

					expected_date_range = DateRange.find_by!(start: max_start, end: max_end)
					assert_equal hero.last_rotation, expected_date_range
				else
					assert_nil hero.last_rotation
				end
			else # rosters.empty?
				assert_nil hero.last_rotation
			end
		end
	end

	test 'should return weeks between hero release and first rotation' do
		heroes = Hero.all
		heroes.each do |hero|
			date_ranges = DateRange.find(Roster.where(hero: hero).map(&:date_range_id))

			# Omit special events
			date_ranges.reject!{|i| i[:special_event]}

			first_rotation = date_ranges.sort_by{|i| i[:start]}.first
			if first_rotation
				difference = first_rotation[:start] - hero.release_date
				weeks = difference / 1.week
				weeks = weeks.to_i
				assert_equal hero.weeks_between_release_and_first_rotation, weeks
			else
				assert_nil hero.weeks_between_release_and_first_rotation
			end
		end
	end

	test 'should return count of hero\'s rotations' do
		heroes = Hero.all
		heroes.each do |hero|
			rosters = Roster.where(hero: hero).to_a

			# Omit special events
			rosters.reject!{|i| i.date_range.special_event}
			# Omit future rotations
			rosters.reject!{|i| i.date_range.start.to_date > Date.today}

			roster_count = rosters.count
			assert_equal hero.rotations, roster_count
		end
	end

	test 'should return count of hero\'s rotations since the newest hero was released' do
		heroes = Hero.all
		newest_hero_release = heroes.where(['release_date <= :release_date', {release_date: Date.today}]).map(&:release_date).max
		date_ranges = DateRange.where('start >= :date', {date: newest_hero_release}).to_a

		# Omit special events
		date_ranges.reject!{|i| i.special_event}
		# Omit future rotations
		date_ranges.reject!{|i| i.start.to_date > Date.today}

		heroes.each do |hero|
			roster_count = Roster.where(hero: hero, date_range: date_ranges).count
			assert_equal hero.rotations_since_newest_hero_release, roster_count
		end
	end

	test 'should return count of hero\'s rotations since the latest change in roster size' do
		heroes = Hero.all

		latest_roster_size_change = Roster.date_range_of_latest_roster_size_change
		if latest_roster_size_change
			date_ranges = DateRange.where('start >= :date', {date: latest_roster_size_change[:start]}).to_a

			# Omit special events
			date_ranges.reject!{|i| i.special_event}
			# Omit future rotations
			date_ranges.reject!{|i| i.start.to_date > Date.today}

			heroes.each do |hero|
				roster_count = Roster.where(hero: hero, date_range: date_ranges).count
				assert_equal hero.rotations_since_latest_change_in_roster_size, roster_count
			end
		else
			assert_equal hero.rotations_since_latest_change_in_roster_size, 0
		end
	end

	test 'should return percentage of hero\'s rotations since game launch' do
		rotations = DateRange.all.to_a

		# Omit special events
		rotations.reject!{|i| i.special_event}
		# Omit future events
		rotations.reject!{|i| i.start.to_date > Date.today}

		rotation_count = rotations.count
		
		heros = Hero.all
		heros.each do |hero|
			hero_rotations = Roster.where(hero: hero).to_a

			# Omit special events
			hero_rotations.reject!{|i| i.date_range.special_event}
			# Omit future events
			hero_rotations.reject!{|i| i.date_range.start.to_date > Date.today}

			hero_rotation_count = hero_rotations.count
			expected_percentage = (hero_rotation_count.to_f / rotation_count) * 100
			assert_in_delta expected_percentage, hero.rotation_percentage_since_launch, 0.005 # Leave some wiggle room for rounding
		end
	end

	test 'should return percentage of hero\'s rotations since hero was released' do
		heros = Hero.all
		heros.each do |hero|
			rotations = DateRange.where('start >= :date', {date: hero.release_date}).to_a
			hero_rotations = Roster.where(hero: hero).to_a

			# Omit special events
			rotations.reject!{|i| i.special_event}
			hero_rotations.reject!{|i| i.date_range.special_event}

			# Omit future events
			rotations.reject!{|i| i.start.to_date > Date.today}
			hero_rotations.reject!{|i| i.date_range.start.to_date > Date.today}

			rotation_count = rotations.count
			hero_rotation_count = hero_rotations.count
			expected_percentage = (hero_rotation_count.to_f / rotation_count) * 100
			assert_in_delta expected_percentage, hero.rotation_percentage_since_release, 0.005 # Leave some wiggle room for rounding
		end
	end

	test 'should return percentage of hero\'s rotations since newest hero was released' do
		newest_hero = Hero.order(release_date: :asc).last
		date_ranges = DateRange.where('start >= :date', {date: newest_hero.release_date}).to_a
		date_ranges.reject!{|i| i.special_event}
		date_ranges.reject!{|i| i.start.to_date > Date.today}
		rotation_count = date_ranges.count

		heros = Hero.all
		heros.each do |hero|
			hero_rotation_count = Roster.where(hero: hero, date_range: date_ranges).count
			expected_percentage = (hero_rotation_count.to_f / rotation_count) * 100
			assert_in_delta expected_percentage, hero.rotation_percentage_since_newest_hero_release, 0.005 # Leave some wiggle room for rounding
		end
	end

	test 'should return percentage of hero\'s rotations since the latest change in roster size' do
		latest_change_in_roster_size = Roster.date_range_of_latest_roster_size_change
		date_ranges = DateRange.where('start >= :date', {date: latest_change_in_roster_size[:start].to_date}).to_a
		date_ranges.reject!{|i| i.special_event}
		date_ranges.reject!{|i| i.start.to_date > Date.today}
		rotation_count = date_ranges.count

		heros = Hero.all
		heros.each do |hero|
			hero_rotation_count = Roster.where(hero: hero, date_range: date_ranges).count
			expected_percentage = (hero_rotation_count.to_f / rotation_count) * 100
			assert_in_delta expected_percentage, hero.rotation_percentage_since_latest_change_in_roster_size, 0.005 # Leave some wiggle room for rounding
		end
	end


end
