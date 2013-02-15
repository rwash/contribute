# Sorting the list
jQuery ->
  $('#project_listings').sortable
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
