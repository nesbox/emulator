package
{
	import flash.external.ExternalInterface;

	public final class Analytics
	{
		private static function trackEvent(action:String, label:String):void
		{

		}

		private static function trackStartEvent(label:String):void
		{
			trackEvent('start', label);
		}

		public static function trackStartSingleEvent():void
		{
			trackStartEvent('single');
		}

		public static function trackOwnRomEvent():void
		{
			trackStartEvent('own');
		}

		public static function trackStartSocialSingleEvent():void
		{
			trackStartEvent('social-single');
		}
		
		public static function trackStartSocialNetworkEvent():void
		{
			trackStartEvent('social-network');
		}

		public static function trackStartNetworkEvent():void
		{
			trackStartEvent('network');
		}
		
		public static function trackOwnServerEvent():void
		{
			trackStartEvent('own-server');
		}

		public static function trackStartWalkEvent():void
		{
			trackStartEvent('walk');
		}
		
		public static function trackStartContestEvent():void
		{
			trackStartEvent('contest');
		}

		private static function trackActionEvent(label:String):void
		{
			trackEvent('action', label);
		}

		public static function trackActionMuteEvent():void
		{
			trackActionEvent('mute');
		}

		public static function trackActionFullscreenEvent():void
		{
			trackActionEvent('fullscreen');
		}
		
		public static function trackActionLoadEvent():void
		{
			trackActionEvent('load');
		}

		public static function trackActionSaveEvent():void
		{
			trackActionEvent('save');
		}
		
		public static function trackActionSetupEvent():void
		{
			trackActionEvent('setup');
		}
		
		public static function trackActionUploadEvent():void
		{
			trackActionEvent('upload');
		}

		public static function trackActionGamepadEvent():void
		{
			trackActionEvent('gamepad');
		}
		
		public static function trackActionFavoriteEvent():void
		{
			trackActionEvent('favorite');
		}
	
		private static function trackShareEvent(label:String):void
		{
			trackEvent('share', label);
		}
		
		public static function trackShareFacebookEvent():void
		{
			trackShareEvent('facebook');
		}
		
		public static function trackShareGoogleEvent():void
		{
			trackShareEvent('google');
		}
		
		public static function trackShareTwitterEvent():void
		{
			trackShareEvent('twitter');
		}
		
		public static function trackShareVkontakteEvent():void
		{
			trackShareEvent('vkontakte');
		}
	}
}