require 'test_helper'

class HeroTest < ActiveSupport::TestCase
	attributes = {
		name: 'Hero Name',
		slug: 'hero-slug',
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

	test "show not save hero with duplicate name" do
		Hero.create! bogus_attributes.merge(name: attributes[:name])
		hero = Hero.new attributes
		assert_not hero.save
	end

	test "show not save hero with duplicate slug" do
		Hero.create! bogus_attributes.merge(slug: attributes[:slug])
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
		flunk
	end

	test 'should return unrotated heroes' do
		flunk
	end

	test 'should return launch heroes' do
		flunk
	end

	# Instance method tests

	test 'should return next hero' do
		heroes = Hero.order(:name)
		heroes.each_with_index do |hero, index|
			expected_index = index + 1
			expected_index = 0 if expected_index >= heroes.count
			expected_hero = heroes[expected_index]
			assert_equal hero.next, expected_hero
		end
	end

	test 'should return previous hero' do
		heroes = Hero.order(:name)
		heroes.each_with_index do |hero, index|
			expected_index = index - 1
			expected_index = (heroes.count - 1) if expected_index < 0
			expected_hero = heroes[expected_index]
			assert_equal hero.previous, expected_hero
		end
	end

	test 'should return hero\'s first rotation' do
		# Yes, this could be waaaay more efficient.
		# Intentionally doing a simple step-by-step Ruby-based process to test the (hopefully!) more effiecient model code
		heroes = Hero.all
		heroes.each do |hero|
			rosters = Roster.where(hero: hero)
			unless rosters.empty?
				date_ranges = DateRange.find(rosters.map(&:date_range_id))

				# Find the earliest start date and toss out any data with a more-recent start date
				min_start = date_ranges.map(&:start).min
				date_ranges.select!{|i| i[:start] == min_start}

				# Find the earliest end date within the subset
				min_end = date_ranges.map(&:end).min

				expected_date_range = DateRange.find_by!(start: min_start, end: min_end)
				assert_equal hero.first_rotation, expected_date_range
			else # rosters.empty?
				assert_nil hero.first_rotation
			end
		end
	end

	test 'should return hero\s most recent rotation' do
		# Yes, this could be waaaay more efficient.
		# Intentionally doing a simple step-by-step Ruby-based process to test the (hopefully!) more effiecient model code
		heroes = Hero.all
		heroes.each do |hero|
			rosters = Roster.where(hero: hero)
			unless rosters.empty?
				date_ranges = DateRange.find(rosters.map(&:date_range_id))

				# Find the latest end date and toss out any data with an earlier end date
				max_end = date_ranges.map(&:end).max
				date_ranges.select!{|i| i[:end] == max_end}

				# Find the latest start date within the subset
				max_start = date_ranges.map(&:start).max

				expected_date_range = DateRange.find_by!(start: max_start, end: max_end)
				assert_equal hero.last_rotation, expected_date_range
			else # rosters.empty?
				assert_nil hero.last_rotation
			end
		end
	end

	test 'should return weeks between release and first rotation' do
		flunk
	end

	test 'should return count of hero\'s rotations' do
		heroes = Hero.all
		heroes.each do |hero|
			roster_count = Roster.where(hero: hero).count
			assert_equal hero.rotations, roster_count
		end
	end

	test 'should return count of hero\'s rotations since the newest hero was released' do
		heroes = Hero.all
		newest_hero_release = heroes.map(&:release_date).max
		date_ranges = DateRange.where('start >= :release_date', {release_date: newest_hero_release})
		heroes.each do |hero|
			roster_count = Roster.where(hero: hero, date_range: date_ranges).count
			assert_equal hero.rotations_since_newest_hero_release, roster_count
		end
	end

	test 'should return count of hero\'s rotations since the latest change in roster size' do
		heroes = Hero.all

		date_ranges_and_roster_counts = Roster.joins(:date_range).group(:date_range).order('date_ranges.start ASC').count.map{|k,v| {date_range: k, count: v}}
		unless date_ranges_and_roster_counts.empty?
			# This algorithm will get progressively slower if the roster size doesn't change
			date_range_and_roster_count = nil # Defining outside the loop, otherwise the variable's scope is limited to the loop
			loop do
				date_range_and_roster_count = date_ranges_and_roster_counts.pop # Remove last item from array
				break if date_ranges_and_roster_counts.empty? # Exit if there aren't any more items!
				break unless date_range_and_roster_count[:count] == date_ranges_and_roster_counts.last[:count]
			end	

			latest_roster_size_change = date_range_and_roster_count[:date_range][:start]
			date_ranges = DateRange.where('start >= :roster_size_change_date', {roster_size_change_date: latest_roster_size_change})
			heroes.each do |hero|
				roster_count = Roster.where(hero: hero, date_range: date_ranges).count
				assert_equal hero.rotations_since_latest_change_in_roster_size, roster_count
			end
		else
			assert_equal hero.rotations_since_latest_change_in_roster_size, 0
		end
	end

	test 'should return percentage of hero\'s rotations since game launch' do
		flunk
	end

	test 'should return percentage of hero\'s rotations since hero was released' do
		flunk
	end

	test 'should return percentage of hero\'s rotations since newest hero was released' do
		flunk
	end

	test 'should return percentage of hero\'s rotations since the latest change in roster size' do
		flunk
	end


end
