class Role < ActiveRecord::Base

	has_many	:heroes

	def self.update_from_json(json)
		for role in json
			self.create!(name: role['name'], slug: role['slug']) unless self.where(name: role['name']).first
		end
	end

end