package
{
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class GameData
	{
		public var domain:String;
		public var rom:String;
		public var game:String;
		public var action:String;
		public var value:String;
		public var data:ByteArray;
		public var ntsc:Boolean;
		public var region:String;
		public var locale:String;
		public var core:ICoreModule;
		public var module:String;
		public var system:String;
		public var baseUrl:String;
		public var url:String;
		
		private var handler:IGameDataHandler;
		
		public static const One:String 		= 'one';
		public static const Arena:String 	= 'arena';
		public static const Walk:String 	= 'walk';
		public static const Save:String 	= 'save';
		public static const Own:String 		= 'own';
		public static const Room:String 	= 'room';
		
		private static const ZipExt:String = '.zip';
		
		public function GameData(handler:IGameDataHandler, loaderUrl:String)
		{
			this.handler = handler;
			
			this.ntsc = true;
			this.region = 'u';
			
			var swfUrl:String = loaderUrl.substring(0, loaderUrl.indexOf('.swf'));
			this.baseUrl = swfUrl.split('/').slice(0,-1).join('/');
		}

		public function loadParams(parameters:Object):void
		{
			this.system = parameters['system'];
			this.game = parameters['game'];
			this.rom = parameters['rom'];
			this.url = parameters['url'];
			this.locale = parameters['locale'] || 'en';
			this.action = parameters['action'] || Own;
			
			this.module = this.system + '.swf';
		}
		
		private function parseLocale(json:String):void
		{
			var locale:Locale = Locale.instance;
			var data:Object = JSON.parse(json);
			
			for(var key:String in data)
			{
				if(locale.hasOwnProperty(key))
				{
					locale[key] = data[key];
				}
			}
		}
		
		public function loadLocale():void
		{
			if (this.locale == 'en')
			{
				[Embed(source='/assets/en.json', mimeType="application/octet-stream")]
				const LocaleJson:Class;
				
				parseLocale(new LocaleJson());
				
				handler.onLoadLocale();				
			}
			else
			{
				var localeLoader:URLLoader = new URLLoader();
				localeLoader.dataFormat = URLLoaderDataFormat.TEXT;
				
				localeLoader.addEventListener(Event.COMPLETE, function():void
				{
					parseLocale(localeLoader.data);
					
					handler.onLoadLocale();
				});
				
				localeLoader.load(new URLRequest(this.locale + '.json'));
			}
		}
		
		public function parseOwnRomName(name:String):void
		{
			if (name.indexOf(ZipExt) != -1)
			{
				var zip:FZip = new FZip();
				
				zip.addEventListener(Event.COMPLETE, function():void
				{
					var romFile:FZipFile = zip.getFileAt(0);
					
					data = romFile.content;
					
					parseOwnRomName(romFile.filename);
				});
				
				zip.loadBytes(data);
				
				return;
			}
			
			const Modules:Object = 
				{
					'nes':'nes.swf',
					'smc':'snes.swf',
					'gen':'sega.swf',
					'gb':'gb.swf',
					'gbc':'gb.swf',
					'gba':'gba.swf'
				};
			
			const Regions:Array = ['E', 'U', 'J'];
			
			for(var ext:String in Modules)
			{
				var length:int = (name.length - ext.length - 1);
				if(name.indexOf('.' + ext) == length)
				{
					this.rom = name.substr(0, length);
					this.module = Modules[ext];
					this.system = module.split('.swf')[0];
					break;
				}
			}
			
			for each(var region:String in Regions)
			{
				if(name.indexOf('('+region+')') != -1)
				{
					this.ntsc = region != 'E';
					this.region = region.toLowerCase();
					break;
				}
			}
		}
		
		public function init():void
		{
			var self:GameData = this;
			
			var request:URLRequest = new URLRequest([self.baseUrl, self.module].join('/'));
			var moduleLoader:Loader = new Loader;
			
			moduleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function():void
			{
				self.core = moduleLoader.content as ICoreModule;
				
				Variables.Width = self.core.getWidth();
				Variables.Height = self.core.getHeight();
				
				if (self.action == Own)
				{
					if (self.url == null)
						handler.onLoadRom();
					else
						loadRom();
				}
			
			});
			
			moduleLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void
			{
				handler.onInfoShow('<p>' + 
					Locale.instance.loading_emulator + 
					' ' + int(event.bytesLoaded * 100 / event.bytesTotal) + '%<p>');
			});
			
			moduleLoader.load(request);	
		}
		
		private function loadRom():void
		{
			rom = rom || url.split('/').pop();
			
			var romLoader:URLLoader = new URLLoader();
			romLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			romLoader.addEventListener(Event.COMPLETE, function():void 
			{
				if (rom.indexOf(ZipExt) != -1)
				{
					var zip:FZip = new FZip();
					
					zip.addEventListener(Event.COMPLETE, function():void
					{
						var romFile:FZipFile = zip.getFileAt(0);
						
						data = romFile.content;
					});
					
					zip.loadBytes(romLoader.data);
				}
				else
				{
					data = romLoader.data;	
				}
				
				handler.onLoadRom();
			});
			
			romLoader.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void
			{
				handler.onInfoShow('<p>' + 
					Locale.instance.loading_game + 
					' ' + int(event.bytesLoaded * 100 / event.bytesTotal) + '%<p>');
			});
			
			romLoader.load(new URLRequest(url));
		}
	}
}