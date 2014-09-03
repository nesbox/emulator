package model
{
	import flash.net.SharedObject;

	public class Settings
	{
		private var settings:Object = 
			{
				muted:false,
				keyboard:null,
				server:new ServerSettings('127.0.0.1', 8080, 3)
			};
		
		private var sharedSettings:SharedObject;
		
		public function Settings(uid:String)
		{
			sharedSettings = SharedObject.getLocal(uid);
			
			var valid:Boolean = false;
			
			if(sharedSettings.data.settings)
			{
				valid = true;
					
				for(var key:String in settings)
				{
					if(!sharedSettings.data.settings.hasOwnProperty(key))
					{
						valid = false;
						break;
					}
				}
			}

			if(valid)
			{
				for(var validKey:String in settings)
				{
					settings[validKey] = sharedSettings.data.settings[validKey];
				}
				sharedSettings.data.settings = settings;
			}
			else
			{
				sharedSettings.data.settings = settings;
				sharedSettings.flush();
			}
		}
		
		public function get muted():Boolean
		{
			return settings.muted;
		}
		
		public function set muted(value:Boolean):void
		{
			settings.muted = value;
			sharedSettings.flush();
		}
		
		public function get keyboard():Gamepad
		{
			if(settings.keyboard && settings.keyboard as Array)
			{
				var gamepad:Gamepad = new Gamepad(settings.keyboard.length);
				gamepad.codes = settings.keyboard;
				return gamepad;
			}

			return null;
		}
		
		public function set keyboard(value:Gamepad):void
		{
			if(value)
			{
				settings.keyboard = value.codes;
				sharedSettings.flush();
			}
		}
		
		public function get server():ServerSettings
		{
			var serverSettings:ServerSettings = new ServerSettings(settings.server.ip, settings.server.port, settings.server.frameskip);
			
			return serverSettings;
		}
		
		public function set server(value:ServerSettings):void
		{
			settings.server = value;
			sharedSettings.flush();
		}
	}
}
