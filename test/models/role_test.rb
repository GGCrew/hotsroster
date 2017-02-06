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

	# Validation tests

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

	# Model tests

	test 'should import from heroes json' do
		assert Role.import_from_heroes_json(heroes_json)
	end

	test 'should import from json' do
		json = [
			HashWithIndifferentAccess.new(attributes),
			HashWithIndifferentAccess.new(bogus_attributes)
		]
		assert Role.import_from_json json
	end
end
