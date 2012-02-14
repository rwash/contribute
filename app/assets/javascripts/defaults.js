$(function (){
	$('#DatePickerEndDate').datepicker();

	// Parse the vlaue inside the div tag. Set the value of the progress bar equal to that.
	// Expand the width so it fills width-wise, set the height so it's like a vertical bar
	$('.progressBar').each(function() {
		var value = parseInt($(this).text());
		value = value + 1;
		$(this).empty().progressbar({value: value});
		$( '.ui-progressbar-value' ).width('100%');
		$( '.ui-progressbar-value' ).height(value + '%');
	});
});
