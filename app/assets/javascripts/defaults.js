$(function (){
	$('#DatePickerEndDate').datepicker();

	// Parse the vlaue inside the div tag. Set the value of the progress bar equal to that.
	// Expand the width so it fills width-wise, set the height so it's like a vertical bar
	$('.progressBar').each(function() {
		var value = parseInt($(this).text());
		value = value + 1; //1 looks like 0. Pad it a little.
		if(value > 100) { value = 100; }

		$(this).empty().progressbar({value: value});
		$(this).find('.ui-progressbar-value').width('100%');
		$(this).find('.ui-progressbar-value').height(value + '%');
	});
});
