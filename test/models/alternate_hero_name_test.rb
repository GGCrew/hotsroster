require 'test_helper'

class AlternateHeroNameTest < ActiveSupport::TestCase
	attributes = {
		name: 'Alternate Hero Name'
	}

	# Validation tests
	test "should not save alternate hero name without name" do
		alternate_hero_name = AlternateHeroName.new attributes.reject{|k,v| k == :name}
		assert_not alternate_hero_name.save
	end

	test "should save alternate hero name" do
		alternate_hero_name = AlternateHeroName.new attributes
		assert alternate_hero_name.save
	end

	# Scope tests
	test "should not find any orphans" do
		assert_empty AlternateHeroName.orphans
	end

	test "should find orphans" do
		expected_orphans = []
		(1..5).each do |index|
			expected_orphans << AlternateHeroName.create!(name: "Orphan Alternate Hero Name #{index}")
		end

		assert_not_equal 0, AlternateHeroName.orphans.count
		assert_equal expected_orphans.length, AlternateHeroName.orphans.length
		assert_empty expected_orphans - AlternateHeroName.orphans
	end
end
