package server
{
	import flash.utils.ByteArray;

	public interface IApiHandler
	{
		function onApiError(info:String):void;
		function onApiSaved(state:ByteArray):void;
		function onApiLoaded(state:ByteArray):void;
		function onApiNeedSign():void;
		function onApiUserSigned(signed:Boolean):void;
		function onApiState(userLogined:Boolean, state:ByteArray):void;
		function onApiUploaded():void;
		function onApiFavorited(value:Boolean):void;
	}
}