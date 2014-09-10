package core
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.ByteArray;
	import flash.utils.setInterval;
	
	public class CorePlayerNetwork extends CorePlayerBase
	{
		private var recvInput:Array = [];
		private var isFirstPeer:Boolean;
		private var handler:ICorePlayerHandler;
		private var inputQueue:Array = [];
		
		private static const Delimiter:uint = 3;
		
		public function CorePlayerNetwork(core:ICoreModule, handler:ICorePlayerHandler)
		{
			super(core, handler);
			this.handler = handler;
		}
		
		public function initNetworkEmulation(isNtsc:Boolean, isFirstPeer:Boolean, rom:ByteArray, region:String):void
		{
			initEmulation(isNtsc, rom, region);
			
			this.isFirstPeer = isFirstPeer;
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrameNetwork);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			if(isFirstPeer)
			{
				sendInputValue(0);
			}
			else
			{
				handler.sendDummy();
			}
			
			setInterval(function():void
			{
				handler.sendDummy();
			}, 1000);
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
				var input:uint = recvInput.shift();
				
				if(isFirstPeer)
				{
					sendInputValue(inputFlags);
				}
				else
				{
					input = (input & 0xfff) | ((inputFlags & 0xfff) << 12);
					
					sendInputValue(input);
				}
				
				var frames:uint = Delimiter;
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
