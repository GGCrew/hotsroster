class Role < ActiveRecord::Base

	has_many	:heroes, dependent: :nullify, inverse_of: :role

	#..#

	validates :name, :slug, presence: true, uniqueness: true

	#..#

	def self.import_from_json(json)
		for json_data in json
			attributes = {
				name: json_data['name'],
				slug: json_data['slug']
			}
				
			role = self.find_by(slug: attributes[:slug])
			role = self.create!(attributes) unless role
			
			role.update_attributes!(attributes)
		end

		return true
	end

end
