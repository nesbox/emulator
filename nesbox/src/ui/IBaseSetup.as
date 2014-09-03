package ui
{
	import flash.display.DisplayObject;
	
	import model.Gamepad;

	public interface IBaseSetup
	{
		function show(gamepad:Gamepad):void;
		function get sprite():DisplayObject;
		function get visible():Boolean;
		function set visible(value:Boolean):void;
	}
}