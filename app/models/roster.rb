class Roster < ActiveRecord::Base

	belongs_to	:hero
	belongs_to	:date_range

	def self.update_from_blizzard
		address = 'http://us.battle.net/heroes/en/forum/topic/17936383460'
		url = URI.parse(address)
		html = Net::HTTP.get(url) # TODO: error handling
		page = Nokogiri::HTML(html)
	end

end
