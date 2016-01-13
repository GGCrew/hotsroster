class CreateAlternateHeroNames < ActiveRecord::Migration
  def change
    create_table :alternate_hero_names do |t|
			t.integer	'hero_id'
			t.string	'name'

      t.timestamps null: false
    end
  end
end
