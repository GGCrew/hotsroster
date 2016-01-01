class HomeController < ApplicationController

	def index
		current_date_range = DateRange.order(:start).last
		@current_rotation = {
			date_range: current_date_range,
			roster: current_date_range.rosters.joins(:hero).order(:player_level).order('heros.name ASC')
		}
		
		@previous_rotations = []
		for date_range in DateRange.order(start: :desc).limit(3)[1..2]
			@previous_rotations << {
				date_range: date_range,
				roster: date_range.rosters.joins(:hero).order(:player_level).order('heros.name ASC')			
			}
		end
	end

end
