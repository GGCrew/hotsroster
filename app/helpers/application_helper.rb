module ApplicationHelper

	def format_date_range(date_range)
		return "#{date_range.start.to_s(:shortish)} — #{date_range.end.to_s(:shortish)}"
	end

end
