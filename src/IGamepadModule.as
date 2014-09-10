package
{
	import flash.display.Bitmap;

	public interface IGamepadModule
	{
		function getGamepadKeysNames():Array;
		function getGamepadImage():Bitmap;
		function getGamepadButton(name:String):GamepadButton;
		function getGamepadDefaultKeys():Array;
		function getSettingsUid():String;
	}
}