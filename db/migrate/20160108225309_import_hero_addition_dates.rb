class ImportHeroAdditionDates < ActiveRecord::Migration
  def up 
  	hero_data = [
			{slug: 'abathur', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'alarak',            release_date: DateTime.parse('2016-09-13')},
			{slug: 'anubarak', 					release_date: DateTime.parse('2014-10-07')},
			{slug: 'artanis', 					release_date: DateTime.parse('2015-10-27'), prerelease_date: DateTime.parse('2015-10-20')},
			{slug: 'arthas', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'auriel',            release_date: DateTime.parse('2016-08-09')},
			{slug: 'azmodan', 					release_date: DateTime.parse('2014-10-07')},
			{slug: 'brightwing', 				release_date: DateTime.parse('2014-03-13')},
			{slug: 'chen', 							release_date: DateTime.parse('2014-09-10')},
			{slug: 'chogall', 					release_date: DateTime.parse('2015-11-17')},
			{slug: 'chromie', 					release_date: DateTime.parse('2016-05-17')},
			{slug: 'dehaka', 						release_date: DateTime.parse('2016-03-29')},
			{slug: 'diablo', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'etc', 							release_date: DateTime.parse('2014-03-13')},
			{slug: 'falstad', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'gazlowe', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'greymane', 					release_date: DateTime.parse('2016-01-12')},
			{slug: 'guldan',            release_date: DateTime.parse('2016-07-12')},
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
			{slug: 'medivh',            release_date: DateTime.parse('2016-06-14')},
			{slug: 'muradin', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'murky', 						release_date: DateTime.parse('2014-05-22')},
			{slug: 'nazeebo', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'nova', 							release_date: DateTime.parse('2014-03-13')},
			{slug: 'ragnaros',          release_date: DateTime.parse('2016-12-20')},
			{slug: 'raynor', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'rehgar', 						release_date: DateTime.parse('2014-07-23')},
			{slug: 'rexxar', 						release_date: DateTime.parse('2015-09-08')},
			{slug: 'samuro',            release_date: DateTime.parse('2016-10-18')},
			{slug: 'sgt-hammer', 				release_date: DateTime.parse('2014-03-13')},
			{slug: 'sonya', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'stitches', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'sylvanas', 					release_date: DateTime.parse('2015-03-24')},
			{slug: 'tassadar', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'the-butcher', 			release_date: DateTime.parse('2015-06-30')},
			{slug: 'the-lost-vikings',	release_date: DateTime.parse('2015-02-10')},
			{slug: 'thrall', 						release_date: DateTime.parse('2015-01-13')},
			{slug: 'tracer', 						release_date: DateTime.parse('2016-04-26')},
			{slug: 'tychus', 						release_date: DateTime.parse('2014-03-18')},
			{slug: 'tyrael', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'tyrande', 					release_date: DateTime.parse('2014-03-13')},
			{slug: 'uther', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'valla', 						release_date: DateTime.parse('2014-03-13')},
			{slug: 'varian',            release_date: DateTime.parse('2016-11-15')},
			{slug: 'xul', 							release_date: DateTime.parse('2016-03-01')},
			{slug: 'zagara', 						release_date: DateTime.parse('2014-06-26')},
			{slug: 'zarya',             release_date: DateTime.parse('2016-09-27')},
			{slug: 'zeratul', 					release_date: DateTime.parse('2014-03-13')}
  	]
 
  	Hero.reset_column_information

 		for hero_datum in hero_data
 			attributes = {} 			
      attributes[:prerelease_date] = (hero_datum[:prerelease_date] ? hero_datum[:prerelease_date] : hero_datum[:release_date])
 			if hero_datum[:release_date] < GAME_LAUNCH_DATE
 				attributes[:release_date] = GAME_LAUNCH_DATE
 			else
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
