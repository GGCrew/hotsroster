action = 'Importing Heroes'
puts "#{action}..."
Hero.import_from_blizzard
puts "#{action} complete!"

action = 'Importing Roster'
puts "#{action}..."
Roster.import_from_blizzard
puts "#{action} complete!"

