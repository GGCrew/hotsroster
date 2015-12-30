class Roster < ActiveRecord::Base

	belongs_to	:hero
	belongs_to	:date_range

	def self.import_from_blizzard
		address = 'http://us.battle.net/heroes/en/forum/topic/17936383460'
		date_search_text = 'Free-to-Play Hero Rotation:'

		url = URI.parse(address)
		html = Net::HTTP.get(url) # TODO: error handling
		page = Nokogiri::HTML(html)

		date_search_regex = Regexp.new(Regexp.quote(date_search_text))
		date_texts = []	# TEMPORARY CODE
	
		post_list = page.css('div.post-list div.topic-post')
		for post in post_list  #[0..0]  # TEMPORARY CODE: range restriction during development
			date_text = nil
			post_detail = post.css('div.post-detail')
			post_detail.first.traverse do |node|
				if node.text?
					date_text = node.text.dup if (date_search_regex =~ node.text)
				end
			end
			hero_texts = post_detail.css('ul li').map{|i| i.text}
			
			# parse dates into DateRange
			date_text.gsub!(date_search_text, '')
			date_text.strip!
			date_range = DateRange.import_date_text(date_text)

			# TODO: parse heroes and player levels

			# TODO: Import into Roster
		end
		
		return {post_list_count: post_list.count, date_range: date_range, hero_texts: hero_texts}
	end

end
