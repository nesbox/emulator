package ui
{
	import model.Gamepad;

	public interface ISetupHandler
	{
		function onSetupSave(joystick:Gamepad):void;
		function onSetupCancel():void;
	}
}