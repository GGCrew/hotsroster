class DropRoleIdFromHeroes < ActiveRecord::Migration
  def change
  	remove_column	'heros', 'role_id', :integer, after: 'slug'
  end
end
