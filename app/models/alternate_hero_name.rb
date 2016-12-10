class AlternateHeroName < ActiveRecord::Base

	belongs_to	:hero

	#..#

	validates :name, presence: true, uniqueness: true

	#..#

	scope :orphans, -> { where(hero_id: nil) }
	scope :adopteds,  -> { where.not(hero_id: nil) }

end
