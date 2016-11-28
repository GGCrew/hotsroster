class HeroRole < ActiveRecord::Base

	belongs_to	:hero
	belongs_to	:role

	#..#

	validates :hero, :role, presence: true
	validates :hero, uniqueness: { scope: :role, message: 'and Role have already been paired.' }

end
