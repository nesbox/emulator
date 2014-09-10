package core
{
	import flash.display.FrameLabel;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.ByteArray;
	import flash.utils.setInterval;
	
	public class CorePlayerOwnServer extends CorePlayerBase
	{
		private var recvInput:Array = [];
		private var handler:ICorePlayerHandler;
		private var inputQueue:Array = [];
		private var delimiter:uint;
		
		public function CorePlayerOwnServer(core:ICoreModule, handler:ICorePlayerHandler)
		{
			super(core, handler);
			this.handler = handler;
		}
		
		public function initNetworkEmulation(isNtsc:Boolean, rom:ByteArray, region:String, frameskip:uint):void
		{
			initEmulation(isNtsc, rom, region);
			
			this.delimiter = frameskip;
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrameNetwork);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			sendInputValue(0);
		}
		
		public function recvInputValue(input:uint):void
		{
			recvInput.push(input);
		}
		
		private function sendInputValue(input:uint):void
		{
			handler.sendInput(input);
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			onKey(event.keyCode);
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			onKey(event.keyCode, false);
		}
		
		private function onEnterFrameNetwork(event:Event):void
		{
			if(paused)
			{
				return;
			}
			
			if(inputQueue.length > 0)
			{
				emulate(uint(inputQueue.shift()));
				return;
			}
			
			if(recvInput.length == 1)
			{
				sendInputValue(inputFlags);
				
				var input:uint = recvInput.shift();
				var frames:uint = delimiter;
				
				while(frames--)
				{
					inputQueue.push(input);
				}
				
				emulate(input);
				
				return;
			}
		}
	}
}
