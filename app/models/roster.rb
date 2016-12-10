class Roster < ActiveRecord::Base

	belongs_to	:hero
	belongs_to	:date_range

	#..#

	validates	:hero, :date_range, presence: true
	validates :hero, uniqueness: { scope: :date_range, message: 'and DateRange have already been taken.' }

	#..#

	def self.import_from_blizzard
		# TODO: split into import_from_hero_page and import_from_forum

		address = SOURCE_URLS[:rotations][:us]

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
				post_detail = post.css('div.TopicPost-bodyContent')

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
