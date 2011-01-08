jQuery(document).ready(function($){
	jQuery('#pages').sortable({
		items: "> li[id*=pageId]",
		stop: function (event, ui){
			positions = [];
			pages = $('#pages li[id*=pageId]');
			for (i=0; i<pages.length; i++){
				positions[i] = pages[i].id.replace('pageId', '');
			}
		
			resultArray = $.ajax({
				url: "/pages/set_order",
				type: "POST",
				data: ({positions : positions}),
				dataType: "text"
			}).responseText;
		}
	}).disableSelection();
});
