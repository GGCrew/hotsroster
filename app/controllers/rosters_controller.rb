class RostersController < ApplicationController
  before_action :set_roster, only: [:show]

  # GET /rosters
  # GET /rosters.json
  def index
    @rosters = Roster.all
  end

  # GET /rosters/1
  # GET /rosters/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_roster
      @roster = Roster.find(params[:id])
    end

end
