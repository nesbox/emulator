package core
{
	import com.adobe.images.PNGEncoder;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.ByteArray;
	
	public class CorePlayerContest extends CorePlayerBase
	{
		private var walkData:ByteArray;
		
		public function CorePlayerContest(core:ICoreModule, handler:ICoreHandler)
		{
			super(core, handler);
		}
		
		public function getWalk():ByteArray
		{
			var data:ByteArray = new ByteArray;
			
			walkData.position = 0;
			walkData.readBytes(data);
			
			data.compress();
			data.position = 0;
			
			return data;
		}
		
		public function initContestEmulation(isNtsc:Boolean, rom:ByteArray, region:String):void
		{
			walkData = new ByteArray;
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			initEmulation(isNtsc, rom, region);
		}
		
		private function onEnterFrame(event:Event):void
		{
			if(!paused)
			{
				emulate(inputFlags);
				
				walkData.writeShort(inputFlags & 0xfff);
			}
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			onKey(event.keyCode);
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			onKey(event.keyCode, false);
		}
	}
}
