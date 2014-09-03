package core
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class CorePlayerWalk extends CorePlayerBase
	{
		private var walkData:ByteArray;
		
		public function CorePlayerWalk(core:ICoreModule, handler:ICoreHandler)
		{
			super(core, handler);
		}
		
		public function initWalkEmulation(isNtsc:Boolean, walk:ByteArray, rom:ByteArray, region:String):void
		{
			initEmulation(isNtsc, rom, region);
			
			walk.position = 0;
			walkData = new ByteArray;
			walk.readBytes(walkData);
			walkData.position = 0;
			
			stage.addEventListener(Event.ENTER_FRAME, onWalkEnterFrame);
		}
		
		private function onWalkEnterFrame(event:Event):void
		{
			if(!paused)
			{
				if(walkData.bytesAvailable)
				{
					var input:uint = walkData.readUnsignedShort();
					emulate(input & 0xfff);
				}
			}
		}
	}
}
