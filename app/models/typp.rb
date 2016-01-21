class Typp < ActiveRecord::Base

	has_many	:heroes, dependent: :nullify, inverse_of: :typp

	#..#

	validates :name, :slug, presence: true, uniqueness: true

	#..#

	def self.import_from_json(json)
		for json_data in json
			typp = self.find_or_create_by!(name: json_data['name'])
			
			typp.update_attributes!({
				slug: json_data['slug']
			})
		end
	end

end
