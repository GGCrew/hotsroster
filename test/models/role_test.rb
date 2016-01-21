require 'test_helper'

class RoleTest < ActiveSupport::TestCase
	attributes = {
		name: 'Role Name',
		slug: 'Role Slug'
	}

	bogus_attributes = {
		name: 'Bogus Role Name',
		slug: 'Bogus Role Slug'
	}
	
	test 'should not save role without name' do
		role = Role.new attributes.reject{|k,v| k == :name}
		assert_not role.save
	end

	test 'should not save role without slug' do
		role = Role.new attributes.reject{|k,v| k == :slug}
		assert_not role.save
	end

	test 'should not save role with duplicate name' do
		Role.create bogus_attributes.merge(name: attributes[:name])
		role = Role.new attributes
		assert_not role.save
	end

	test 'should not save role with duplicate slug' do
		Role.create bogus_attributes.merge(slug: attributes[:slug])
		role = Role.new attributes
		assert_not role.save
	end

	test 'should save role' do
		role = Role.new attributes
		assert role.save
	end
end
