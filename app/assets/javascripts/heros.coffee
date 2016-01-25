# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

applyFilters = () ->
	$('.filtered').removeClass('filtered')
	$('.filters a').each (index) ->
		filterdata = $(this).data()
		console.log filterdata
		if !filterdata.selected
			selector = '[data-' + filterdata.key + '="' + filterdata.value + '"]'
			console.log selector
			$(selector).addClass('filtered')
		return true
	return true
	
$(document).on "ready", ->
  $('.filters a').click ->
    icondata = $(this).data()
    icondata.selected = !icondata.selected
    applyFilters()
    return false
  return true


