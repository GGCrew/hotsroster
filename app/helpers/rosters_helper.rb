module RostersHelper

	def create_roster_groups(roster)
		max_per_row = 7 # 7 is max amount per row/group

		roster_count = roster.count

		rows_needed = roster_count / max_per_row
		rows_needed += 1 if ((roster_count % max_per_row) > 0)

		items_per_row = roster_count / rows_needed
		straggler_count = roster_count % items_per_row

		groups = []
		roster_start_index = 0
		roster_end_index = -1
		(1..rows_needed).each do |row_index|
			roster_end_index += items_per_row
			if straggler_count > 0
				roster_end_index += 1
				straggler_count -= 1
			end
			groups << roster[roster_start_index..roster_end_index]
			roster_start_index = roster_end_index + 1
		end

=begin
		if roster_count > 7 # 7 is max amount per row/group
			# TODO: algorithm for even distribution when more than 2 groups

			break_point = roster_count / 2
			break_point += 1 if roster_count.odd? # Put "extra" item on top row  -- aesthetics!

			groups << roster[0..(break_point  - 1)]
			groups << roster[break_point..-1]
		else
			groups << roster
		end
=end

		return groups
	end

end
