class ImportHeroGender < ActiveRecord::Migration

	# Data source: https://www.facebook.com/BlizzHeroes/posts/584984145044427

	# Assume unspecified are male (because they make up the majority of characters)
	GENDER_ASSIGNMENTS = {
		males: [],
		females: [	
			'auriel', 
			'brightwing', 
			'chromie', 
			'jaina', 
			'johanna', 
			'kerrigan', 
			'li-ming', 
			'lili', 
			'lt-morales', 
			'lunara', 
			'nova', 				 
			'sgt-hammer', 
			'sonya', 
			'sylvanas', 
			'tracer', 
			'tyrande', 
			'valeera', 
			'valla', 
			'zagara', 
			'zarya'
		],
		other: []
	}

  def up
		# Assume unspecified are male (because they make up the majority of characters)
  	Hero.update_all(gender: 'male')
  	Hero.where(slug: GENDER_ASSIGNMENTS[:females]).update_all(gender: 'female')
  	Hero.where(slug: GENDER_ASSIGNMENTS[:other]).update_all(gender: nil)
  end

	def down
	end
end
