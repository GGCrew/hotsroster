class RotationsController < ApplicationController
  before_action :set_rotation, only: [:show]

  def index
		@head[:meta][:description] = "Hero Rotations for Blizzard's Heroes of the Storm."
		@head[:title] = "Rotations"

    #@rotations = DateRange.order(end: :desc).order(start: :desc)
    #@rotations = DateRange.order(end: :desc).order(start: :desc).includes(:rosters).order('rosters.player_level ASC').includes(:heroes).order('heros.name ASC')
    @rotations = DateRange.includes(:rosters).includes(:heroes).order(end: :desc).order(start: :desc).order('rosters.player_level ASC').order('heros.name ASC')
  end

	def show
		@head[:meta][:description] = "#{@rotation.start.to_s(:shortish)} - #{@rotation.end.to_s(:shortish)} Hero Rotation for Blizzard's Heroes of the Storm."
		@head[:title] = "Rotation for #{@rotation.start.to_s(:shortish)} - #{@rotation.end.to_s(:shortish)}"

		@rosters = @rotation.rosters.includes(:hero).order('heros.name ASC')
		@newest_hero = @rotation.heroes.newest
	end


	private         
    def set_rotation
      @rotation = DateRange.find(params[:id])
    end
end
