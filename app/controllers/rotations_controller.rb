class RotationsController < ApplicationController
  before_action :set_rotation, only: [:show]

  def index
		@head[:meta][:description] = "Hero Rotations for Blizzard's Heroes of the Storm."
		@head[:title] = "Rotations"

    @rotations = DateRange.order(end: :desc).order(start: :desc)
  end

	def show
	
	end


	private         
    def set_rotation
      @rotation = DateRange.find(params[:id])
    end
end
