class Franchise < ActiveRecord::Base

	has_many	:heroes

	def self.update_from_json(json)
		for name in json
			self.create!(name: name) unless self.where(name: name).first
		end
	end

end
