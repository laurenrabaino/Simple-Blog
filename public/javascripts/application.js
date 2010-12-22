jQuery(document).ready(function($){

	/* Admin Menu */
	jQuery("#showEmbeddedAdminMenu").click(function(){
		$('#embeddedAdminMenu').slideDown(600);
		$("#showEmbeddedAdminMenu").hide();
		$("#hideEmbeddedAdminMenu").show();
		return false;
	});

	jQuery("#hideEmbeddedAdminMenu").click(function(){
		$('#embeddedAdminMenu').slideUp(600);
		$("#hideEmbeddedAdminMenu").hide();
		$("#showEmbeddedAdminMenu").show();
		return false;
	});

	jQuery("li[id*=adminMenu]").click(function(){

		menuItem = this.id.replace('adminMenu', '');

		var menuItems = new Array();
		menuItems[1] = "Posts";
		menuItems[2] = "Profiles";
		menuItems[3] = "Comments";
		menuItems[4] = "Pages";
		menuItems[5] = "Categories";
		
		// hide all other menues
		for (i=0; i<menuItems.length; i++){
			$("#subMenu"+menuItems[i]).hide();
			$("#adminMenu"+menuItems[i]).removeClass('active');
		}

		$(this).addClass('active');
		$("#subMenu"+menuItem).show();
		return false;
	});

	/* Reply To Comment */
	jQuery("span[id*=replyToComment]").click(function(){
		spanId = this.id.replace('replyToComment', '');
		commentDataArr = spanId.split('-');
		$("#commentParentId").val(commentDataArr[0]);
		$("#commentLevel").val(commentDataArr[1]);
		$("#replyForm"+commentDataArr[0]).append($('#commentFormContainer'));
		editor = CKEDITOR.instances['comment_body_editor'];
		bodyText = editor.getData();
		if (editor){
			editor.destroy();
		}
		CKEDITOR.remove(editor);
		$('#comment_body_editor').html(bodyText);
		editor = CKEDITOR.replace('comment_body_editor', {width: '444px', toolbar: 'Comments'});
		editor = CKEDITOR.instances['comment_body_editor'];
	});
	
	/* Hover */
	jQuery("li[id*=hoverAnchor]").hover(function(){
        $(this).addClass("hover");
        containerName = this.id.replace('hoverAnchor', '');
		pos = $(this).position();
		$("#hoverContainer"+containerName).css( { "left": (pos.left) + "px", "top": pos.top+11 + "px" } );
		$("#hoverContainer"+containerName).fadeIn();
    }, function(){
		containerName = this.id.replace('hoverAnchor', '');
        $(this).removeClass("hover");
        $("#hoverContainer"+containerName).hide();
    });

	jQuery("ul[id*=hoverContainer]").hover(function(){
        containerName = this.id.replace('hoverContainer', '');
		$("#hoverAnchor"+containerName).addClass("hover");
		$(this).show();
    }, function(){
		containerName = this.id.replace('hoverContainer', '');
		$("#hoverAnchor"+containerName).removeClass("hover");
        $(this).fadeOut();
    });

	/* Suggest Tags */
	jQuery("span[id*=suggestTags]").click(function(){
		
		typeOfContent = this.id.replace('suggestTags', '');
		
		var bodyText = "";
		
		if (typeOfContent == 'Post') {
			var objEditor = CKEDITOR.instances['post_body_editor'];
		} else {
			return;
		}
		
		bodyText += objEditor.getData();
		
		existing_tags = $("#"+typeOfContent.toLowerCase()+"_tag_list").val();
		$("#ajaxSpinner").show();
		bodyContent = jQuery.ajax({
			url: "/tags/suggest",
			type: "POST",
			data: ({text : bodyText, existing_tags : existing_tags}),
			dataType: "html",
			success: function(msg){
				$("#ajaxSpinner").hide();
				$("#"+typeOfContent.toLowerCase()+"_tag_list").val(msg);
			}
		}).responseText;
	});

	/* facebox links */
	jQuery('a[rel*=facebox]').facebox();
	jQuery('img[id*=faceboxImage]').click(function(){
		$.facebox({ image: this.name });
	});

});

function setUrlField(url){
	value = jQuery("input[id*='PhotoUrls']").val();
	jQuery("input[id*='PhotoUrls']").val(value+"::"+url);
}

function createAudioPlayer(player,recording_id,div,hashcode){
	var s1 = new SWFObject(player,'player','600','500','9');
	s1.addParam('allowfullscreen','true');
	s1.addParam('allowscriptaccess','always');
	//s1.addParam('flashvars','file=http://mobiletools.hablacentro.com/radio/retrieve?internal_request='+hashcode+'&file_id='+recording_id);
	s1.addParam('flashvars','file=http://mobiletools.hablacentro.com/public/recordings/transcoded/'+recording_id);
	s1.write(div);
}
