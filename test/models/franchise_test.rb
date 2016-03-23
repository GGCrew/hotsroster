require 'test_helper'

class FranchiseTest < ActiveSupport::TestCase
	attributes = {
		name: 'Franchise Name',
		value: 'Franchise Value'
	}

	bogus_attributes = {
		name: 'Bogus Franchise Name',
		value: 'Bogus Franchise Value'
	}

	# Validation tests

	test 'should not save franchise without name' do
		franchise = Franchise.new attributes.reject{|k,v| k == :name}
		assert_not franchise.save
	end

	test 'should not save franchise without value' do
		franchise = Franchise.new attributes.reject{|k,v| k == :value}
		assert_not franchise.save
	end

	test 'should not save franchise with duplicate name' do
		Franchise.create bogus_attributes.merge(name: attributes[:name])
		franchise = Franchise.new attributes
		assert_not franchise.save
	end

	test 'should not save franchise with duplicate value' do
		Franchise.create bogus_attributes.merge(value: attributes[:value])
		franchise = Franchise.new attributes
		assert_not franchise.save
	end

	test 'should save franchise' do
		franchise = Franchise.new attributes
		assert franchise.save
	end

	# Method tests

	test 'should import from blizzard' do
		assert Franchise.import_from_blizzard
	end

	test 'should import from json' do
		assert Franchise.import_from_json([attributes[:value], bogus_attributes[:value]])
	end

	test 'should import from empty json' do
		assert Franchise.import_from_json([])
	end
end
