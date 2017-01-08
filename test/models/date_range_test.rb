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


	# Scope tests

	test "should return date ranges since game launch" do
		expected_date_ranges = DateRange.all
		expected_date_ranges = expected_date_ranges.reject{|i| i.start < GAME_LAUNCH_DATE}
		expected_date_range_ids = expected_date_ranges.map(&:id)

		date_range_ids = DateRange.since_game_launch.select(:id).map(&:id)

		assert_equal expected_date_range_ids.length, date_range_ids.length
		assert_empty expected_date_range_ids - date_range_ids
	end

	test "should return date ranges since specific start dates" do
		20.times do
			start_date = DateRange.all.sample.start

			expected_date_ranges = DateRange.all
			expected_date_ranges = expected_date_ranges.reject{|i| i.start < start_date}
			expected_date_range_ids = expected_date_ranges.map(&:id)

			date_range_ids = DateRange.since_start_date(start_date).select(:id).map(&:id)

			assert_equal expected_date_range_ids.length, date_range_ids.length
			assert_empty expected_date_range_ids - date_range_ids
		end
	end


	# Method tests

	test "should import date text" do
		# US website samples:
		# - Dec 27, 2016 – Jan 3, 2017

		# EU website samples:
		# - 27-Dec-2016 – 03-Jan-2017

		# US forum samples
		# - June 2 - 9, 2015
		# - June 30 - July 7, 2015
		# - Dec 29 - Jan 5, 2015   (NOTE: year for the ending date is obviously wrong!  Should be 2016)
		# - Jan 3 - 10, 2016 (NOTE: Should be 2017)

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

		assert_instance_of DateRange, DateRange.import_date_text('Dec 27, 2016 – Jan 3, 2017')
		assert_instance_of DateRange, DateRange.import_date_text('27-Dec-2016 – 03-Jan-2017')
		assert_instance_of DateRange, DateRange.import_date_text('June 2 - 9, 2015')
		assert_instance_of DateRange, DateRange.import_date_text('June 30 - July 7, 2015')
		assert_instance_of DateRange, DateRange.import_date_text('Dec 29 - Jan 5, 2015')
		assert_instance_of DateRange, DateRange.import_date_text('Jan 3 - 10, 2016')
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

	test "should import from specific blizzard hero pages" do
		SOURCE_URLS[:heroes].each do |country, address|
			assert DateRange.import_from_blizzard_hero_page(address)
		end
	end

	test "should import from blizzard hero pages" do
		assert DateRange.import_from_blizzard_hero_pages
	end

	test "should import from post" do
		# <div class="TopicPost-bodyContent" data-topic-post-body-content="true">
		# 	<span class="underline">
		# 		<strong>Free-to-Play Hero Rotation: Jan 3 - 10, 2016</strong>
		# 	</span>
		# 	<br />
		# 	<ul>
		# 		<li>Malfurion</li>
		# 		<li>Valla</li>
		# 		<li>Tyrael</li>
		# 		<li>Kael'thas</li>
		# 		<li>Zarya</li>
		# 		<li>Sylvanas</li>
		# 		<li>Artanis (Slot unlocked at Player Level 5)</li>
		# 		<li>Brightwing (Slot unlocked at Player Level 7)</li>
		# 		<li>Alarak (Slot unlocked at Player Level 12)</li>
		# 		<li>Medivh (Slot unlocked at Player Level 15)</li>
		# 	</ul>
		# </div>

		html = '<div class="TopicPost-bodyContent" data-topic-post-body-content="true"><span class="underline"><strong>Free-to-Play Hero Rotation: Jan 3 - 10, 2016</strong></span><br /><ul><li>Malfurion</li><li>Valla</li><li>Tyrael</li><li>Kael\'thas</li><li>Zarya</li><li>Sylvanas</li><li>Artanis (Slot unlocked at Player Level 5)</li><li>Brightwing (Slot unlocked at Player Level 7)</li><li>Alarak (Slot unlocked at Player Level 12)</li><li>Medivh (Slot unlocked at Player Level 15)</li></ul></div>'
		fragment = Nokogiri::XML.fragment(html)
		post_detail = fragment.children

		assert_instance_of DateRange, DateRange.import_from_post(post_detail)
	end

end
