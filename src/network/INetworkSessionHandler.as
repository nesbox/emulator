package network
{
	public interface INetworkSessionHandler
	{
		function onNetworkPeer(value:String):void;
		function onNetworkInput(value:uint):void;
		function onNetworkTest():void;
		function onNetworkStart(isFirstPeer:Boolean, ping:uint):void;
	}
}