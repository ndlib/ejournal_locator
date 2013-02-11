jQuery(function($) {
  $(".search-toggle").click(function(){
    $(".header_search").toggleClass("closed");
    $(".header").toggleClass("open");
  });

  $('#nav').mobileMenu({combine:false, prependTo:'.menu'});
});
