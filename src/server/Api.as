package server
{
	import flash.utils.ByteArray;

	public class Api
	{
		public function Api(handler:IApiHandler, domain:String) {}
		public function isFavorited(rom:String):void {}
		public function favorite(rom:String, value:Boolean):void {}
		public function check(rom:String):void {}
		public function loadState(rom:String, user:String):void {}
		public function loadWalk(rom:String, user:String):void {}
		public function save(rom:String, state:ByteArray, screen:ByteArray):void {}
		public function uploadWalk(rom:String, walk:ByteArray):void {}
		public function screen(rom:String, screen:ByteArray):void {}
	}
}