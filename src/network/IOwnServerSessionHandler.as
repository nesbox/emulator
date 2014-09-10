package network
{
	public interface IOwnServerSessionHandler
	{
		function onOwnServerConnected(ip:String, port:int, room:String, frameskip:int):void;
		function onOwnServerDisconnected():void;
		function onOwnServerError():void;
		function onOwnServerInput(input:uint):void;
	}
}