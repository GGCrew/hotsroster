class Hero < ActiveRecord::Base

	belongs_to	:role
	belongs_to	:typp
	belongs_to	:franchise

	has_many	:rosters, dependent: :destroy
	has_many	:date_ranges,	through: :rosters
	has_many	:alternate_hero_names,	dependent: :destroy

	#..#

	scope	:launch_heroes, -> { where(release_date: GAME_LAUNCH_DATE) }
	scope	:post_launch_heroes, -> { where.not(release_date: GAME_LAUNCH_DATE) }

	#..#

	def self.import_from_blizzard
		address = 'http://us.battle.net/heroes/en/heroes/'
		url = URI.parse(address)
		html = Net::HTTP.get(url) # TODO: error handling
		page = Nokogiri::HTML(html)

		json_start_string = 'window.heroes = '
		json_end_string = '}];'

		json_start_regex = Regexp.new(Regexp.quote(json_start_string))
		json_end_regex = Regexp.new(Regexp.quote(json_end_string))

		hero_script = nil
		page.css('script').each do |script|
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
		Role.import_from_json(roles)
		Typp.import_from_json(typps)
		Franchise.import_from_json(franchises)

		# update heroes
		json.each do |hero_json|
			hero = self.find_or_create_by!(name: hero_json['name'])
			
			attributes = {
				title: hero_json['title'],
				slug: hero_json['slug'],
				role: Role.where(name: hero_json['role']['name']).first,
				typp: Typp.where(name: hero_json['type']['name']).first,
				franchise: Franchise.where(value: hero_json['franchise']).first
			}
			attributes.merge!({release_date: Date.today.to_datetime}) unless hero.release_date
			attributes.merge!({prerelease_date: Date.today.to_datetime}) unless hero.prerelease_date

			hero.update_attributes!(attributes)
		end
		
		return json
	end

	def self.newest
		return self.order(:release_date).last
	end

	def self.percentage_by_franchise(franchise)
		(self.where(franchise: franchise).count / self.count.to_f) * 100
	end

	def self.percentage_by_role(role)
		(self.where(role: role).count / self.count.to_f) * 100
	end

	def self.percentage_by_typp(typp)
		(self.where(typp: typp).count / self.count.to_f) * 100
	end

	def self.rotated
		rotated_ids = Roster.select(:hero_id).map(&:hero_id).uniq
		return self.where(id: rotated_ids)
	end

	def self.unrotated
		rotated_ids = Roster.select(:hero_id).map(&:hero_id).uniq
		return self.where('id NOT IN (:ids)', {ids: rotated_ids})
	end

	def self.launch_heroes
		self.where(release_date: GAME_LAUNCH_DATE)
	end

	#..#

	def first_rotation
		self.date_ranges.order([:start, :end]).first
	end

	def last_rotation
		self.date_ranges.order([:end, :start]).last
	end

	def rotations
		self.date_ranges.count
	end

	def rotations_since_newest_hero_release
		self.date_ranges.since_start_date(Hero.newest.release_date).count
	end

	def rotations_since_latest_change_in_roster_size
		self.date_ranges.since_start_date(Roster.date_range_of_latest_roster_size_change.start).count
	end


	def rotation_percentage_since_launch
		((self.rotations / DateRange.count.to_f) * 100).round(2)
	end

	def rotation_percentage_since_release
		(self.rotations / DateRange.since_start_date(self.release_date).count.to_f) * 100
	end

	def rotation_percentage_since_newest_hero_release
		(self.rotations_since_newest_hero_release / DateRange.since_start_date(Hero.newest.release_date).count.to_f) * 100
	end

	def rotation_percentage_since_latest_change_in_roster_size
		(self.rotations_since_latest_change_in_roster_size / DateRange.since_start_date(Roster.date_range_of_latest_roster_size_change.start).count.to_f) * 100
	end

end

