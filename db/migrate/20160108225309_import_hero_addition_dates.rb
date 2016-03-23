class ImportHeroAdditionDates < ActiveRecord::Migration
  def up 
  	game_launch_date = DateTime.parse('2015-06-02')
  	hero_data = [
			{slug: 'abathur', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'anubarak', 					release_date: DateTime.parse('2014-10-07')},
			{slug: 'artanis', 					release_date: DateTime.parse('2015-10-27'), prerelease_date: DateTime.parse('2015-10-20')},
			{slug: 'arthas', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'azmodan', 					release_date: DateTime.parse('2014-10-07')},
			{slug: 'brightwing', 				release_date: DateTime.parse('2014-03-13')},
			{slug: 'chen', 							release_date: DateTime.parse('2014-09-10')},
			{slug: 'chogall', 					release_date: DateTime.parse('2015-11-17')},
			{slug: 'diablo', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'etc', 							release_date: DateTime.parse('2014-03-13')},
			{slug: 'falstad', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'gazlowe', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'greymane', 					release_date: DateTime.parse('2016-01-24')},
			{slug: 'illidan', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'jaina', 						release_date: DateTime.parse('2014-12-02')},
			{slug: 'johanna', 					release_date: DateTime.parse('2015-06-02')},
			{slug: 'kaelthas', 					release_date: DateTime.parse('2015-05-12')},
			{slug: 'kerrigan', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'kharazim', 					release_date: DateTime.parse('2015-08-18')},
			{slug: 'leoric', 						release_date: DateTime.parse('2015-07-21')},
			{slug: 'li-ming', 					release_date: DateTime.parse('2016-02-02')},
			{slug: 'lili', 							release_date: DateTime.parse('2014-04-15')},
			{slug: 'lt-morales', 				release_date: DateTime.parse('2015-10-06')},
			{slug: 'lunara', 						release_date: DateTime.parse('2015-12-15')},
			{slug: 'malfurion', 				release_date: DateTime.parse('2014-03-13')},
			{slug: 'muradin', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'murky', 						release_date: DateTime.parse('2014-05-22')},
			{slug: 'nazeebo', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'nova', 							release_date: DateTime.parse('2014-03-13')},
			{slug: 'raynor', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'rehgar', 						release_date: DateTime.parse('2014-07-23')},
			{slug: 'rexxar', 						release_date: DateTime.parse('2015-09-08')},
			{slug: 'sgt-hammer', 				release_date: DateTime.parse('2014-03-13')},
			{slug: 'sonya', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'stitches', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'sylvanas', 					release_date: DateTime.parse('2015-03-24')},
			{slug: 'tassadar', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'the-butcher', 			release_date: DateTime.parse('2015-06-30')},
			{slug: 'the-lost-vikings',	release_date: DateTime.parse('2015-02-10')},
			{slug: 'thrall', 						release_date: DateTime.parse('2015-01-13')},
			{slug: 'tychus', 						release_date: DateTime.parse('2014-03-18')},
			{slug: 'tyrael', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'tyrande', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'uther', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'valla', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'zagara', 						release_date: DateTime.parse('2014-06-26')},
			{slug: 'zeratul', 					release_date: DateTime.parse('2014-03-13')}
  	]
 
  	Hero.reset_column_information

 		for hero_datum in hero_data
 			attributes = {} 			
 			if hero_datum[:release_date] < game_launch_date
 				attributes[:prerelease_date] = hero_datum[:release_date]
 				attributes[:release_date] = game_launch_date
 			else
				#hero_datum[:prerelease_date] ? (hero.prerelease_date = hero_datum[:prerelease_date]) : (hero.prerelease_date = hero_datum[:release_date] )
				attributes[:prerelease_date] = (hero_datum[:prerelease_date] ? hero_datum[:prerelease_date] : hero_datum[:release_date])
 				attributes[:release_date] = hero_datum[:release_date]
 			end
 		
 			say_with_time "Updating #{hero_datum[:slug]}..." do
 				Hero.where(slug: hero_datum[:slug]).update_all(attributes)
 			end
 		end
  end

	def down
		Hero.update_all(release_date: nil)
		Hero.update_all(prerelease_date: nil)
	end
end
