class Role < ActiveRecord::Base

	has_many	:hero_roles,	dependent: :destroy,	inverse_of:	:role
	has_many	:heroes,	through: :hero_roles

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

	def self.import_from_heroes_json(heroes_json)
		json = heroes_json.map{|i| [i['role'], i['roleSecondary']]}
		json.flatten!
		json.uniq!
		json.reject!{|i| i.empty?}

		return self.import_from_json(json)
	end

end
