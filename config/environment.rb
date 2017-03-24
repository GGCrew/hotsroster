# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Specify order to when loading fixtures
ENV['FIXTURES'] ||= 'heros,date_ranges,rosters' # Roster model tests check for the existence of data in the other two tables

