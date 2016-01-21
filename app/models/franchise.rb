class Franchise < ActiveRecord::Base

	has_many	:heroes, dependent: :nullify, inverse_of: :franchise

	#..#

	validates :name, :value, presence: true, uniqueness: true

	#..#

	def self.import_from_blizzard
		address = 'http://us.battle.net/heroes/en/heroes/'
		url = URI.parse(address)
		html = Net::HTTP.get(url) # TODO: error handling
		page = Nokogiri::HTML(html)

		
		#<input type="checkbox" id="warcraft-check" data-ng-model="gameFilters.warcraft" data-ng-change="filterChampions()" />
		#<label for="warcraft-check" title="Warcraft">
		#	<i class="heroes-icon-universe-warcraft hero-filter-icon" data-ng-class="{checked: gameFilters.warcraft}"></i>
		#	<span>Warcraft</span>
		#</label>
		universe_options = page.css('#warcraft-check').first.parent.parent.css('label')
		for option in universe_options
			name = option.attributes['title'].value	# Warcraft
			value = option.attributes['for'].value	# warcraft-check

			name.strip!
			value.strip!
			value.gsub!('-check', '')
			
			franchise = self.find_or_create_by!(value: value)
			franchise.update_attributes!(name: name)
		end
	end

	def self.import_from_json(json)
		for value in json
			franchise = self.find_or_create_by!(value: value)
			franchise.name = value.titlecase if franchise.name.blank?
			franchise.save!
		end

		return true
	end

end
