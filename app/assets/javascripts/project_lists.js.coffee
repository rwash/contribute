# Sorting the list
jQuery ->
  $('#project_listings').sortable
    axis: 'y'
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
