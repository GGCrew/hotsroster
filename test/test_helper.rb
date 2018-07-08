ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # Load fixtures in specific order to avoid "record not found" errors
  fixtures :franchises, :roles, :typps
  fixtures :heros
  fixtures :alternate_hero_names, :hero_roles
  fixtures :date_ranges
  fixtures :rosters

  # Add more helper methods to be used by all tests here...
  def heroes_json
    # Sample data generated via "pp Hero.get_heroes_json(SOURCE_URLS[:heroes][:us])[-21]"
=begin
{"id"=>"Zeratul",
 "name"=>"Zeratul",
 "title"=>"Dark Prelate",
 "baseHeroInfo"=>
  {"role"=>{},
   "skins"=>[],
   "type"=>{},
   "trait"=>{},
   "defaultMount"=>{},
   "abilities"=>[],
   "heroicAbilities"=>[],
   "multiclassRoles"=>[],
   "otherAbilities"=>[],
   "pairedHeroes"=>[]},
 "role"=>
  {"name"=>"Assassin",
   "slug"=>"assassin",
   "description"=>"Assassin Slayers of Heroes and bringers of pain."},
 "roleSecondary"=>{},
 "type"=>{"name"=>"Melee", "slug"=>"melee"},
 "multiclassRoles"=>[],
 "pairedHeroes"=>[],
 "slug"=>"zeratul",
 "franchise"=>"StarCraft",
 "stanceSlug"=>"",
 "difficulty"=>"Hard",
 "stats"=>{"damage"=>0, "utility"=>0, "survivability"=>0, "complexity"=>0},
 "skins"=>[],
 "releaseDate"=>{"year"=>2014, "month"=>3, "day"=>13},
 "alternateHeroInfo"=>[],
 "auxiliaryHeroInfo"=>[],
 "heroStanceName"=>"",
 "analyticsName"=>"zeratul",
 "revealed"=>true,
 "inFreeHeroRotation"=>false,
 "freeRotationMinLevel"=>0,
 "unified"=>false}
=end

		heroes_json = []
		(1..20).each do |index|
			role_slug = "role-#{(1..4).to_a.sample}"
			role_name = role_slug.titleize
			if index == 10
				begin
					secondary_slug = "role-#{(1..4).to_a.sample}"
				end while secondary_slug == role_slug
				secondary_name = secondary_slug.titleize

				role_secondary = {
          "name"=>secondary_name,
          "slug"=>secondary_slug,
          "description"=>"#{secondary_name} Flowery description of secondary role."
        }
			else
				role_secondary = {}
			end

			type_slug = "role-#{(1..2).to_a.sample}"
			type_name = role_slug.titleize

			franchise_value = "role-#{(1..5).to_a.sample}"

			in_free_hero_rotation = (index % 5 == 0)
			free_rotation_min_level = (in_free_hero_rotation ? [5, 7, 12, 15].sample : 0)

      difficulty = ['Easy', 'Medium', 'Hard', 'Very Hard'].sample

      release_date = {
        "year"=>(2014..2018).to_a.sample,
        "month"=>(1..12).to_a.sample,
        "day"=>(1..28).to_a.sample
      }

			heroes_json << {
        "id"=>"Hero #{index}",
        "name"=>"Hero #{index}",
        "title"=>"Title for Hero #{index}",
        "baseHeroInfo"=>{
          "role"=>{},
          "skins"=>[],
          "type"=>{},
          "trait"=>{},
          "defaultMount"=>{},
          "abilities"=>[],
          "heroicAbilities"=>[],
          "multiclassRoles"=>[],
          "otherAbilities"=>[],
          "pairedHeroes"=>[]
        },
        "role"=>{
          "name"=>role_name,
          "slug"=>role_slug,
          "description"=>"#{role_name} Flowery description of role."
        },
        "roleSecondary"=>role_secondary,
        "type"=>{"name"=>type_name, "slug"=>type_slug},
        "multiclassRoles"=>[],
        "pairedHeroes"=>[],
        "slug"=>"hero-#{index}",
        "franchise"=>franchise_value,
        "stanceSlug"=>"",
        "difficulty"=>difficulty,
        "stats"=>{"damage"=>0, "utility"=>0, "survivability"=>0, "complexity"=>0},
        "skins"=>[],
        "releaseDate"=>release_date,
        "alternateHeroInfo"=>[],
        "auxiliaryHeroInfo"=>[],
        "heroStanceName"=>"",
        "analyticsName"=>"Hero #{index}".downcase,
        "revealed"=>true,
        "inFreeHeroRotation"=>in_free_hero_rotation,
        "freeRotationMinLevel"=>free_rotation_min_level
        "unified"=>false
			}
		end

		return heroes_json
  end
end
