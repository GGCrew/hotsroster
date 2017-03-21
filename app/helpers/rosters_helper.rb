module RostersHelper

	def create_roster_groups(roster)
		groups = []

		roster_count = roster.count
		if roster_count > 7 # 7 is max amount per row/group
			# TODO: algorithm for even distribution when more than 2 groups

			break_point = roster_count / 2
			break_point += 1 if roster_count.odd? # Put "extra" item on top row  -- aesthetics!

			groups << roster[0..(break_point  - 1)]
			groups << roster[break_point..-1]
		else
			groups << roster
		end

		return groups
	end

end
