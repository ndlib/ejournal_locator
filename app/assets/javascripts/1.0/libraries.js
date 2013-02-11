(function($){

$(document).ready(function(){
	

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
  	if ($(window).width() < 960) {
    	
  	}
 	else {
    if ($("#gallery").length > 0) {
    	$("#gallery").after('<div id="chat"><div id="chat-head">Click to Chat with a Librarian <img src="/images/blue_arrow_horiz.png" /></div><div id="chat-widget"><div class="libraryh3lp" jid="nd-ask-a-lib@chat.libraryh3lp.com"><iframe src="http://libraryh3lp.com/chat/nd-ask-a-lib@chat.libraryh3lp.com?skin=10273&amp;theme=gota&amp;title=Ask%20a%20Librarian&amp;identity=asklib" frameborder="0" style="width: 257px; height: 300px; border: 0px inset #2a4480;"></iframe></div></div></div>');
    }
 	}


	$("#one_search").val($("#one_search").siblings('.legend').text());
	$("#catplus_search").val($("#catplus_search").siblings('.legend').text());
	$("#articles_search").val($("#articles_search").siblings('.legend').text());
	$("#journals_search").val($("#journals_search").siblings('.legend').text());
	$("#databases_search").val($("#databases_search").siblings('.legend').text());
	$("#ebooks_search").val($("#ebooks_search").siblings('.legend').text());




});

})(jQuery);
