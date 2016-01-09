class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter	:define_head_tags

	def define_head_tags
		@head = HashWithIndifferentAccess.new
		@head.merge!(title: nil)
		@head.merge!(meta: HashWithIndifferentAccess.new)
		@head[:meta].merge!(description: nil)
	end
end
