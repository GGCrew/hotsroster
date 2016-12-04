require 'test_helper'

class RosterTest < ActiveSupport::TestCase
	attributes = {
		hero: Hero.find_or_create_by(
			name: 'Roster Hero Name',
			slug: 'roster-hero-slug',
			franchise: Franchise.find_or_create_by(name: 'Hero Franchise Name', value: 'hero_franchise_value'),
			typp: Typp.find_or_create_by(name: 'Hero Typp Name', slug: 'hero-typp-slug')
		),
		date_range: DateRange.find_or_create_by(
			start: Date.today.to_datetime,
			end: Date.today.to_datetime + 1.week
		)
	}

	# Validation tests

	test "should not save roster without hero" do
		roster = Roster.new attributes.reject{|k,v| k == :hero}
		assert_not roster.save
	end	

	test "should not save roster without date_range" do
		roster = Roster.new attributes.reject{|k,v| k == :date_range}
		assert_not roster.save
	end	

	test "should not save roster with duplicate hero and date_range" do
		Roster.create attributes
		roster = Roster.new attributes
		assert_not roster.save
	end	

	# Model tests

	test 'should import from blizzard' do
		assert Roster.import_from_blizzard
	end

	test 'should return date range of latest roster size change' do
		date_ranges_and_roster_counts = Roster.joins(:date_range).group(:date_range).order('date_ranges.start ASC').count.map{|k,v| {date_range: k, count: v}}
		unless date_ranges_and_roster_counts.empty?
			# This algorithm will get progressively slower if the roster size doesn't change
			date_range_and_roster_count = nil # Defining outside the loop, otherwise the variable's scope is limited to the loop
			loop do
				date_range_and_roster_count = date_ranges_and_roster_counts.pop # Remove last item from array
				break if date_ranges_and_roster_counts.empty? # Exit if there aren't any more items!
				break unless date_range_and_roster_count[:count] == date_ranges_and_roster_counts.last[:count]
			end
			latest_roster_size_change = date_range_and_roster_count[:date_range]

			assert_instance_of DateRange, Roster.date_range_of_latest_roster_size_change
			assert_equal latest_roster_size_change, Roster.date_range_of_latest_roster_size_change
		else
			assert_nil Roster.date_range_of_latest_roster_size_change
		end	
	end

end
