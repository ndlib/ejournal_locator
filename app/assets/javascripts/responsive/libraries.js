jQuery(document).ready(function(){
  var $ = jQuery;
  $('#nav').mobileMenu({nested:false});
  $(".search-toggle").click(function(){
    $(".header_search").toggleClass("closed");
    $(".header").toggleClass("open");
});
  var pathnameArr = window.location.pathname.split('/');
  switch (pathnameArr[1]) {
    case 'styleguide':
        $('.sg').insertAfter('.header h3');

    break;
  }
});