class Typp < ActiveRecord::Base

	has_many	:heroes

	def self.import_from_json(json)
		for typp in json
			self.create!(name: typp['name'], slug: typp['slug']) unless self.where(name: typp['name']).first
		end
	end

end
