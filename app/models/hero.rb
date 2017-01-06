class Hero < ActiveRecord::Base

	belongs_to	:typp
	belongs_to	:franchise

	has_many	:hero_roles,	dependent: :destroy, inverse_of: :hero
	has_many	:roles, through: :hero_roles
	has_many	:rosters, dependent: :destroy, inverse_of: :hero
	has_many	:date_ranges,	through: :rosters
	has_many	:alternate_hero_names,	dependent: :destroy, inverse_of: :hero

	#..#

	scope	:launch_heroes, -> { where(release_date: GAME_LAUNCH_DATE) }
	scope	:post_launch_heroes, -> { where.not(release_date: GAME_LAUNCH_DATE) }
	scope :distinct_heroes, -> { where(id: Hero.distinct_hero_ids) }
	scope :multiclass_heroes, -> { joins(:hero_roles).group(:id).having('count(hero_roles.id) > 1') }

	#..#

	validates :name, :slug, presence: true
	validates :player_character_name, uniqueness: {scope: [:name, :slug]}
	validates	:typp, presence: true
	validates	:franchise, presence: true

	#..#

	def self.get_heroes_json(address)
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
		
		return json
	end

	def self.import_from_blizzard_hero_page(address)
		heroes_json = self.get_heroes_json(address)

		# update related tables
		Role.import_from_heroes_json(heroes_json)
		Typp.import_from_heroes_json(heroes_json)
		Franchise.import_from_heroes_json(heroes_json)

		# update heroes
		heroes_json.each do |hero_json|
			attributes = {
				name: hero_json['name'],
				title: hero_json['title'],
				slug: hero_json['slug'],
				typp: Typp.find_by(name: hero_json['type']['name']),
				franchise: Franchise.find_by(value: hero_json['franchise'])
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

			# update hero roles
			# TODO: delete existing hero role records that don't match the imported JSON data
			case hero.slug
				when 'chogall'
					# Cho is a Warrior, Gall is an Assassin
					# I really hate that I'm hard-coding this...

					cho = Hero.find_by(slug: 'chogall', player_character_name: 'Cho')
					gall = Hero.find_by(slug: 'chogall', player_character_name: 'Gall')
					if cho && gall
						# Let's assume Cho is 'role' and Gall is 'roleSecondary'
						attributes = { hero_id: cho.id, role_id: Role.find_by(slug: hero_json['role']['slug']).id }
						HeroRole.create!(attributes) unless HeroRole.find_by(attributes)

						attributes = { hero_id: gall.id, role_id: Role.find_by(slug: hero_json['roleSecondary']['slug']).id }
						HeroRole.create!(attributes) unless HeroRole.find_by(attributes)
					end
				else
					['role', 'roleSecondary'].each do |role_key|
						unless hero_json[role_key].empty?
							attributes = { hero_id: hero.id, role_id: Role.find_by(slug: hero_json[role_key]['slug']).id }
							HeroRole.create!(attributes) unless HeroRole.find_by(attributes)
						end
					end
			end
		end

		return heroes_json
	end

	def self.import_from_blizzard_hero_pages
		json_hash = {}
		SOURCE_URLS[:heroes].each do |country, address|
			json_hash.merge!(country.to_sym => self.import_from_blizzard_hero_page(address))
		end
		return json_hash
	end

	def self.parse_from_post(post_detail)
		# TODO: test for this method
		# parse heroes and player levels

		heroes = [] # Assume failure

		if post_detail.class == Nokogiri::XML::NodeSet
			# Note: I spent time developing a RegEx to check for the presense or absense
			#       of the "(Slot unlocked...)" text, but it was becoming overly complex.
			#       Only checking for the presense of the text is much clearer,
			#       as is a simple if-else for handling the RegEx match results.
			hero_texts = post_detail.css('ul li').map{|i| i.text.strip}

			for hero_text in hero_texts
				# Check for required player levels
				hero_match = hero_match = /^(.*)\s*\((?:Slot unlocked at|Available after you reach) Player Level (\d{1,2})\)$/i.match(hero_text)
				if hero_match
					# hero requires a player level
					hero_name = hero_match[1].strip
					player_level = hero_match[2].to_i
				else
					# hero does not require a player level
					hero_name = hero_text
					player_level = 1
				end

				# Check for hero name
				hero = Hero.find_by(name: hero_name)
				hero = Hero.find_by(player_character_name: hero_name) unless hero
				unless hero
					alternate_name = AlternateHeroName.find_by(name: hero_name)
					if alternate_name
						hero = alternate_name.hero
					else
						alternate_hero_name = AlternateHeroName.create!(name: hero_name)
						# Alert Admin of newly-created unrelated record
						begin
							AdminMailer.unrecognized_hero_name(hero_name).deliver_now
						rescue => e
							Rails.logger.error "Failed 'AdminMailer.unrecognized_hero_name(hero_name)' -- #{hero_name}"
							Rails.logger.error e.message
						end
					end
				end

				# Alert Admin if hero.nil?
				unless hero
					begin
						AdminMailer.hero_not_found(hero_text).deliver_now
					rescue => e
						Rails.logger.error "Failed 'AdminMailer.hero_not_found(hero_text)' -- #{hero_text}"
						Rails.logger.error e.message
					end
				end

				heroes << {
					hero: hero,
					player_level: player_level
				} if hero
			end
		end

		return heroes
	end

	def self.distinct_hero_ids
		duplicate_counts = self.group(:slug).count.select{|k,v| v>1}
		extra_ids = []
		duplicate_counts.keys.each do |slug|
			duplicate_hero_ids = self.where(slug: slug).order(:id).map(&:id)
			duplicate_hero_ids.shift # drop the lowest-value ID, which represents the "unique" record
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
		(self.joins(:hero_roles).where(hero_roles: {role: role}).count / self.count.to_f) * 100
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
				if difference < 0
					logger.debug("hero: #{hero.id} #{hero.name}")
					logger.debug("difference: #{difference}")
					logger.debug("hero.first_rotation.start: #{hero.first_rotation.start}, hero.release_date: #{hero.release_date}")
				end
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

	def role_slugs
		if self.multiple_player_character_names?
			slugs = self.player_character_heroes.map{|i| i.roles.map(&:slug)}.flatten
		else
			slugs = self.roles.map(&:slug)
		end
		slugs.uniq!
		return slugs
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
		self.date_ranges.where('start >= ?', GAME_LAUNCH_DATE).order([:start, :end]).first
	end

	def last_rotation
		self.date_ranges.where('start >= ?', GAME_LAUNCH_DATE).order([:end, :start]).last
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

