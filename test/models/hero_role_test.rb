require 'test_helper'

class HeroRoleTest < ActiveSupport::TestCase
	attributes = {
		hero: Hero.find_or_create_by(
			name: 'HeroRole Hero Name',
			slug: 'herorole-hero-slug',
			franchise: Franchise.find_or_create_by(name: 'HeroRole Franchise Name', value: 'herorole_franchise_value'),
			typp: Typp.find_or_create_by(name: 'HeroRole Typp Name', slug: 'herorole-typp-slug')
		),
		role: Role.find_or_create_by(
			name: 'HeroRole Role Name',
			slug: 'herorole-role-slug'
		)
	}

	# Validation tests

	test "should not save herorole without hero" do
		herorole = HeroRole.new attributes.reject{|k,v| k == :hero}
		assert_not herorole.save
	end	

	test "should not save herorole without role" do
		herorole = HeroRole.new attributes.reject{|k,v| k == :role}
		assert_not herorole.save
	end	

	test "should not save herorole with duplicate hero and role" do
		HeroRole.create attributes
		herorole = HeroRole.new attributes
		assert_not herorole.save
	end	

	# Model tests

	# no model methods to test

end
