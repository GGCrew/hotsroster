# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

applyFilters = () ->
	$('.filtered').removeClass('filtered')
	$('.filters a').each (index) ->
		filterdata = $(this).data()
		if !filterdata.selected
			selector = '[data-' + filterdata.key + '="' + filterdata.value + '"]'
			$(selector).addClass('filtered')
		return true
	hero_count = $('.heroes figure').length
	filtered_count = $('.heroes figure.filtered').length
	unfiltered_count = hero_count - filtered_count
	message = unfiltered_count + " matching Heroes (out of " + hero_count + " Heroes)"
	$('.filters .messages').text(message)
	return true
	
$(document).on "ready", ->
  $('.filters a').click ->
    icondata = $(this).data()
    icondata.selected = !icondata.selected
    applyFilters()
    return false
  return true


