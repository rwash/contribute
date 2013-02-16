# Sorting the list
jQuery ->
  # Respond when the user drags projects into place
  $('#project_listings').sortable
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
  # And when they sort using the dropdown menu
  $("#reorder-by-attribute").click ->
    sort_listings_by_data_attribute $('#sort-attribute')[0].value, $('#sort-order')[0].value

@sort_listings_by_data_attribute = (attribute, order) ->
  $('ul#project_listings>li.project_listing').tsort
    data: attribute
    order: order
  $.post($('#project_listings').data('update-url'), $('#project_listings').sortable('serialize'))
