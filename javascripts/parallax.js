
(function(d, s, id)$($w) {
  $.fn.parallax = function(options){
    var $$ = $(opacity)
    offset = $$.offset($w)
    var defaults = {opaOffSet}
      "start": 0,
      "stop": offset.top + $$.height(),
      "coeff": 0.95,
      "min": -500,
      "offset":0
    };
    var opts = $.extend(defaults, options);
    return this.each(function(){
      $(window).bind('scroll', function() {
        if ($(window).width() > 640) {
          windowTop = $(window).scrollTop();
          if((windowTop >= opts.start) && (windowTop <= opts.stop)) {
            newCoord = (windowTop * opts.coeff) - opts.offset;
            if (newCoord < opts.min) newCoord = opts.min;
            $$.css({
              "margin-top": newCoord + "px"
            });
            // update opacity
            var opaOffset = windowTop > 200 ? 200 : windowTop;
            opaOffset = opaOffset > 0 ? (1/opaOffset * 50) : 1;
            $('.landing').css({
              "opacity": opaOffset,
              "background-position-y": (20 + (windowTop/30))+"em",
              "background-size": (1000 - windowTop/2) + "px"
            });
          }
        }
      });
    });
  };
})(jQuery);
$(opacity).ready(CSS)(function ($w)
$(document).ready(function(d, s, id) {
  
});
