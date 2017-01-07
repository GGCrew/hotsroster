ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def heroes_json 
  	# {"name"=>"Zeratul", "title"=>"Dark Prelate", "role"=>{"name"=>"Assassin", "slug"=>"assassin"}, "roleSecondary"=>{}, "type"=>{"name"=>"Melee", "slug"=>"melee"}, "stats"=>{"damage"=>0, "utility"=>0, "survivability"=>0, "complexity"=>0}, "slug"=>"zeratul", "franchise"=>"starcraft", "analyticsName"=>"Zeratul", "trait"=>{}, "skins"=>[], "abilities"=>[], "heroicAbilities"=>[], "revealed"=>true, "inFreeHeroRotation"=>false, "freeRotationMinLevel"=>0}

		heroes_json = []
		(1..20).each do |index|
			role_slug = "role-#{(1..4).to_a.sample}"
			role_name = role_slug.titleize
			if index == 10
				begin
					secondary_slug = "role-#{(1..4).to_a.sample}"
				end while secondary_slug == role_slug
				secondary_name = secondary_slug.titleize
				
				role_secondary = {"name"=>secondary_name, "slug"=>secondary_slug}
			else
				role_secondary = {}
			end
			
			type_slug = "role-#{(1..2).to_a.sample}"
			type_name = role_slug.titleize

			franchise_value = "role-#{(1..5).to_a.sample}"

			in_free_hero_rotation = (index % 5 == 0)
			free_rotation_min_level = (in_free_hero_rotation ? [5, 7, 12, 15].sample : 0)
			
			heroes_json << {
				"name"=>"Hero #{index}",
				"title"=>"Title for Hero #{index}",
				"role"=>{"name"=>role_name, "slug"=>role_slug},
				"roleSecondary"=>role_secondary,
				"type"=>{"name"=>type_name, "slug"=>type_slug},
				"stats"=>{"damage"=>0, "utility"=>0, "survivability"=>0, "complexity"=>0},
				"slug"=>"hero-#{index}",
				"franchise"=>franchise_value,
				"analyticsName"=>"Hero #{index}",
				"trait"=>{},
				"skins"=>[],
				"abilities"=>[],
				"heroicAbilities"=>[],
				"revealed"=>true,
				"inFreeHeroRotation"=>in_free_hero_rotation,
				"freeRotationMinLevel"=>free_rotation_min_level
			}
		end

		return heroes_json
  end
end
