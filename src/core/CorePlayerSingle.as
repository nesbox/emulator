package core
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.ByteArray;
	
	public class CorePlayerSingle extends CorePlayerBase
	{
		public function CorePlayerSingle(core:ICoreModule, handler:ICoreHandler)
		{
			super(core, handler);
		}
		
		public function initSingleEmulation(isNtsc:Boolean, rom:ByteArray, region:String):void
		{
			stage.focus = stage;
			
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
