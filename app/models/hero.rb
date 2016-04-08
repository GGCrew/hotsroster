class Hero < ActiveRecord::Base

	belongs_to	:role
	belongs_to	:typp
	belongs_to	:franchise

	has_many	:rosters, dependent: :destroy, inverse_of: :hero
	has_many	:date_ranges,	through: :rosters
	has_many	:alternate_hero_names,	dependent: :destroy, inverse_of: :hero

	#..#

	scope	:launch_heroes, -> { where(release_date: GAME_LAUNCH_DATE) }
	scope	:post_launch_heroes, -> { where.not(release_date: GAME_LAUNCH_DATE) }
	scope :distinct_heroes, -> { where(id: Hero.distinct_hero_ids) }

	#..#

	validates :name, :slug, presence: true
	validates :player_character_name, uniqueness: {scope: [:name, :slug]}
	validates	:role, presence: true
	validates	:typp, presence: true
	validates	:franchise, presence: true

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
			attributes = {
				name: hero_json['name'],
				title: hero_json['title'],
				slug: hero_json['slug'],
				role: Role.where(name: hero_json['role']['name']).first,
				typp: Typp.where(name: hero_json['type']['name']).first,
				franchise: Franchise.where(value: hero_json['franchise']).first
			}

			hero = self.find_by(slug: hero_json['slug'])
			hero = self.create!(attributes) unless hero

			# Assumes Blizzard continues to release new heroes on Tuesdays
			release_date = Date.today
			(release_date += (2 - release_date.wday).days) if release_date.wday < 2 # Sun, Mon
			(release_date += (9 - release_date.wday).days) if release_date.wday > 2 # Wed, Thu, Fri, Sat
			
			attributes.merge!({release_date: release_date}) unless hero.release_date
			attributes.merge!({prerelease_date: release_date}) unless hero.prerelease_date
			attributes.merge!({player_character_name: hero_json['name']}) unless hero.player_character_name

			hero.update!(attributes)
		end
		
		return json
	end

	def self.distinct_hero_ids
		duplicate_counts = self.group(:name).count.select{|k,v| v>1}
		extra_ids = []
		duplicate_counts.keys.each do |name|
			duplicate_hero_ids = self.where(name: name).order(:id).map(&:id)
			duplicate_hero_ids.shift
			extra_ids << duplicate_hero_ids
		end
		extra_ids.flatten!
		extra_ids.uniq! unless extra_ids.empty?
		
		return self.select(:id).where.not(id: extra_ids).map(&:id)
	end

	def self.newest
		return self.order(:release_date).where(["release_date <= :now", {now: DateTime.now}]).last
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
		return self.where.not(id: rotated_ids)
	end

	def self.typical_weeks_between_release_and_first_rotation
		weeks = []
		for hero in self.distinct_heroes
			if hero.first_rotation
				difference = hero.first_rotation.start - hero.release_date
				difference = (difference / 1.week).to_i
				weeks[difference] ||= 0 # Initialize if not already set
				weeks[difference] += 1
			end
		end
		weeks.map!{|i| i ||= 0} # Initialize any unset values
		max_count = weeks.max
		return weeks.index(max_count)
	end

	def self.typical_weeks_between_hero_releases
		weeks = []
		heroes = self.distinct_heroes.post_launch_heroes.order(release_date: :asc)
		
		heroes.each_with_index do |hero, index|
			difference = hero.release_date - (index == 0 ? GAME_LAUNCH_DATE : heroes[index-1].release_date)
			difference = (difference / 1.week).to_i
			weeks[difference] ||= 0 # Initialize if not already set
			weeks[difference] += 1
		end
		weeks.map!{|i| i ||= 0} # Initialize any unset values
		max_count = weeks.max
		return weeks.index(max_count)
	end

	#..#

	def distinct_hero
		return Hero.distinct_heroes.find_by(name: self.name)
	end

	def player_character_heroes
		return Hero.where(name: self.name).order(player_character_name: :asc)
	end

	def multiple_player_character_names?
		return self.player_character_heroes.count > 1
	end

	def previous
		hero_ids = Hero.distinct_heroes.select(:id).order(:name).map(&:id)
		index = hero_ids.index(self.distinct_hero.id)
		index = hero_ids.count if index == 0
		return Hero.find(hero_ids[index - 1])
	end
	
	def next
		hero_ids = Hero.distinct_heroes.select(:id).order(:name).map(&:id)
		index = hero_ids.index(self.distinct_hero.id)
		index = -1 if self.id == hero_ids.last
		return Hero.find(hero_ids[index + 1])
	end
	
	def first_rotation
		self.date_ranges.where(special_event: false).order([:start, :end]).first
	end

	def last_rotation
		self.date_ranges.where(special_event: false).where(['start <= :start', {start: Date.today}]).order([:end, :start]).last
	end

	def weeks_between_release_and_first_rotation
		if self.first_rotation
			return ((self.first_rotation.start - self.release_date) / 1.week).to_i
		else
			return nil
		end
	end

	def expected_first_rotation
		expected_start = self.release_date + Hero.distinct_heroes.post_launch_heroes.typical_weeks_between_release_and_first_rotation.weeks
		expected_end = expected_start + 1.week
		return DateRange.new(start: expected_start, end: expected_end)
	end

	def rotations
		self.date_ranges.count
	end

	def rotations_since_newest_hero_release
		self.date_ranges.since_start_date(Hero.distinct_heroes.newest.release_date).count
	end

	def rotations_since_latest_change_in_roster_size
		self.date_ranges.since_start_date(Roster.date_range_of_latest_roster_size_change.start).count
	end


	def rotation_percentage_since_launch
		(self.rotations / DateRange.count.to_f) * 100
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

	def rotation_pairings
		self_date_ranges = self.date_ranges
		self_date_ranges_count = self_date_ranges.count
		other_heroes = Hero.distinct_heroes.where.not(id: self.id).order(name: :asc)
		pairings = []
		for other_hero in other_heroes
			other_hero_date_ranges = other_hero.date_ranges
			paired_date_ranges = self_date_ranges & other_hero_date_ranges
			paired_date_ranges_count = paired_date_ranges.count
			paired_date_ranges_percentage = (self_date_ranges_count == 0 ? 0.0 : ((paired_date_ranges_count / self_date_ranges_count.to_f) * 100))
			pairings << {
				hero: other_hero,
				date_ranges: paired_date_ranges,
				count: paired_date_ranges_count,
				percentage: paired_date_ranges_percentage
			}
		end
		pairings.sort_by!{|i| [-i[:count], i[:hero].name]}
		return pairings
	end
end

