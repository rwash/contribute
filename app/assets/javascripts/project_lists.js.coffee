# Sorting the list
jQuery ->
  $('#listings').sortable
    axis: 'y'
    dropOnEmpty: false
    handle: '.handle'
    cursor: 'crosshair'
    items: 'li'
    opacity: 0.4
    scroll: true
    update: ->
      $.ajax
        type: 'post'
        data: $('#listings').sortable('serialize') + "&title=" + $('#title').val() + "&authenticity_token=" + "<%= form_authenticity_token %>"
        dataType: 'script'
        complete: (response) ->
          $('#listings').effect('highlight');
        url: '<%= "/project_lists/#{id}/listings/sort" %>'
