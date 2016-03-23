class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@HotSRoster.com"
  layout 'mailer'

	# The following method is a workaround
	# For no discenerable reason, these environment variable are not being read during application initialization
  def self.set_smtp_settings
		self.smtp_settings = {
		  :address              => "smtp.gmail.com",
		  :port                 => 587,
		  :user_name            => ENV['GMAIL_USERNAME'],
		  :password             => ENV['GMAIL_PASSWORD'],
		  :authentication       => "plain",
		  :enable_starttls_auto => true
		} unless self.smtp_settings[:user_name] && self.smtp_settings[:password]

		return true
  end

	def self.format_date_range(date_range)
		format = '%Y-%m-%d'
		return "#{date_range.start.strftime(format)}::#{date_range.end.strftime(format)}"
	end
end
