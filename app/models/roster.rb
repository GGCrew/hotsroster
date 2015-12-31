class Roster < ActiveRecord::Base

	belongs_to	:hero
	belongs_to	:date_range

	def self.import_from_blizzard
		address = 'http://us.battle.net/heroes/en/forum/topic/17936383460'
		date_search_text = 'Free-to-Play Hero Rotation:'

		date_search_regex = Regexp.new(Regexp.quote(date_search_text))

		# Loop through all pages via pagination
		page_query_string = '?page=1'
		loop do
			url = URI.parse(address + page_query_string)
			html = Net::HTTP.get(url) # TODO: error handling
			page = Nokogiri::HTML(html)
			post_list = page.css('div.post-list div.topic-post')
			for post in post_list
				date_text = nil
				post_detail = post.css('div.post-detail')
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
					hero_match = /^(.*) \(Slot unlocked at Player Level (\d{1,2})\)$/.match(hero_text)
					if hero_match
						# hero requires a player level
						hero_name = hero_match[1]
						player_level = hero_match[2].to_i
					else
						# hero does not require a player level
						hero_name = hero_text
						player_level = 1
					end
					heroes << {
						hero: Hero.where(name: hero_name).first,
						player_level: player_level
					}
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
			next_page_link = page.css('ul.ui-pagination a.page-next').first
			break unless next_page_link # Exit loop if there isn't a "next page" link
			page_query_string = next_page_link[:href]
		end # END: Loop through all pages via pagination
		
		return true
	end

end
