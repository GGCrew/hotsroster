class AlternateHeroName < ActiveRecord::Base

	belongs_to	:hero

	#..#

	validates :name, presence: true, uniqueness: true

end
