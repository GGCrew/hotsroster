class Franchise < ActiveRecord::Base

	has_many	:heroes, dependent: :nullify

	def self.import_from_json(json)
		for name in json
			self.find_or_create_by!(name: name)
		end

		return true
	end

end
