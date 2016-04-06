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

	# Class method tests
	
	test "should return normal rotations" do
		expected_date_ranges = DateRange.all.select{|i| !i.special_event}
		assert_equal expected_date_ranges.count, DateRange.normal_rotations.count
		assert_empty DateRange.normal_rotations - expected_date_ranges
	end

	test "should return special events" do
		expected_date_ranges = DateRange.all.select{|i| i.special_event}
		assert_equal expected_date_ranges.count, DateRange.special_events.count
		assert_empty DateRange.special_events - expected_date_ranges
	end

	test "should return current date range" do
		date_ranges = DateRange.all
		date_ranges.reject!{|i| i.start > Date.today}
		date_ranges.sort_by!{|i| [i.end, i.start]}
		expected_date_range = date_ranges.last
		assert_equal DateRange.current, expected_date_range
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
