class AddAddedDateToHeroes < ActiveRecord::Migration
  def change
  	add_column	'heros', 'release_date',	:datetime,	after: 'franchise_id'
  	add_column	'heros', 'prerelease_date',	:datetime,	after: 'release_date'
  end
end
