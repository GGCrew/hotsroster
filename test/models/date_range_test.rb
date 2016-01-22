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
		assert_instance_of DateRange, DateRange.import_date_text('Jan 01 - Jan 08, 2000')
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
