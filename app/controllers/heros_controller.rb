class HerosController < ApplicationController
  before_action :set_hero, only: [:show, :edit, :update, :destroy]

  # GET /heros
  # GET /heros.json
  def index
    @heros = Hero.order(:name)
  end

  # GET /heros/1
  # GET /heros/1.json
  def show
  	@head[:title] = @hero.name
  	@head[:meta][:description] = "Rotation statistics for #{@hero.name}"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hero
      @hero = Hero.find(params[:id])
    end
end
