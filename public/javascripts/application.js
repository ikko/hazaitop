// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

if (typeof jQuery != 'undefined') { 
  jQuery( function() {
    jQuery('.person-to-org-relation-no-end-time').live( 'click', function(e) {
      var input = jQuery(this)
      jQuery(this).parents('li').find('.end-time-toggler').toggle( function() { if (input.is(':checked')) {
        jQuery(this).css('display', 'none');
      }
      else {
        jQuery(this).css('display', 'block');
      }} );
    });
  });

  (function($){
    $(function() {
      // tabváltás
      $(".tab a").click(function(e) {
        var $this = $(this);
        if (!$this.parent().hasClass("active")) {
          $(".tab").removeClass("active");
          $(".tab_content").hide();
          $($this.attr('href')).show();
          $(this).parent().addClass("active");
        }
        e.preventDefault();
      });

      //hírléptetés
      $("#arrows a").click(function(e) {
        var next_news, actual_news = $("#news li.active");
        if (actual_news.next().length>0) {
          next_news = actual_news.next();
        } else {
          next_news = $("#news li:first");
        }
        $("#news li").removeClass("active").hide();
        next_news.addClass("active").show();
        e.preventDefault();
      });
    });

  })(jQuery)
}
