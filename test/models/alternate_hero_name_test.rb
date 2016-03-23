require 'test_helper'

class AlternateHeroNameTest < ActiveSupport::TestCase
	attributes = {
		name: 'Alternate Hero Name'
	}

	test "should not save alternate hero name without name" do
		alternate_hero_name = AlternateHeroName.new attributes.reject{|k,v| k == :name}
		assert_not alternate_hero_name.save
	end

	test "should save alternate hero name" do
		alternate_hero_name = AlternateHeroName.new attributes
		assert alternate_hero_name.save
	end
end
