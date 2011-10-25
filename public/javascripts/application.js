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
      $(".tab a").click(function() {
        var $this = $(this);
        $(".tab").removeClass("active");
        $(".tab_content").hide("slow");
        $($this.attr('href')).show('slow');
        $(this).parent().addClass("active");
      });
    });

  })(jQuery)
}
