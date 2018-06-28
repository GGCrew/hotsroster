class Roster < ActiveRecord::Base

	belongs_to	:hero
	belongs_to	:date_range

	#..#

	validates	:hero, :date_range, presence: true
	validates :hero, uniqueness: { scope: :date_range, message: 'and DateRange have already been taken.' }

	#..#

	def self.import_from_blizzard_hero_page(address)
		heroes_json = Hero.get_heroes_json(address)
		date_range = DateRange.import_from_blizzard_hero_page(address)

		heroes_json.select!{|hero_json| hero_json['inFreeHeroRotation']}
		if heroes_json.empty?
			# TODO: Send alert to admin
		end

		heroes_json.each do |hero_json|
			slug = hero_json['slug']
			player_level = (hero_json['freeRotationMinLevel'] == 0 ? 1 : hero_json['freeRotationMinLevel'])
			hero = Hero.find_by(slug: slug)
			if hero
				roster = Roster.find_or_create_by(date_range_id: date_range.id, hero_id: hero.id)
				roster.update!(player_level: player_level)
			else
				# Should never get here!
				# TODO: Send alert to admin
			end
		end

		return date_range.rosters
	end

	def self.import_from_blizzard_hero_pages
		roster_hash = {}
		SOURCE_URLS[:heroes].each do |country, address|
			roster_hash.merge!(country.to_sym => self.import_from_blizzard_hero_page(address))
		end
		return roster_hash
	end

	def self.import_from_blizzard_forum
		require 'net/http'

		SOURCE_URLS[:rosters].each do |country, address|
			# Loop through all pages via pagination
			page_query_string = '?page=1'
			loop do
        if READ_DATA_FROM_LOCAL_DOCS
          html = File.read('docs/free_hero_rotation.html')
        else
          url = URI.parse(address + page_query_string)
          html = Net::HTTP.get(url) # TODO: error handling
        end
				if html.blank?
					# TODO: Send alert to admin
				end

				page = Nokogiri::HTML(html)
				#post_list = page.css('div.Topic-content div.TopicPost')
        post_list = page.css('div#post-list div.topic-post')

				if post_list.empty?
					# TODO: Send alert to admin
				end

				for post in post_list
					#post_detail = post.css('div.TopicPost-bodyContent')
          post_detail = post.css('div.post-detail')

					date_range = DateRange.import_from_post(post_detail)

					heroes = Hero.parse_from_post(post_detail)

					# Import into Roster
					for hero in heroes
						Roster.find_or_create_by!({
							date_range: date_range,
							hero: hero[:hero],
							player_level: hero[:player_level]
						})
					end
				end

				# Check for pagination
				next_page_link = page.css('div.Topic-pagination--header a.Pagination-button--next').first
				break unless next_page_link # Exit loop if there isn't a "next page" link
				page_query_string = next_page_link[:href]
				break if page_query_string.nil?  # Exit loop if there isn't a valid "href" value
			end # END: Loop through all pages via pagination
		end
		
		return true
	end

	def self.date_range_of_latest_roster_size_change
		# Count each date_range's roster size
		# Using the database sort commands because they should be more efficient than Ruby's sorting/reverse methods
		# The key:value pairs represent date_range_id:roster_size_for_that_date
		counts = self.joins(:date_range).group(:date_range_id).order('date_ranges.start DESC, date_ranges.end DESC').count

		# This trick works because Ruby's Array.uniq method maintains the order of the first appearance of a value
		values = counts.values.uniq[0..1]
		current_size = values.first
		previous_size = values.last

		# Get key of last rotation with previous roster size
		previous_key = counts.key(previous_size)

		# Get key of first rotation with current roster size
		counts_keys = counts.keys
		previous_key_index = counts_keys.index(previous_key)
		current_key = counts.keys[previous_key_index - 1]
		
		return DateRange.find(current_key)
	end
end
