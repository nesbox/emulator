package
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.System;

	public final class Tools
	{
		public static function get currentUrl():String
		{
			if (ExternalInterface.available)
			{
				return ExternalInterface.call('function(){return window.location.href}');
			}
		
			return null;
		}
		
		public static function isInteractiveFullscreenSupported():Boolean
		{
			var parts:Array = Capabilities.version.split(' ')[1].split(',');
			var major:int = parts[0];
			var minor:int = parts[1];
				
			return (major > 11) || (major == 11 && minor > 2);
		}
		
		public static function shortLink(url:String, done:Function):void
		{
			var bitly:String = 'http://api.bitly.com/v3/shorten?login=nesbox&apiKey=R_6933c0180c526715fb29e12176373e46&format=json&longUrl=' + escape(url);
			var loader:URLLoader = new URLLoader;
			
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(event:Event):void
			{
				var result:Object = JSON.parse(loader.data);
				
				if(result.status_code == 200 
					&& result.data
					&& result.data.url)
				{
					done(result.data.url);
					return;
				}
				
				done(null);
			});
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void
			{
				done(null);
			});
			
			loader.load(new URLRequest(bitly));
		}
		
		public static function gotoNesboxPage():void
		{
			navigateToURL(new URLRequest('http://nesbox.github.io/emulator/'), '_blank');
		}
	}
}