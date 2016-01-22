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

	# Method tests

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
end
