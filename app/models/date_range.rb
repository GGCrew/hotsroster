class DateRange < ActiveRecord::Base

	has_many	:rosters, dependent: :destroy, inverse_of: :date_range
	has_many	:heroes,	through: :rosters

	#..#
	
	scope :since_start_date, -> (date) { where(['start >= :date', {date: date}]) }

	#..#

	validates	'start', 'end', presence: true
	validate	:end_is_after_start
	validates	:start, uniqueness: { scope: :end, message: 'and End have already been taken' }

	#..#

	def self.import_date_text(date_text)
		# US forum samples:
		# - June 2 - 9, 2015
		# - June 30 - July 7, 2015
		# - Dec 29 - Jan 5, 2015   (NOTE: year for the ending date is obviously wrong!)

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

		end


		# - June 2 - 9, 2015
		# - June 30 - July 7, 2015
		# - Dec 29 - Jan 5, 2015   (NOTE: year for the ending date is obviously wrong!)
		# - December 8 - 15, 2015
		# - December 29 - January 4    (NOTE: This specific entry is missing the year value)
		# - January 26 - February 02, 2016
		# - July 05 - July 12, 2016
		# - August 23- 29, 2016    (NOTE: no whitespace between "23" and hyphen)
		date_match = /^([a-zA-Z]*) (\d{1,2}) ?. ([a-zA-Z]*) ?(\d{1,2}), (\d{4})$/.match(date_text)
		if date_match
			start_month = date_match[1]
			start_day = date_match[2]
			end_month = date_match[3]
			end_day = date_match[4]
			year = date_match[5]
		end

		# - February 10, 2015
		date_match = /^([a-zA-Z]*) (\d{1,2}), (\d{4})$/.match(date_text)
		if date_match
			start_month = date_match[1]
			start_day = date_match[2]
			year = date_match[3]
			calculated_date = DateTime.parse("#{start_month} #{start_day}, #{year}") + 1.week
			end_day = calculated_date.strftime('%d')
			end_month = calculated_date.strftime('%B')
		end

		# - 02 - 09 February, 2016
		date_match = /^(\d{1,2}) - (\d{1,2}) ([a-zA-Z]*), (\d{4})$/.match(date_text)
		if date_match
			start_month = date_match[3]
			start_day = date_match[1]
			end_month = date_match[3]
			end_day = date_match[2]
			year = date_match[4]
		end

		# - 23 February - 01 March, 2016
		# - 05 April - 12, 2016
		date_match = /^(\d{1,2}) ([a-zA-Z]*) - (\d{1,2}) ?([a-zA-Z]*), (\d{4})$/.match(date_text)
		if date_match
			start_month = date_match[2]
			start_day = date_match[1]
			end_month = date_match[4]
			end_day = date_match[3]
			year = date_match[5]
		end

		if year && start_month && start_day && end_day
			# end_day should always be 7 days later than start_day (both on a Tuesday)
			(end_day = (end_day.to_i + 1).to_s) if (end_day.to_i == (start_day.to_i + 6))

			# if no end_month, assume start_month and end_month are the same
			(end_month = start_month) if (end_month.blank? && (end_day.to_i == (start_day.to_i + 7)))

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
