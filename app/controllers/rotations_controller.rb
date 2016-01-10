class RotationsController < ApplicationController

  def index
    @rotations = DateRange.order(end: :desc).order(start: :desc)
  end

end
