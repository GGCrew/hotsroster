require 'test_helper'

class RosterTest < ActiveSupport::TestCase
	attributes = {
		hero: Hero.find_or_create_by(
			name: 'Roster Hero Name',
			slug: 'roster-hero-slug',
			franchise: Franchise.find_or_create_by(name: 'Hero Franchise Name', value: 'hero_franchise_value'),
			role: Role.find_or_create_by(name: 'Hero Role Name', slug: 'hero-role-slug'),
			typp: Typp.find_or_create_by(name: 'Hero Typp Name', slug: 'hero-typp-slug')
		),
		date_range: DateRange.find_or_create_by(
			start: Date.today.to_datetime,
			end: Date.today.to_datetime + 1.week
		)
	}

	# Validatino tests

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
		flunk
	end

	test 'should return date range of latest roster size change' do
		flunk
	end

end
