# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

applyFilters = () ->
	# Clear filtered status
	$('[data-filtered=true]').attr('data-filtered', false)

	# Apply filtered status to filtered items
	$('.filters a').each (index) ->
		filterdata = $(this).data()
		if !filterdata.selected
			selector = '[data-' + filterdata.key + '="' + filterdata.value + '"]'
			$(selector).attr('data-filtered', true)
		return true

	filtered_heroes = $('.heroes figure[data-filtered=true]')
	unfiltered_heroes = $('.heroes figure[data-filtered=false]')

	# Hide newly-filtered heroes
	filtered_heroes.each (index) ->
		if $(this).css('display') != 'none'
				$(this).slideUp()
		return true

	# Reveal newly-unfiltered heroes
	unfiltered_heroes.each (index) ->
		if $(this).css('display') == 'none'
				$(this).slideDown()
		return true

	hero_count = $('.heroes figure').length
	unfiltered_count = unfiltered_heroes.length
	message = unfiltered_count + " matching Heroes (out of " + hero_count + " Heroes)"
	$('.filters .messages').text(message)
	return true

$(document).on "ready", ->
	$('.filters a').click ->
		#icondata = $(this).data()
		#icondata.selected = !icondata.selected
		$(this).data('selected', !$(this).data('selected'))
		applyFilters()
		return false
	return true


