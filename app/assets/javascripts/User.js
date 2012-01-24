/*
* User.js
*
* Defines a class that represents a user.
*
*/

function User ()
{
	/*----------INSTANCE VARIABLES-------------*/
	
	this.username = $('#user_id').val();

	this.password = $('#user_token').val();

	this.isTA = $('#is_ta').val();
	
	/*---------INSTANCE METHODS---------------*/
	
	this.getName = function ()
	{
		return this.username;
	}
	
	this.getPassword = function ()
	{
		return this.password;
	}

}
