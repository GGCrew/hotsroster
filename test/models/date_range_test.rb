require 'test_helper'

class DateRangeTest < ActiveSupport::TestCase
	attributes = {
		start: DateTime.parse('1999-01-01 00:00:00'),
		end: DateTime.parse('1999-01-01 00:00:00') + 1.week
	}

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
end
