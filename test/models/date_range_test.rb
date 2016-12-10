require 'test_helper'

class DateRangeTest < ActiveSupport::TestCase
	attributes = {
		start: DateTime.parse('1999-01-01 00:00:00'),
		end: DateTime.parse('1999-01-01 00:00:00') + 1.week
	}

	# Validation tests

	test "should not save date range without start" do
		date_range = DateRange.new attributes.reject{|k,v| k == :start}
		assert_not date_range.save
	end

	test "should not save date range without end" do
		date_range = DateRange.new attributes.reject{|k,v| k == :end}
		assert_not date_range.save
	end

	test "should not save date range if start is after end" do
		date_range = DateRange.new attributes.merge(end: attributes[:start] - 1.week)
		assert_not date_range.save
	end

	test "should not save date range if duplicate start and end" do
		DateRange.create attributes
		date_range = DateRange.new attributes
		assert_not date_range.save
	end

	test "should save date range" do
		date_range = DateRange.new attributes
		assert date_range.save
	end

	# Method tests

	test "should import date test" do
		# US forum samples
		# - June 2 - 9, 2015
		# - June 30 - July 7, 2015
		# - Dec 29 - Jan 5, 2015   (NOTE: year for the ending date is obviously wrong!)

		# EU forum samples:
		# - February 10, 2015
		# - December 8 - 15, 2015
		# - December 29 - January 4    (NOTE: This specific entry is missing the year value)
		# - January 26 - February 02, 2016
		# - 02 - 09 February, 2016
		# - 23 February - 01 March, 2016
		# - 05 April - 12, 2016
		# - July 05 - July 12, 2016
		# - August 23- 29, 2016    (NOTE: no whitespace between "23" and hyphen)
		# - September 27 - October 04 , 2016    (NOTE: whitespace before comma)

		assert_instance_of DateRange, DateRange.import_date_text('June 2 - 9, 2015')
		assert_instance_of DateRange, DateRange.import_date_text('June 30 - July 7, 2015')
		assert_instance_of DateRange, DateRange.import_date_text('Dec 29 - Jan 5, 2015')
		assert_instance_of DateRange, DateRange.import_date_text('February 10, 2015')
		assert_instance_of DateRange, DateRange.import_date_text('December 8 - 15, 2015')
		assert_instance_of DateRange, DateRange.import_date_text('December 29 - January 4')
		assert_instance_of DateRange, DateRange.import_date_text('January 26 - February 02, 2016')
		assert_instance_of DateRange, DateRange.import_date_text('02 - 09 February, 2016')
		assert_instance_of DateRange, DateRange.import_date_text('23 February - 01 March, 2016')
		assert_instance_of DateRange, DateRange.import_date_text('05 April - 12, 2016')
		assert_instance_of DateRange, DateRange.import_date_text('July 05 - July 12, 2016')
		assert_instance_of DateRange, DateRange.import_date_text('August 23- 29, 2016')
		assert_instance_of DateRange, DateRange.import_date_text('September 27 - October 04 , 2016')
	end

	test "should pass if start is before end" do
		date_range = DateRange.new(start: attributes[:start], end: attributes[:start] + 1.week)
		assert date_range.end_is_after_start
	end

	test "should fail if start equal to end" do
		date_range = DateRange.new(start: attributes[:start], end: attributes[:start])
		assert_not date_range.end_is_after_start
	end

	test "should fail if start is after end" do
		date_range = DateRange.new(start: attributes[:start], end: attributes[:start] - 1.week)
		assert_not date_range.end_is_after_start
	end

	test "should fail if start is missing" do
		date_range = DateRange.new(start: nil, end: attributes[:start] + 1.week)
		assert_not date_range.end_is_after_start
	end

	test "should fail if end is missing" do
		date_range = DateRange.new(start: attributes[:start], end: nil)
		assert_not date_range.end_is_after_start
	end
end
