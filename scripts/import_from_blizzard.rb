action = 'Importing Franchises'
puts "#{action}..."
Franchise.import_from_blizzard_hero_pages
puts "#{action} complete!"

action = 'Importing Heroes'
puts "#{action}..."
Hero.import_from_blizzard_hero_pages
puts "#{action} complete!"

action = 'Importing Roster'
puts "#{action}..."
Roster.import_from_blizzard_hero_pages
puts "#{action} complete!"

