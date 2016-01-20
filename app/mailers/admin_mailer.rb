class AdminMailer < ApplicationMailer
	@@admin = ENV['SITE_ADMIN']
	
	def roster_unrecognized_hero_name(hero_name, date_range)
		@hero_name = hero_name
		@date_range = AdminMailer.format_date_range(date_range)
		
		subject = [
			@date_range,
			'Unrecognized Hero Name', 
			@hero_name
		].join(' - ')
		
		AdminMailer.set_smtp_settings
		mail(to: @@admin,  subject: subject)
	end

	def roster_hero_not_found(hero_text, date_range)
		@hero_text = hero_text
		@date_range = AdminMailer.format_date_range(date_range)
		
		subject = [
			@date_range,
			'Hero Not Found'
		].join(' - ')
		
		AdminMailer.set_smtp_settings
		mail(to: @@admin,  subject: subject)
	end

end
