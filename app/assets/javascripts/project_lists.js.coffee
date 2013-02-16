# Sorting the list
jQuery ->
  $('#project_listings').sortable
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))

@sort_listings_by_data_attribute = (attribute, order) ->
  $('ul#project_listings>li.project_listing').tsort
    data: attribute
    order: order
  $.post($('#project_listings').data('update-url'), $('#project_listings').sortable('serialize'))
