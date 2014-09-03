package core
{
	import com.adobe.images.PNGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SampleDataEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	public class CorePlayerBase extends Bitmap implements ICorePlayer
	{
		private var coreModule:ICoreModule;
		private var keyCodes:Array;
		private var sound:Sound;
		private var soundChannel:SoundChannel;
		private var pausedValue:Boolean = true;
		private var handler:ICoreHandler;
		private var gamepadSocket:Socket;
		private var gamepadOffsets:Array;
		
		protected var inputFlags:uint;
		
		private static const Port:int = 8087;
		private static const Localhost:String = '127.0.0.1';
		
		private static const CompanionButtonsOrder:Array = 
			[
				'up', 'down', 'left', 'right',
				'a', 'b', 'c',
				'x', 'y', 'z',
				'select', 'start',
				'l', 'r'
			];
		
		public function CorePlayerBase(core:ICoreModule, handler:ICoreHandler)
		{
			this.coreModule = core;
			this.handler = handler;
			
			bitmapData = new BitmapData(Variables.Width, Variables.Height, false, 0x000000);
			
			initGamepad();
		}
		
		private function initGamepad():void
		{
			if(handler.isNeedGamepad())
			{
				gamepadSocket = new Socket;
				
				gamepadSocket.addEventListener(Event.CONNECT, function():void
				{
					var names:Array = coreModule.getGamepadKeysNames();
					gamepadOffsets = [];
					
					for each(var order:String in CompanionButtonsOrder)
					{
						gamepadOffsets.push(names.indexOf(order));
					}
				});
				
				var processGamepad:Function = function(input:uint):uint
				{
					var inputFlags:uint = 0;
					
					for(var index:int = 0; index < gamepadOffsets.length; index++)
					{
						var offset:int = gamepadOffsets[index];
						
						if(offset != -1 && (input & (1 << index)))
						{
							inputFlags |= (1 << offset);
						}
					}
					
					return inputFlags;
				};
				
				gamepadSocket.addEventListener(ProgressEvent.SOCKET_DATA, function():void
				{
					while(gamepadSocket.bytesAvailable)
					{
						var input:uint = gamepadSocket.readUnsignedInt();
						var firstInput:uint = processGamepad(input & 0xffff);
						var secondInput:uint = processGamepad((input & 0xffff0000) >> 16);
						
						inputFlags = ((firstInput & 0xfff) | ((secondInput & 0xfff) << 12));
					}
				});
				
				var connectToGamepad:Function = function():void
				{
					setTimeout(function():void
					{
						gamepadSocket.connect(Localhost, Port);
					}, 1000);
				}
				
				gamepadSocket.addEventListener(Event.CLOSE, function():void
				{
					connectToGamepad();
				});
				
				gamepadSocket.addEventListener(IOErrorEvent.IO_ERROR, function():void
				{
					connectToGamepad();
				});
				
				gamepadSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function():void
				{
					connectToGamepad();
				});
				
				connectToGamepad();
				
			}
		}
		
		public function pause():void
		{
			pausedValue = true;
			
			stopChannel();
		}
		
		public function play():void
		{
			pausedValue = false;
			
			if(!muted)
			{
				startChannel();
			}
		}
		
		public function get paused():Boolean
		{
			return pausedValue;
		}
		
		public function set muted(value:Boolean):void
		{
			coreModule.muted = value;
			
			if(value)
			{
				stopChannel();
			}
			else
			{
				startChannel();
			}
		}

		public function get muted():Boolean
		{
			return coreModule.muted;
		}
		
		private function stopChannel():void
		{
			if(soundChannel)
			{
				soundChannel.stop();
				soundChannel = null;
			}
		}
		
		private function startChannel():void
		{
			if(sound)
			{
				stopChannel();
				soundChannel = sound.play();
			}
		}
		
		public function load(saveDataComp:ByteArray):void
		{
			if (saveDataComp)
			{
				saveDataComp.position = 0;
				var saveData:ByteArray = new ByteArray;
				saveDataComp.readBytes(saveData);
				saveData.position = 0;
				
				if (saveData.bytesAvailable)
				{
					saveData.uncompress();
					coreModule.load(saveData);
				}
			}
		}
		
		public function save():ByteArray
		{
			var saveData:ByteArray = coreModule.save();
			
			if (saveData)
			{
				saveData.compress();
				saveData.position = 0;
			}
			
			return saveData;
		}
		
		public function initEmulation(isNtsc:Boolean, rom:ByteArray, region:String):void
		{
			coreModule.init(isNtsc, rom, region);
			
			stage.frameRate = isNtsc ? Variables.NtscFramerate : Variables.PalFramerate;
			sound = new Sound;
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			
			if(!muted)
			{
				startChannel();
			}
		}
		
		public function updateKeyCodes(codes:Array):void
		{
			keyCodes = codes;
		}
		
		protected function onKey(code:uint, down:Boolean = true):void
		{
			var index:int = keyCodes.indexOf(code);
			var mask:int = 1 << index;
			down ? inputFlags |= mask : inputFlags &= ~mask;
		}
		
		protected function emulate(input:uint):void
		{
			coreModule.tick(input, bitmapData);

			if(handler)
			{
				handler.onEmulate();
			}
		}
		
		private function onSampleData(event:SampleDataEvent):void
		{
			coreModule.sound(event.data);
		}
		
		public function get screen():ByteArray
		{
			var data:BitmapData = new BitmapData(Variables.Width, Variables.Height);
			data.copyPixels(bitmapData, new Rectangle(0, 0, Variables.Width, Variables.Height), new Point);
			return PNGEncoder.encode(data);
		}
	}
}
