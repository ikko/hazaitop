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
        e.preventDefault();
        if ($(this).hasClass('left_arrow')) {
          news = [news.pop()].concat(news);
        } else {
          news.push(news.shift());
        }
        $("#news").replaceWith("<marquee  class='left' id='news'>" + news.join(" ") + "</marquee>");
      });

      //térképszűrők
      $("#person_relation").click(function(){
        if ($(this).is(":checked")) {
          $(".person_relation").attr("checked", "checked")
        } else {
          $(".person_relation").attr("checked", "")
        }
      });
      $("#org_relation").click(function(){
        if ($(this).is(":checked")) {
          $(".org_relation").attr("checked", "checked")
        } else {
          $(".org_relation").attr("checked", "")
        }
      });
    });

  })(jQuery)
}
