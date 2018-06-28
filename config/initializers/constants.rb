GAME_LAUNCH_DATE = DateTime.parse('2015-06-02')

SOURCE_URLS = {
#	heroes: {
#		us: 'http://us.battle.net/heroes/en/heroes/',
#		eu: 'http://eu.battle.net/heroes/en/heroes/'
#	},
	heroes: {
		us: 'https://heroesofthestorm.com/en-us/heroes/'
		#eu: 'https://heroesofthestorm.com/en-eu/heroes/'
	},  
	rosters: {
		us: 'https://us.battle.net/forums/en/heroes/topic/17936383460',
		eu: 'https://eu.battle.net/forums/en/heroes/topic/13604571130'
	},
	patch_notes: {
		us: 'https://us.battle.net/forums/en/heroes/topic/18301004598',
		eu: nil
	},
	sales: {
		us: 'https://us.battle.net/forums/en/heroes/topic/18183929301',
		eu: 'https://eu.battle.net/forums/en/heroes/topic/13605640947'
	}
}

READ_DATA_FROM_LOCAL_DOCS = true
