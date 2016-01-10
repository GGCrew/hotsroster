class RotationsController < ApplicationController

  def index
		@head[:meta][:description] = "Hero Rotations for Blizzard's Heroes of the Storm."
		@head[:title] = "Rotations"

    @rotations = DateRange.order(end: :desc).order(start: :desc)
  end

end
