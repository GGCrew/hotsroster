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
end
