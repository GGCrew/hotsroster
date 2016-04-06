class AddSpecialEventToRotation < ActiveRecord::Migration
  def change
  	add_column	'date_ranges',	'special_event',	:boolean,	after: 'end', default: false
  	add_column	'date_ranges',	'special_event_name',	:string,	after: 'special_event'
  end
end
