class AdminMailer < ApplicationMailer
	@@admin = ENV['SITE_ADMIN']
	
	def unrecognized_hero_name(hero_name)
		@hero_name = hero_name
		
		subject = [
			'Unrecognized Hero Name', 
			@hero_name
		].join(' - ')
		
		AdminMailer.set_smtp_settings
		mail(to: @@admin,  subject: subject)
	end

	def hero_not_found(hero_text)
		@hero_text = hero_text
		
		subject = [
			'Hero Not Found'
		].join(' - ')
		
		AdminMailer.set_smtp_settings
		mail(to: @@admin,  subject: subject)
	end

end
