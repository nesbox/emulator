package mode
{
	import core.ICoreHandler;
	import flash.net.navigateToURL;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import model.Gamepad;
	import model.Settings;
	
	import server.Api;
	import server.IApiHandler;
	
	import ui.Actions;
	import ui.FullscreenMessage;
	import ui.IActionsHandler;
	import ui.Message;
	
	internal class Base extends Sprite implements IApiHandler, ICoreHandler, IActionsHandler
	{
		private var activeMessage:Message;
		private var gamepadMessage:Message;
		private var fullscreenMessage:FullscreenMessage;
		
		protected var api:Api;
		protected var settings:Settings;
		protected var gameData:GameData;
		protected var locale:Locale;
		
		protected static const UploadHotkeyCode:uint = 113; // F2
		protected static const SaveHotkeyCode:uint = 119; // F8
		protected static const LoadHotkeyCode:uint = 116; // F5
		protected static const FullscreenHotkeyCode:uint = 122; // F11
		
		public function Base(gameData:GameData)
		{
			super();
			
			locale = Locale.instance;
			
			this.gameData = gameData;
			
			settings = new Settings(gameData.core.getSettingsUid());
			api = new Api(this, gameData.domain);
			
			this.addEventListener(Event.ADDED_TO_STAGE, function():void
			{
				initActionsShowing();
//				enableGamepad(!Tools.isWindows);

				stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullscreenModeChanged);
				
				if(Tools.isInteractiveFullscreenSupported())
				{
					stage.addEventListener(FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED, fullscreenAccepted);
				}
				
//				setFullscreenRect();
				
				const Ntsc:String = 'ntsc';
				if(stage.loaderInfo.parameters.hasOwnProperty(Ntsc))
				{
					gameData.ntsc = stage.loaderInfo.parameters[Ntsc] == 'true';
				}
				
				const Region:String = 'region';
				if(stage.loaderInfo.parameters.hasOwnProperty(Region))
				{
					gameData.region = stage.loaderInfo.parameters[Region];
				}

				init();
			});
		}
		
		private function initActionsShowing():void
		{
			var timeoutId:uint = 0;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function():void
			{
				startActionsShow();
				
				if(timeoutId)
				{
					clearTimeout(timeoutId);
					timeoutId = 0;
				}
				
				timeoutId = setTimeout(function():void
				{
					if(timeoutId)
					{
						clearTimeout(timeoutId);
						timeoutId = 0;
					}
					
					stopActionsShow();
				}, 3000);
				
			});
			
			stage.addEventListener(Event.MOUSE_LEAVE, function():void
			{
				stopActionsShow();				
			});
		}
		
		protected function showActions(actions:DisplayObject):void
		{
			if(actions.visible) return;
			
			actions.visible = true;
			actions.alpha = 0.0;
			actions.y = Variables.Height;
			
			var id:uint = setInterval(function():void
			{
				if(!actions.visible) clearInterval(id);
				
				if(actions.y > Variables.Height - Actions.Height)
				{
					actions.y -= 1;
				}
				else
				{
					clearInterval(id);
				}
				
				if(actions.alpha < 1.0)
				{
					actions.alpha += 1.0/Number(Actions.Height);
				}
			}, 20);
		}
		
		protected function hideActions(actions:DisplayObject):void
		{
			actions.visible = false;
		}
		
		protected function startActionsShow():void {}
		
		protected function stopActionsShow():void {}
		
		protected function init():void 
		{
			JSProxy.initSigningCallback(onApiUserSigned);
			initActivateEngine();
			
			if(!settings.keyboard 
				|| settings.keyboard.empty)
			{
				var keysCount:int = gameData.core.getGamepadDefaultKeys().length;
			
				var joystick:Gamepad = new Gamepad(keysCount);
				joystick.codes = gameData.core.getGamepadDefaultKeys();
				settings.keyboard = joystick;
			}
			
			showDefaultKeyboard();
			start();
		}
		
		private function showDefaultKeyboard():void
		{
			var needShowing:Boolean = JSON.stringify(settings.keyboard.codes) 
				== JSON.stringify(gameData.core.getGamepadDefaultKeys());
			
			if(needShowing)
			{
				JSProxy.showDefaultKeyboard();
			}
		}
		
		protected function start():void {};
		
		protected function resume():void
		{
			activeMessage.hide();
		}
		
		protected function pause():void
		{
			activeMessage.show('<p><a href="event:click">' + 
				locale.click_here_to_play_the_game + //value('Click here to play the game') + 
				'...</a></p>');
		}
		
		protected function initActivateEngine():void
		{
			activeMessage = new Message;
			addChild(activeMessage);

			gamepadMessage = new Message;
			addChild(gamepadMessage);
			
			fullscreenMessage = new FullscreenMessage;
			addChild(fullscreenMessage);
			
			stage.addEventListener(Event.ACTIVATE, function():void
			{
				if(fullscreenMessage.visible)return;
				resume();
			});
			
			stage.addEventListener(Event.DEACTIVATE, function():void
			{
				if(fullscreenMessage.visible)return;
				pause();
			});
		}
		
		public function onApiError(info:String):void 
		{
			if(!activeMessage) return;
			
			var callbacks:Object = 
				{
					close:function():void
					{
						activeMessage.hide();
					}
				};
			
			activeMessage.show('<p>'+locale.error_occured
				+ '<br><br><a href="event:close">' 
				+ locale.close
				+ '</a></p>', callbacks);
		}
		public function onApiSaved(state:ByteArray):void {}
		public function onApiLoaded(state:ByteArray):void {}
		public function onApiNeedSign():void {}
		public function onApiUserSigned(signed:Boolean):void {}
		public function onApiState(userLogined:Boolean, state:ByteArray):void {}
		public function onApiUploaded():void {}
		public function onApiFavorited(value:Boolean):void {}
		
		protected function onScreenShot():void {} 
		
		public function onEmulate():void {}
		
		public function isNeedGamepad():Boolean
		{
			return gameData.action != 'walk';
		}
		
		public function onActionsShareFacebook():void 
		{
			JSProxy.windowOpen('http://www.facebook.com/sharer.php?u=' + Tools.currentUrl, 'Send to Facebook');
		}
		
		public function onActionsShareGoogle():void 
		{
			JSProxy.windowOpen('https://plus.google.com/share?url=' + Tools.currentUrl, 'Send to Google+');
		}
		
		public function onActionsShareTwitter():void 
		{
			JSProxy.windowOpen('http://twitter.com/share?url=' + Tools.currentUrl, 'Send to Twitter');
		}
		
		public function onActionsShareVkontakte():void 
		{
			JSProxy.windowOpen('http://vk.com/share.php?url=' + Tools.currentUrl, 'Send to VKontakte');
		}
		
		public function onActionsShareGithub():void
		{
			Tools.gotoNesboxPage();
		}

		protected function pauseEmulation():void {}
		protected function resumeEmulation():void {}
		protected function enableFullscreen(enable:Boolean):void {}
		
		public function onActionsFullscreen():void
		{
			if(stage.displayState == StageDisplayState.NORMAL)
			{
				setFullscreenRect();
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		public function onActionsFullscreenInteractive():void
		{
			if(stage.displayState == StageDisplayState.NORMAL)
			{
				pauseEmulation();
				
				var handlers:Object = 
					{
						cancel:function():void
						{
							stage.displayState = StageDisplayState.NORMAL;
						}
					};
				
				fullscreenMessage.show('<p>'
					+ locale.click_allow_button
					+ '<br><br><br>'
					+ '<a href="event:cancel">'+locale.cancel.toUpperCase()+'</a></p>', handlers);
				
				resetFullscreenRect();
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		private function fullscreenModeChanged(event:FullScreenEvent):void
		{
			if(!event.fullScreen)
			{
				resetFullscreenRect();
				fullscreenMessage.hide();
				resumeEmulation();
			}
		}
		
		private function fullscreenAccepted(event:FullScreenEvent):void
		{
			fullscreenMessage.hide();
			
			setFullscreenRect();
			
			resumeEmulation();
		}
		
		private function setFullscreenRect():void
		{
			parent.scaleX = parent.scaleY = 1;
			
			var fullWidth:int = stage.fullScreenWidth;
			var fullHeight:int = stage.fullScreenHeight;
			var rect:Rectangle = new Rectangle();
			
			if(Variables.Width/Variables.Height <= fullWidth/fullHeight)
			{
				rect.x = (Variables.Width - fullWidth * Variables.Height / fullHeight) / 2;
				rect.width = fullWidth * Variables.Height / fullHeight;
				rect.height = Variables.Height;
			}
			else
			{
				rect.y = (Variables.Height - fullHeight * Variables.Width/ fullWidth) / 2;
				rect.width = Variables.Width;
				rect.height = fullHeight * Variables.Width / fullWidth;
			}
			
			stage.fullScreenSourceRect = rect;
		}
		
		private function resetFullscreenRect():void
		{
			parent.scaleX = parent.scaleY = 2;
			stage.fullScreenSourceRect = null;
		}
		
		public function onActionsMute():void {}
		public function onActionsLoad():void {}
		public function onActionsSave():void {}
		public function onActionsSetup():void {}
		public function onActionsUpload():void {}
		public function onActionsFavorite():void {}
		
		public function onActionsGamepad():void 
		{
			var callbacks:Object = 
				{
					air:function():void
					{
						navigateToURL(new URLRequest('//get.adobe.com/air/'), '_blank');
					},

					companion:function():void
					{
						navigateToURL(new URLRequest('//github.com/nesbox/nesbox-companion/raw/master/air/companion.air'), '_blank');
					},

					close:function():void
					{
						gamepadMessage.hide();
					}
				};
			
			gamepadMessage.show('<p>'+locale.gamepad_app_info+'<br><br><br><br><br>' +
				'<a href="event:air">Download Adobe AIR</a><br><br>' +
				'<a href="event:companion">Download Nesbox Companion</a><br><br><br>' +
				'<a href="event:close">'+locale.close.toLocaleUpperCase()+'</a></p>', callbacks);
		}

	}
}