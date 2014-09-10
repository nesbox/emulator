package core
{
	public interface ICorePlayerHandler extends ICoreHandler
	{
		function sendInput(input:uint):void;
		function sendDummy():void;
	}
}