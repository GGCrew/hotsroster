class ImportHeroesOfTheDorm2016Data < ActiveRecord::Migration
  def up
  	DateRange.reset_column_information
  	
  	dr = DateRange.create!({
  		start: '2016-04-08',
  		end: '2016-04-11',
  		special_event: true,
  		special_event_name: 'Heroes of the Dorm 2016'
  	})

		dr.heroes << Hero.all
  end

	def down
		DateRange.destroy_all(special_event: true)
	end
end
