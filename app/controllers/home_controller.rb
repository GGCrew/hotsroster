class HomeController < ApplicationController

	def index
		@head[:meta][:description] = "Hero Rotation statistics for Blizzard's Heroes of the Storm."
		@head[:title] = "Hero Rotation statistics for Blizzard's Heroes of the Storm"

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

	def copyrights
		@head[:meta][:description] = "Copyright information for images and text used on this website."
		@head[:title] = "Copyrights"
	end

	def about
		@head[:meta][:description] = "The who and why about this website."
		@head[:title] = "About"

		rotation_count_data = Hero.launch_heroes.map{|hero| {id: hero.id, name: hero.name, rotation_count: hero.date_ranges.count}}
		rotation_counts = rotation_count_data.map{|i| i[:rotation_count]}.uniq.sort
		least_rotation_counts = rotation_counts[0..2]
		most_rotation_counts = rotation_counts[-3..-1].reverse
		
		@rotation_table_data = []
		for counter in (0..2) do
			@rotation_table_data << {
				least: {
					count: least_rotation_counts[counter],
					heroes: Hero.where(id: rotation_count_data.select{|i| i[:rotation_count] == least_rotation_counts[counter]}.map{|i| i[:id]}).order(:name)
				},
				most: {
					count: most_rotation_counts[counter],
					heroes: Hero.where(id: rotation_count_data.select{|i| i[:rotation_count] == most_rotation_counts[counter]}.map{|i| i[:id]}).order(:name)
				}
			}
		end
	end

	def sitemap
		headers['Content-Type'] = 'application/xml'
		
		respond_to do |format|
			format.xml { 
				@heroes = Hero.all.order(:name)
				@rotations = DateRange.all.order([:start, :end])
				
				@lastmod = DateRange.maximum(:updated_at).strftime('%Y-%m-%d')
			}
		end
	end

end
