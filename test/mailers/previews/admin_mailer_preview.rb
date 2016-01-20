# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview

	def roster_unrecognized_hero_name_preview
		AdminMailer.roster_unrecognized_hero_name('Blarg', DateRange.last)
	end

	def roster_hero_not_found
		AdminMailer.roster_hero_not_found('Blarg (Slot unlocked at Player Level 5)', DateRange.last)
	end

end
