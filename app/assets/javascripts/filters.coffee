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
			$(this).addClass('filtered')
		else
			$(this).removeClass('filtered')
		return true

	# Multiclass
	getCombinations = (array) ->
		result = []
		f = (prefix, array) ->
		  for index in [0...array.length]
		    do (index) ->
		      result.push prefix.concat [array[index]]
		      f prefix.concat([array[index]]), array.slice(index + 1)
		f [], array
		return result

	roles = $('[data-key="roles"]').filter (index, element) ->
		!$(element).data().selected

	roles = $.map roles, (element, index) ->
		$(element).data().value

	combinations = getCombinations roles
	combinations = combinations.filter (element) ->
		element.length > 1

	for combination in combinations
		do (combination) ->
			selector = (
			  combination.map (element) ->
			    return '[data-roles*="' + element + '"]'
			  ).join('')
			$(selector).attr 'data-filtered', true

	# Show/hide and update counts
	hero_sections = $('.heroes')
	hero_sections.each (index) ->
		hero_count = $(this).find('figure').length
		filtered_heroes = $(this).find('figure[data-filtered=true]')
		unfiltered_heroes = $(this).find('figure[data-filtered=false]')

		# Hide newly-filtered heroes
		filtered_heroes.each (index) ->
			if $(this).css('display') != 'none'
				$(this).animate({height: 'toggle', width: 'toggle'})
			return true

		# Reveal newly-unfiltered heroes
		unfiltered_heroes.each (index) ->
			if $(this).css('display') == 'none'
				$(this).animate({height: 'toggle', width: 'toggle'})
			return true

		unfiltered_count = unfiltered_heroes.length
		if unfiltered_count == hero_count
			message = hero_count + " Heroes"
		else if unfiltered_count != 1
			message = unfiltered_count + " matching Heroes (out of " + hero_count + ")"
		else
			message = unfiltered_count + " matching Hero (out of " + hero_count + ")"
		
		this_parent = $(this).parent()
		if $(this_parent).hasClass('rotation')
			# Rosters page
			$(this_parent).find('.hero_count').text(message)
		else
			# Heroes page
			$('.filters .messages .hero_count').text(message)
		return true
	return true

$(document).on "ready", ->
	$('.filters a').click ->
		icondata = $(this).data()
		icondata.selected = !icondata.selected
		#$(this).data('selected', !$(this).data('selected')) # single-line solution doesn't "read" as well as the two-line solution above
		applyFilters()
		return false
	return true


