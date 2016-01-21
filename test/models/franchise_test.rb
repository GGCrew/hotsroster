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
end
