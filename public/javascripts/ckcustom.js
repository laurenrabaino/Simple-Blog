/*
Copyright (c) 2003-2009, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

//CKEDITOR.plugins.load( 'embed' );

CKEDITOR.editorConfig = function( config )
{
	config.PreserveSessionOnFileBrowser = true;
	// Define changes to default configuration here. For example:
	config.language = $.cookie("locale");
	config.uiColor = '#f9f9f9';

	//config.ContextMenu = ['Generic','Anchor','Flash','Select','Textarea','Checkbox','Radio','TextField','HiddenField','ImageButton','Button','BulletedList','NumberedList','Table','Form'] ;

	config.resize_enabled = true;
	//config.resize_maxHeight = 2000;
	//config.resize_maxWidth = 750;

	//config.startupFocus = true;

	//config.extraPlugins = "embed"; // works only with en, ru, ua languages

	config.skin = 'office2003'

	config.toolbar = 'HablaGuate';

	config.toolbar_HablaGuate =
	[
		['Bold','Italic','Underline','BulletedList','NumberedList','-','Outdent','Indent','-','Link','Rule','Source'],
	];
	
	config.toolbar_HablaCentro =
	[
		['Bold','Italic','Underline','BulletedList','NumberedList','-','Outdent','Indent','-','Link','Rule','Source','-','Image','FileButton'],
	];

	config.toolbar_Comments =
	[
		['Bold','Italic','Underline'],
	];
};