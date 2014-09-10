package
{
	import flash.external.ExternalInterface;

	public class JSProxy
	{
		public static function windowOpen(url:String, title:String, width:int = 800, height:int = 400):void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.call('function(){window.open("' + url + 
					'", "' + title + '", "width=' + width + ',height=' + 300 + '");}');
			}
		}
		
		public static function showSignInModal():void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.call('function(){$("#signin").modal("show");}');
			}
		}
		
		public static function showSignUpModal():void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.call('function(){$("#signup").modal("show");}');
			}
		}
		
		public static function onNetworkInit(peer:String = null):void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.call(peer && peer.length == 64
					? 'function(){Client.onNetworkInit("'+peer+'");}' 
					: 'function(){Client.onNetworkInit();}');
			}
		}
		
		public static function addCallback(name:String, callback:Function):void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback(name, callback);
			}
		}
		
		public static function showDefaultKeyboard():void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.call('function(){Client.showDefaultKeyboard();}');
			}
		}
		
		public static function resizeOwnEmulator(width:int, height:int):void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.call('function(){resizeOwnEmulator("'+width+'px", "'+height+'px");}');
			}
		}
		
		public static function initSigningCallback(callback:Function):void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback('onUserSigned', function(signed:Boolean):void
				{
					callback(signed);
				});
			}
		}
		
		public static function log(value:String):void
		{
			trace(value);
			
			if(ExternalInterface.available)
			{
				ExternalInterface.call('function(){console.log("'+value+'");}');
			}
		}
	}
}