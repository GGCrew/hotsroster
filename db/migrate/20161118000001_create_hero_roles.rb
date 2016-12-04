class CreateHeroRoles < ActiveRecord::Migration
  def change
    create_table :hero_roles do |t|
    	t.integer :hero_id
    	t.integer :role_id

      t.timestamps null: false
    end
  end
end
