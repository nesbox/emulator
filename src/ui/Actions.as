package ui
{
	import flash.display.Sprite;
	
	public class Actions extends Sprite
	{
		private static const UpColor:uint 	= 0x000000;
		private static const OverColor:uint = 0xffffff;
		private static const ToggleColor:uint = 0x9b9b9b;
		private static const OffColor:uint 	= 0x777777;
		private static const BackColor:uint = 0x666666;
		
		private var handler:IActionsHandler;
		
		private const singleModeButtonsMap:Array = 
			[
				{name:'setup', 		icon:ActionAsset.SetupButton, click:setup},
				{name:'mute', 		icon:ActionAsset.MuteButton, click:mute},
				{name:'save', 		icon:ActionAsset.SaveButton, click:save},
				{name:'load', 		icon:ActionAsset.LoadButton, click:load},
				{name:'gamepad',	icon:ActionAsset.GamepadButton, click:gamepad},
				{name:'fullscreen',	icon:ActionAsset.FullscreenButton, click:fullscreenInteractive}
			];
		
		private const ownModeButtonsMap:Array = 
			[
				{name:'setup', 		icon:ActionAsset.SetupButton, click:setup},
				{name:'mute', 		icon:ActionAsset.MuteButton, click:mute},
				{name:'save', 		icon:ActionAsset.SaveButton, click:save},
				{name:'load', 		icon:ActionAsset.LoadButton, click:load},
				{name:'gamepad',	icon:ActionAsset.GamepadButton, click:gamepad},
				{name:'fullscreen',	icon:ActionAsset.FullscreenButton, click:fullscreenInteractive},
			];

		private const networkModeButtonsMap:Array = 
			[
				{name:'setup', 		icon:ActionAsset.SetupButton, click:setup},
				{name:'mute', 		icon:ActionAsset.MuteButton, click:mute},
				{name:'gamepad',	icon:ActionAsset.GamepadButton, click:gamepad},
				{name:'fullscreen',	icon:ActionAsset.FullscreenButton, click:fullscreenInteractive},
			];
		
		private const walkModeButtonsMap:Array = 
			[
				{name:'mute', 		icon:ActionAsset.MuteButton, click:mute},
				{name:'fullscreen',	icon:ActionAsset.FullscreenButton, click:fullscreen},
			];
		
		private const contestModeButtonsMap:Array = 
			[
				{name:'setup', 		icon:ActionAsset.SetupButton, click:setup},
				{name:'mute', 		icon:ActionAsset.MuteButton, click:mute},
				{name:'upload',		icon:ActionAsset.UploadButton, click:upload},
				{name:'gamepad',	icon:ActionAsset.GamepadButton, click:gamepad},
				{name:'fullscreen',	icon:ActionAsset.FullscreenButton, click:fullscreenInteractive},
			];

		private const socialSingleModeButtonsMap:Array = 
			[
				{name:'setup', 		icon:ActionAsset.SetupButton, click:setup},
				{name:'mute', 		icon:ActionAsset.MuteButton, click:mute},
				{name:'save', 		icon:ActionAsset.SaveButton, click:save},
				{name:'load', 		icon:ActionAsset.LoadButton, click:load},
				{name:'fullscreen',	icon:ActionAsset.FullscreenButton, click:fullscreenInteractive},
			];
		
		private const socialNetworkModeButtonsMap:Array = 
			[
				{name:'setup', 		icon:ActionAsset.SetupButton, click:setup},
				{name:'mute', 		icon:ActionAsset.MuteButton, click:mute},
				{name:'fullscreen',	icon:ActionAsset.FullscreenButton, click:fullscreenInteractive},
			];

		private const socialButtonsMap:Array = 
			[
				{name:'github', 	icon:ActionAsset.GithubButton, click:github},
			];
		
		private var buttons:Array = [];
		private var loadActiveValue:Boolean = false;
		private var saveActiveValue:Boolean = false;
		private var favoriteValue:Boolean = false;
		private var favoriteActiveValue:Boolean = false;
		private var infoText:Text;
		
		public static const Height:uint = 16;
		
		public function Actions(handler:IActionsHandler, mode:ActionsMode)
		{
			this.handler = handler;
			
			graphics.beginFill(BackColor);
			graphics.drawRect(0, 0, Variables.Width, Height);
			graphics.endFill();
			
			switch(mode)
			{
			case ActionsMode.Single:
				fillButtons(singleModeButtonsMap);
				break;
			case ActionsMode.Network:
				fillButtons(networkModeButtonsMap);
				break;
			case ActionsMode.Walk:
				fillButtons(walkModeButtonsMap);
				break;
			case ActionsMode.Contest:
				fillButtons(contestModeButtonsMap);
				break;
			case ActionsMode.SocialSingle:
				fillButtons(socialSingleModeButtonsMap);
				return;
			case ActionsMode.SocialNetwork:
				fillButtons(socialNetworkModeButtonsMap);
				return;
			case ActionsMode.Custom:
				fillButtons(ownModeButtonsMap);
				break;
			}
			
			fillSocialButtons();
		}
		
		public function set info(value:String):void
		{
			if(!infoText)
			{
				infoText = new Text;
				addChild(infoText);
			}
			
			infoText.htmlText = value;
			infoText.x = (Variables.Width - infoText.width)/2;
			infoText.y = - 1;
		}
		
		private function fillSocialButtons():void
		{
			var offset:int = Variables.Width - socialButtonsMap.length*Height;
			for each(var item:Object in socialButtonsMap)
			{
				var button:Button = new Button(item.name, item.icon, item.click, 'share');
				addChild(button).x = offset;
				offset += Height;
				
				buttons.push(button);
			}
		}

		private function fillButtons(map:Array):void
		{
			var offset:int = 0;
			for each(var item:Object in map)
			{
				var button:Button = new Button(item.name, item.icon, item.click, item.name);
				addChild(button).x = offset;
				offset += Height;
				
				buttons.push(button);
			}
		}
		
		private function mute():void
		{
			Analytics.trackActionMuteEvent();
			handler.onActionsMute();
		}
		
		private function fullscreen():void
		{
			Analytics.trackActionFullscreenEvent();
			handler.onActionsFullscreen();
		}

		private function fullscreenInteractive():void
		{
			Analytics.trackActionFullscreenEvent();
			handler.onActionsFullscreenInteractive();
		}

		public function set muted(value:Boolean):void
		{
			getButton('mute').upColor = value ? ToggleColor : UpColor;
		}
		
		private function load():void
		{
			Analytics.trackActionLoadEvent();
			handler.onActionsLoad();
		}
		
		private function save():void
		{
			Analytics.trackActionSaveEvent();
			handler.onActionsSave();
		}
		
		private function enableButton(name:String, value:Boolean):void
		{
			var button:Button = getButton(name);
			
			if(button)
			{
				button.enabled = value;
				button.upColor = value ? UpColor : OffColor;
			}
		}
		
		public function set enableFullscreen(value:Boolean):void
		{
			enableButton('fullscreen', value);
		}
		
//		public function set enableGamepad(value:Boolean):void
//		{
//			enableButton('gamepad', value);
//		}
		
		public function set loadActive(value:Boolean):void
		{
			enableButton('load', value);
			loadActiveValue = value;
		}
		
		public function get loadActive():Boolean
		{
			return loadActiveValue;
		}
		
		public function set saveActive(value:Boolean):void
		{
			enableButton('save', value);
			saveActiveValue = value;
		}
		
		public function get saveActive():Boolean
		{
			return saveActiveValue;
		}
		
		private function setup():void
		{
			Analytics.trackActionSetupEvent();
			handler.onActionsSetup();
		}
		
		private function getButton(name:String):Button
		{
			for each(var button:Button in buttons)
			{
				if(button.name == name)
				{
					return button;
				}
			}
			
			return null;
		}
		
		private function upload():void
		{
			Analytics.trackActionUploadEvent();
			handler.onActionsUpload();
		}
		
		private function facebook():void
		{
			Analytics.trackShareFacebookEvent();
			handler.onActionsShareFacebook();
		}
		
		private function google():void
		{
			Analytics.trackShareGoogleEvent();
			handler.onActionsShareGoogle();
		}
		
		private function twitter():void
		{
			Analytics.trackShareTwitterEvent();
			handler.onActionsShareTwitter();
		}
		
		private function vkontakte():void
		{
			Analytics.trackShareVkontakteEvent();
			handler.onActionsShareVkontakte();
		}
		
		private function github():void
		{
			handler.onActionsShareGithub();
		}
		
		private function gamepad():void
		{
			Analytics.trackActionGamepadEvent();
			handler.onActionsGamepad();
		}
		
		private function favorite():void
		{
			Analytics.trackActionFavoriteEvent();
			handler.onActionsFavorite();
		}

//		public function get favorited():Boolean
//		{
//			return favoriteValue;
//		}
//
//		public function set favorited(value:Boolean):void
//		{
//			getButton('favorite').upColor = value ? ToggleColor : UpColor;
//			favoriteValue = value;
//		}
		
		public function set favoriteActive(value:Boolean):void
		{
			enableButton('favorite', value);
			favoriteActiveValue = value;
		}
		
		public function get favoriteActive():Boolean
		{
			return favoriteActiveValue;
		}
	}
}
