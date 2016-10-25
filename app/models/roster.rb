class Roster < ActiveRecord::Base

	belongs_to	:hero
	belongs_to	:date_range

	#..#

	validates	:hero, :date_range, presence: true
	validates :hero, uniqueness: { scope: :date_range, message: 'and DateRange have already been taken.' }

	#..#

	def self.import_from_blizzard
		# TODO: split into import_from_hero_page and import_from_forum

		address = 'http://us.battle.net/forums/en/heroes/topic/17936383460'
		date_search_text = 'Free-to-Play Hero Rotation:'

		date_search_regex = Regexp.new(Regexp.quote(date_search_text))

		# Loop through all pages via pagination
		page_query_string = '?page=1'
		loop do
			url = URI.parse(address + page_query_string)
			html = Net::HTTP.get(url) # TODO: error handling
			if html.blank?
				# TODO: Send alert to admin
			end

			page = Nokogiri::HTML(html)
			post_list = page.css('div.Topic-content div.TopicPost')
			if post_list.empty?
				# TODO: Send alert to admin
			end

			for post in post_list
				date_text = nil
				post_detail = post.css('div.TopicPost-bodyContent')
				post_detail.first.traverse do |node|
					if node.text?
						date_text = node.text.dup if (date_search_regex =~ node.text)
					end
				end
				hero_texts = post_detail.css('ul li').map{|i| i.text.strip}
			
				# parse dates into DateRange
				date_text.gsub!(date_search_text, '')
				date_text.strip!
				date_range = DateRange.import_date_text(date_text)

				# parse heroes and player levels
				# Note: I spent time developing a RegEx to check for the presense or absense
				#       of the "(Slot unlocked...)" text, but it was becoming overly complex.
				#       Only checking for the presense of the text is much clearer,
				#       as is a simple if-else for handling the RegEx match results.
				heroes = []
				for hero_text in hero_texts
					# Check for required player levels
					hero_match = /^(.*)\s*\(Slot unlocked at Player Level (\d{1,2})\)$/.match(hero_text)
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
					hero = Hero.where(name: hero_name).first
					hero = Hero.where(player_character_name: hero_name).first unless hero
					unless hero
						alternate_name = AlternateHeroName.where(name: hero_name).first
						if alternate_name
							hero = alternate_name.hero
						else
							alternate_hero_name = AlternateHeroName.create!(name: hero_name)
							# Alert Admin of newly-created unrelated record
							begin
								AdminMailer.roster_unrecognized_hero_name(hero_name, date_range).deliver_now
							rescue => e
								Rails.logger.error "Failed 'AdminMailer.roster_unrecognized_hero_name(hero_name, date_range)' -- #{hero_name} -- #{date_range.try(:id)}"
								Rails.logger.error e.message
							end
						end
					end

					# Alert Admin if hero.nil?
					unless hero
						begin
							AdminMailer.roster_hero_not_found(hero_text, date_range).deliver_now
						rescue => e
							Rails.logger.error "Failed 'AdminMailer.roster_hero_not_found(hero_text, date_range)' -- #{hero_text} -- #{date_range.try(:id)}"
							Rails.logger.error e.message
						end
					end

					heroes << {
						hero: hero,
						player_level: player_level
					} if hero
				end

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
