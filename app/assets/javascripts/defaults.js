$(function (){
	$('#DatePickerEndDate').datepicker();
	$('#DatePickerEndDate').datepicker("option", "dateFormat", "yy-mm-dd");

	// Parse the value inside the div tag. Set the value of the progress bar equal to that.
	// Expand the width so it fills width-wise, set the height so it's like a vertical bar
	$('.contributionBar').each(function() {
		var pbValue = parseInt($(this).text());
		pbValue = pbValue + 1; //1 looks like 0. Pad it a little.
		if(pbValue > 100) { pbValue = 100; }

		$(this).empty().progressbar({ value: pbValue });
		$(this).find('.ui-progressbar-value').width('100%');
		$(this).find('.ui-progressbar-value').height(pbValue + '%');
	});

	$('#flash').delay(6000).fadeOut(500);
});
