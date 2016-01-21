require 'test_helper'

class HeroTest < ActiveSupport::TestCase
	attributes = {
		name: 'Hero Name',
		slug: 'hero-slug',
		franchise: Franchise.create!(name: 'Hero Franchise Name', value: 'hero_franchise_value'),
		role: Role.create!(name: 'Hero Role Name', slug: 'hero-role-slug'),
		typp: Typp.create!(name: 'Hero Typp Name', slug: 'hero-typp-slug')
	}

	test "should not save hero without name" do
		p attributes
		hero = Hero.new attributes.reject{|k,v| k == :name}
		assert_not hero.save
	end

	test "should not save hero without slug" do
		hero = Hero.new attributes.reject{|k,v| k == :slug}
		assert_not hero.save
	end

	test "should save hero" do
		hero = Hero.new attributes
		assert hero.save
	end
end
