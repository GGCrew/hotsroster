require 'test_helper'

class FranchiseTest < ActiveSupport::TestCase
	attributes = {
		name: 'Franchise Name',
		value: 'Franchise Value'
	}

	test 'should not save franchise without name' do
		franchise = Franchise.new attributes.reject{|k,v| k == :name}
		assert_not franchise.save
	end

	test 'should not save franchise without value' do
		franchise = Franchise.new attributes.reject{|k,v| k == :value}
		assert_not franchise.save
	end

	test 'should save franchise' do
		franchise = Franchise.new attributes
		assert franchise.save
	end
end
