package ui
{
	public interface ISignHandler
	{
		function onSignin(login:String, password:String):void;
		function onSignup(login:String, email:String, password:String):void;
		function onSigninCancel():void;
	}
}