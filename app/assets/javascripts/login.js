/*=============================================================================
 *
 *  login.js
 *
 *  This is the main javascript file for the login page.
 *
 *  Note: This file doesn't need to be included anywhere except for pages
 *        where login control happens.
 *
 *==========
 */

$(document).ready(function() 
{
	// Javascript needed to set up the tabs correctly.
	$('#student_tab, #ta_tab').click(function (){

	  if ($(this).attr('id') == 'student_tab' && $('#student_panel').css('display') == 'none')
	  {
	    $('#student_panel').toggle();
	    $('#ta_panel').toggle();
	  }
	  
	  if ($(this).attr('id') == 'ta_tab' && $('#ta_panel').css('display') == 'none')
	  {
	    $('#student_panel').toggle();
	    $('#ta_panel').toggle();
	  }
	  
	});
	
	
});
