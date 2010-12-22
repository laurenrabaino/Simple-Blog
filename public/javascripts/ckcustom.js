/*
Copyright (c) 2003-2009, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	config.PreserveSessionOnFileBrowser = true;
	config.language = $.cookie("locale");
	config.uiColor = '#f9f9f9';

	config.resize_enabled = true;

	config.skin = 'office2003'

	config.toolbar = 'SimpleBlog';

	config.toolbar_SimpleBlog =
	[
		['Bold','Italic','Underline','BulletedList','NumberedList','-','Outdent','Indent','-','Link','Rule','Source'],
	];
	
	config.toolbar_Comments =
	[
		['Bold','Italic','Underline'],
	];
};