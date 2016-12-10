class Franchise < ActiveRecord::Base

	has_many	:heroes, dependent: :nullify, inverse_of: :franchise

	#..#

	validates :name, :value, presence: true, uniqueness: true

	#..#

	def self.import_from_blizzard
		SOURCE_URLS[:heroes].each do |country, address|
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
				name = option.attributes['title'].value	# eg Warcraft
				value = option.attributes['for'].value	# eg warcraft-check

				name.strip!
				value.strip!
				value.gsub!('-check', '')

				franchise = self.find_by(value: value)
				if franchise
					franchise.update_attributes!(name: name)
				else
					franchise = self.find_or_create_by!(value: value, name: name)
				end
			end
		end

		return true
	end

	def self.import_from_json(json)
		for value in json
			name = value.titlecase
			franchise = self.find_by(value: value)
			if franchise
				franchise.update_attributes!(name: name) if franchise.name.blank?
			else
				franchise = self.find_or_create_by!(value: value, name: name)
			end
		end

		return true
	end

end
