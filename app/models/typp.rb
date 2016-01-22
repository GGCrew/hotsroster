class Typp < ActiveRecord::Base

	has_many	:heroes, dependent: :nullify, inverse_of: :typp

	#..#

	validates :name, :slug, presence: true, uniqueness: true

	#..#

	def self.import_from_json(json)
		for json_data in json
			attributes = {
				name: json_data['name'],
				slug: json_data['slug']
			}
				
			typp = self.find_by(slug: attributes[:slug])
			typp = self.create!(attributes) unless typp
			
			typp.update_attributes!(attributes)
		end
	end

end
