class DateRange < ActiveRecord::Base

	has_many	:rosters, dependent: :destroy, inverse_of: :date_range
	has_many	:heroes,	through: :rosters

	#..#
	
	scope :since_start_date, -> (date) { where(['start >= :date', {date: date}]) }
	scope :since_game_launch, -> { where(['start >= :date', {date: GAME_LAUNCH_DATE}]) }

	#..#

	validates	'start', 'end', presence: true
	validate	:end_is_after_start
	validates	:start, uniqueness: { scope: :end, message: 'and End have already been taken' }

	#..#

	def self.import_date_text(date_text)
		# US website samples:
		# - Dec 27, 2016 – Jan 3, 2017

		# EU website samples:
		# - 27-Dec-2016 – 03-Jan-2017

		# US forum samples:
		# - June 2 - 9, 2015
		# - June 30 - July 7, 2015
		# - Dec 29 - Jan 5, 2015   (NOTE: year for the ending date is obviously wrong!)
		# - Jan 3 - 10, 2016 (NOTE: Should be 2017)

		# EU forum samples:
		# - February 10, 2015
		# - December 8 - 15, 2015
		# - December 29 - January 4    (NOTE: This specific entry is missing the year value)
		# - January 26 - February 02, 2016
		# - 02 - 09 February, 2016
		# - 23 February - 01 March, 2016
		# - 05 April - 12, 2016
		# - July 05 - July 12, 2016
		# - August 23- 29, 2016    (NOTE: no whitespace between "23" and hyphen)
		# - September 27 - October 04 , 2016    (NOTE: whitespace before comma)
		# (Man, the EU folks need to get their act together!)  :)

		# Initialize variables
		start_month = nil
		start_day = nil
		end_month = nil
		end_day = nil
		year = nil

		# Special cases for incomplete/invalid dates
		case date_text
			#when "Dec 29 - Jan 5, 2015"
			#	date_text = "Dec 29 - Jan 5, 2016"

			when "December 29 - January 4"
				date_text = "#{date_text}, 2015"

			#when "August 23- 29, 2016"
			#	date_text = "August 23 - 29, 2016"

			when "Jan 3 - 10, 2016"
				date_text = "Jan 3 - 10, 2017"

		end


		# - Dec 27, 2016 – Jan 3, 2017
		date_match = /^([A-Za-z]{3}) (\d{1,2}), (\d{4})\s.\s([A-Za-z]{3}) (\d{1,2}), (\d{4})$/.match(date_text)
		if date_match
			start_month = date_match[1]
			start_day = date_match[2]
			start_year = date_match[3]
			end_month = date_match[4]
			end_day = date_match[5]
			end_year = date_match[6]
		end

		# - 27-Dec-2016 – 03-Jan-2017
		date_match = /^(\d{1,2})-([A-Za-z]{3})-(\d{4})\s.\s(\d{1,2})-([A-Za-z]{3})-(\d{4})$/.match(date_text)
		if date_match
			start_day = date_match[1]
			start_month = date_match[2]
			start_year = date_match[3]
			end_day = date_match[4]
			end_month = date_match[5]
			end_year = date_match[6]
		end

		# - June 2 - 9, 2015
		# - June 30 - July 7, 2015
		# - Dec 29 - Jan 5, 2015   (NOTE: year for the ending date is obviously wrong!)
		# - December 8 - 15, 2015
		# - December 29 - January 4    (NOTE: This specific entry is missing the year value)
		# - January 26 - February 02, 2016
		# - July 05 - July 12, 2016
		# - August 23- 29, 2016    (NOTE: no whitespace between "23" and hyphen)
		# - September 27 - October 04 , 2016    (NOTE: whitespace before comma)
		date_match = /^([a-zA-Z]*) (\d{1,2}) ?. ([a-zA-Z]*) ?(\d{1,2}) ?, (\d{4})$/.match(date_text)
		if date_match
			start_month = date_match[1]
			start_day = date_match[2]
			end_month = date_match[3]
			end_day = date_match[4]
			start_year = date_match[5]
			end_year = date_match[5]

			end_month = start_month if end_month.blank?
		end

		# - February 10, 2015
		date_match = /^([a-zA-Z]*) (\d{1,2}), (\d{4})$/.match(date_text)
		if date_match
			start_month = date_match[1]
			start_day = date_match[2]
			start_year = date_match[3]

			calculated_date = DateTime.parse("#{start_month} #{start_day}, #{start_year}") + 1.week
			end_day = calculated_date.strftime('%d')
			end_month = calculated_date.strftime('%B')
			end_year = calculated_date.strftime('%Y')
		end

		# - 02 - 09 February, 2016
		date_match = /^(\d{1,2}) - (\d{1,2}) ([a-zA-Z]*), (\d{4})$/.match(date_text)
		if date_match
			start_day = date_match[1]
			end_day = date_match[2]
			start_month = date_match[3]
			end_month = date_match[3]
			start_year = date_match[4]
			end_year = date_match[4]
		end

		# - 23 February - 01 March, 2016
		# - 05 April - 12, 2016
		date_match = /^(\d{1,2}) ([a-zA-Z]*) - (\d{1,2}) ?([a-zA-Z]*), (\d{4})$/.match(date_text)
		if date_match
			start_day = date_match[1]
			start_month = date_match[2]
			end_day = date_match[3]
			end_month = date_match[4]
			start_year = date_match[5]
			end_year = date_match[5]

			end_month = start_month if end_month.blank?
		end

		if start_year && start_month && start_day && end_year && end_month && end_day
			# end_day should always be 7 days later than start_day (both on a Tuesday)
			(end_day = (end_day.to_i + 1).to_s) if (end_day.to_i == (start_day.to_i + 6))

			start_date = DateTime.parse("#{start_month} #{start_day}, #{year}")
			end_date = DateTime.parse("#{end_month} #{end_day}, #{year}")

			# Kludge for funky end-of-year date text like "Dec 29 - Jan 5, 2015"
			if start_date > end_date
				if ((start_date + 1.week).month == end_date.month) && 
					(((start_date + 1.week).day == end_date.day) || ((start_date + 6.days).day == end_date.day))
					end_date = start_date + 1.week
				end
			end

			date_range = self.find_or_create_by!(start: start_date, end: end_date)

			return date_range
		else
			# We should never get to here!
			# TODO: Send alert to admin
			logger.info "---- UNEXPECTED date text: #{date_text} ----"
			return nil
		end
	end		

	def self.import_from_post(post_detail)
		# TODO: test for this method
		date_range = nil	# Assume failure

		if post_detail.class == Nokogiri::XML::NodeSet
			date_search_texts = [
				'Free-to-Play Hero Rotation:',
				'Week of Tuesday,'
			]

			date_searches = []
			date_search_texts.each{ |i| date_searches << {text: i, regex: Regexp.new(Regexp.quote(i))} }

			date_text = nil
			post_detail.first.traverse do |node|
				if node.text?
					if date_text.nil?
						date_searches.each do |date_search|
							if date_search[:regex].match(node.text)
								date_text = node.text.dup
								date_text.gsub!(date_search[:text], '')
								date_text.strip!
								date_text.chop! while /[^[a-zA-Z0-9]]$/ =~ date_text
								date_range = DateRange.import_date_text(date_text)

								break	# exit the date_searches.each loop
							end
						end
					end
				end
			end

			if date_text.nil?
				# TODO: Send alert to admin
				logger.info "---- UNEXPECTED DateRange text in Blizzard forum post: #{post_detail.text}"
			end
		end

		return date_range
	end

	def self.import_from_blizzard_hero_page(address)
		#	<p class="free-rotation">
		#		<span class="free-rotation__text">Free to play:</span>
		#		<span class="free-rotation__date">Dec 27, 2016 – Jan 3, 2017</span>
		#	</p>

		require 'net/http'

		url = URI.parse(address)
		html = Net::HTTP.get(url) # TODO: error handling
		page = Nokogiri::HTML(html)

		date_text = page.css('.free-rotation .free-rotation__date').text
		date_range = self.import_date_text(date_text)

		return date_range
	end

	def self.import_from_blizzard_hero_pages
		date_range_hash = {}
		SOURCE_URLS[:heroes].each do |country, address|
			date_range_hash.merge!(country.to_sym => self.import_from_blizzard_hero_page(address))
		end
		return date_range_hash
	end

	def self.current
		return self.order([:end, :start]).last
	end

	def end_is_after_start
		if self.start && self.end
			if self.start < self.end
				return true
			else
				errors.add(:start, "must be before End (#{self.end.to_s})")
				return false
			end
		else
			errors.add(:start, "or End is invalid")
			return false
		end
	end
end
