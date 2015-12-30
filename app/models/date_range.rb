class DateRange < ActiveRecord::Base

	has_many	:rosters

	def self.import_date_text(date_text)
		date_match = /^([a-zA-Z]*) (\d{1,2}) . ([a-zA-Z]*) ?(\d{1,2}), (\d{4})$/.match(date_text)
		start_month = date_match[1]
		start_day = date_match[2]
		end_month = date_match[3]
		end_day = date_match[4]
		year = date_match[5]
		start_date = DateTime.parse("#{start_month} #{start_day}, #{year}")
		(end_month = start_month) if (end_month.blank? && (end_day.to_i == (start_day.to_i + 7)))
		end_date = DateTime.parse("#{end_month} #{end_day}, #{year}")
		
		# Kludge for funky end-of-year date text like "Dec 29 - Jan 5, 2015"
		if start_date > end_date
			if ((start_date + 1.week).month == end_date.month) && ((start_date + 1.week).day == end_date.day)
				end_date = start_date + 1.week
			end
		end

		date_range = self.where(start: start_date).where(end: end_date).first
		date_range = self.create!(start: start_date, end: end_date) unless date_range

		return date_range
	end		
	
end
