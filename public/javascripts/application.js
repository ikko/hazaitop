// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var spinnerImg = '<img src="/hobothemes/clean/images/spinner.gif" class="ajax-loader"/>';

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

  jQuery( function() {
    jQuery('.person-to-org-relation-no-start-time').live( 'click', function(e) {
      var input = jQuery(this)
      jQuery(this).parents('li').find('.start-time-toggler').toggle( function() { if (input.is(':checked')) {
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
      $(".tab a").live('click', function(e) {
        var $this = $(this);
        if (!$this.parent().hasClass("active")) {
          $this.parent().parent().find(".tab").removeClass("active");
          $content = $this.parents('.contents')
          $content.find(".tab_content").hide();
          $content.find($this.attr('href')).show();
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

      // oldal váltó
      $(".page_selector").live("change", function() {
        $(this).parent().find(".pagination").append("<a href='"+$(this).next().find("a:first").attr("href").replace(/page=\d+/, "page="+$(this).val())+"'></a>").find("a:last").click();
      });
    });

  })(jQuery)
}
