class Role < ActiveRecord::Base

	has_many	:heroes, dependent: :nullify

	def self.import_from_json(json)
		for json_data in json
			role = self.find_or_create_by!(name: json_data['name'])
			
			role.update_attributes!({
				slug: json_data['slug']
			})
		end
	end

end
