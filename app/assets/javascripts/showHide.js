///////////////////////////////////////////////////
// Show/Hide Comment Box                               
// Author: Sam Mills
// Date: 23 May 2012                                     
///////////////////////////////////////////////////

(function ($) {
    $.fn.showHide = function (options) {

		//default vars
        var defaults = {
            speed: 500,
			easing: '',
			changeText: 1,
			showText: 'reply',
			hideText: 'cancel'
			
        };
        var options = $.extend(defaults, options);

        $(this).click(function () {	
           
             $('.toggleDiv').slideUp(options.speed, options.easing);	
			 // this var stores which button you've clicked
             var toggleClick = $(this);
		     // this reads the rel attribute of the button to determine which div id to toggle
		     var toggleDiv = $(this).attr('rel');
		     // show/hide the correct div with the right speed and easing effect
		     $(toggleDiv).slideToggle(options.speed, options.easing, function() {
		     // toggle link text once the animation is completed
			 if(options.changeText==1){
		     $(toggleDiv).is(":visible") ? toggleClick.text(options.hideText) : toggleClick.text(options.showText);
			 }
              });
		   
		  return false;
		   	   
        });

    };
})(jQuery);