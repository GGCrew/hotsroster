class Hero < ActiveRecord::Base

	belongs_to	:role
	belongs_to	:typp
	belongs_to	:franchise

	def self.update_from_blizzard
		address = 'http://us.battle.net/heroes/en/heroes/'
		url = URI.parse(address)
		html = Net::HTTP.get(url) # TODO: error handling
		page = Nokogiri::HTML(html)

		json_start_string = 'window.heroes = '
		json_end_string = '}];'

		json_start_regex = Regexp.new(Regexp.quote(json_start_string))
		json_end_regex = Regexp.new(Regexp.quote(json_end_string))

		hero_script = nil
		page.css('script').each_with_index do |script|
			hero_script = script.to_s if (json_start_regex =~ script)
		end
		#TODO: error handling (hero_script == nil)

		json_start = (json_start_regex =~ hero_script) + json_start_string.length
		json_end = (json_end_regex =~ hero_script) + json_end_string.length - 1 - 1  #...and trim trailing semicolon
		json_string = hero_script[json_start..json_end]
		json = JSON.parse(json_string)
	
		# update related tables
		roles = []
		typps = []
		franchises = []
		json.each do |hero_json|
			roles << hero_json['role']
			typps << hero_json['type']
			franchises << hero_json['franchise']
		end
		roles.uniq!
		typps.uniq!
		franchises.uniq!
		Role.update_from_json(roles)
		Typp.update_from_json(typps)
		Franchise.update_from_json(franchises)

		# update heroes
		json.each do |hero_json|
			hero = self.where(name: hero_json['name']).first
			hero = self.new(name: hero_json['name']) unless hero
			
			hero.title = hero_json['title']
			hero.slug = hero_json['slug']

			hero.role = Role.where(name: hero_json['role']['name']).first
			hero.typp = Typp.where(name: hero_json['type']['name']).first
			hero.franchise = Franchise.where(name: hero_json['franchise']).first

			hero.save! if hero.changed?
		end
		
		return json
	end

end
