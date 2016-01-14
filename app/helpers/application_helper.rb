module ApplicationHelper

	def format_date_range(date_range)
		return "#{date_range.start.to_s(:shortish)} — #{date_range.end.to_s(:shortish)}"
	end

=begin
	def percent_of_heroes_in_franchise(heroes, franchise)
		return ((heroes.where(franchise: franchise).count.to_f / heroes.count) * 100).round(2)
	end

	def percent_of_heroes_by_role(heroes, role)
		return ((heroes.where(role: role).count.to_f / heroes.count) * 100).round(2)
	end

	def percent_of_heroes_by_typp(heroes, typp)
		return ((heroes.where(typp: typp).count.to_f / heroes.count) * 100).round(2)
	end
=end

end
