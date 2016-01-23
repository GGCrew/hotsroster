require 'test_helper'

class TyppTest < ActiveSupport::TestCase
	attributes = {
		name: 'Typp Name',
		slug: 'Typp Slug'
	}

	bogus_attributes = {
		name: 'Bogus Typp Name',
		slug: 'Bogus Typp Slug'
	}

	# Validation tests

	test 'should not save typp without name' do
		typp = Typp.new attributes.reject{|k,v| k == :name}
		assert_not typp.save
	end

	test 'should not save typp without slug' do
		typp = Typp.new attributes.reject{|k,v| k == :slug}
		assert_not typp.save
	end

	test 'should not save typp with duplicate name' do
		Typp.create bogus_attributes.merge(name: attributes[:name])
		typp = Typp.new attributes
		assert_not typp.save
	end

	test 'should not save typp with duplicate slug' do
		Typp.create bogus_attributes.merge(slug: attributes[:slug])
		typp = Typp.new attributes
		assert_not typp.save
	end

	test 'should save typp' do
		typp = Typp.new attributes
		assert typp.save
	end

	# Model tests

	test 'should import from json' do
		flunk
	end
end
