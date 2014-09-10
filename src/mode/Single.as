package mode
{
	import com.adobe.images.PNGEncoder;
	
	import core.CorePlayerSingle;
	
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import model.Gamepad;
	
	import ui.Actions;
	import ui.ActionsMode;
	import ui.IBaseSetup;
	import ui.ISetupHandler;
	import ui.Message;
	import ui.Setup;
	import ui.SetupBuilder;

	public class Single extends Base 
		implements 
			ISetupHandler
	{
		private var nes:CorePlayerSingle;
		private var setup:IBaseSetup;
		private var message:Message;
		private var actions:Actions;
		private var state:EmulatorState;
		
		private var lastState:ByteArray;
		
		public function Single(gameData:GameData)
		{
			super(gameData);
			
			nes 			= new CorePlayerSingle(gameData.core, this);
			actions 		= new Actions(this, ActionsMode.Single);
			setup 			= SetupBuilder.Make(this, gameData);
			message 		= new Message();
			
			actions.muted = nes.muted = settings.muted;
			actions.visible = false;
			actions.loadActive = false;
			actions.enableFullscreen = Tools.isInteractiveFullscreenSupported();
			actions.favoriteActive = false;
		}
		
		protected override function init():void
		{
			addChild(nes);
			addChild(actions);
			addChild(setup.sprite);
			addChild(message);
			
			state = EmulatorState.Playing;
			
			super.init();
		}
		
		protected override function startActionsShow():void 
		{
			super.showActions(actions);
		}
		
		protected override function stopActionsShow():void 
		{
			super.hideActions(actions);
		}
		
		protected override function resume():void
		{
			super.resume();
			
			if(!setup.sprite.visible
				&& !message.visible)
			{
				nes.play();
			}
		}
		
		protected override function pause():void
		{
			if(!setup.sprite.visible
				&& !message.visible)
			{
				super.pause();
				nes.pause();
			}
		}
		
		protected override function pauseEmulation():void
		{
			nes.pause();
		}
		
		protected override function resumeEmulation():void
		{
			nes.play();
		}
		
//		protected override function updateGamepadCodes(codes:Array):void
//		{
//			nes.updateGamepadCodes(codes);
//		}
		
		protected override function enableFullscreen(enable:Boolean):void 
		{
			actions.enableFullscreen = enable;
		}
		
//		protected override function enableGamepad(enable:Boolean):void
//		{
//			actions.enableGamepad = enable;
//		}
		
		private function loadState(saveId:String = null):void
		{
			nes.pause();
			
			message.show('<p>' + locale.loading_game + '...</p>');
			
			if(lastState 
				&& lastState.length)
			{
				onApiLoaded(lastState);
			}
			else
			{
				api.loadState(gameData.rom, saveId);
			}
		}
		
		private function saveState():void
		{
			nes.pause();
			
			message.show('<p>'+locale.please_wait+'...</p>');
			
			var data:ByteArray = nes.save();
				
			if(data && data.bytesAvailable)
			{
				nes.pause();
				message.show('<p>' + locale.saving_game + '...</p>');
				
				api.save(gameData.rom, data, nes.screen);
			}
		}
		
		private function initSaveLoadShortcuts():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent):void
			{
				switch(event.keyCode)
				{
					case SaveHotkeyCode:
						onActionsLoad();
						break;
					case LoadHotkeyCode:
						onActionsSave();
//					case 114:
//						onScreenShot();
//						break;
				}
			});
		}
		
		private function onSignIn():void
		{
			message.hide();
			nes.pause();
			JSProxy.showSignInModal();
		}
		
		private function onSignUp():void
		{
			message.hide();
			nes.pause();
			JSProxy.showSignUpModal();
		}
		
		public function onSetupSave(joystick:Gamepad):void
		{
			settings.keyboard = joystick;
			nes.updateKeyCodes(joystick.codes);
			nes.play();
			setup.sprite.visible = false;
		}
		
		public function onSetupCancel():void
		{
			nes.play();
			setup.sprite.visible = false;
		}
		
		protected override function start():void
		{
			nes.updateKeyCodes(settings.keyboard.codes);
			
			initSaveLoadShortcuts();
			nes.initSingleEmulation(gameData.ntsc, gameData.data, gameData.region);
			
			if(gameData.value && gameData.value.length)
			{
				if(!Focus.activated)
				{
					pause();
				}
				
				state = EmulatorState.Loading;
				message.show('<p>' + locale.loading_game + '</p>');
				
				api.loadState(gameData.rom, gameData.value);
			}
			else
			{
				api.check(gameData.rom);
			}
			
			api.isFavorited(gameData.rom);
		}
		
		public override function onActionsFavorite():void
		{
//			api.favorite(gameData.rom, !actions.favorited);
		}
		
		public override function onActionsMute():void
		{
			nes.muted = !nes.muted;
			settings.muted = nes.muted;
			actions.muted = nes.muted;
		}
		
		public override function onActionsLoad():void
		{
			if(actions.loadActive)
			{
				var handlers:Object = 
					{
						yes:function():void
						{
							message.hide();
							state = EmulatorState.Loading;
							loadState();
						},
						no:function():void
						{
							message.hide();
							nes.play();
						}
					};
				
				nes.pause();
				message.show('<p>'+locale.do_you_want_to_load_state+'<br><br>'+
					'<a href="event:yes">' + 
					locale.yes.toUpperCase() + '</a> ' + 
					locale.or + ' <a href="event:no">' + 
					locale.no.toUpperCase() + '</a></p>', handlers);
				
			}
		}
		
		public override function onActionsSave():void
		{
			state = EmulatorState.Saving;
			saveState();
		}
		
		public override function onActionsSetup():void
		{
			nes.pause();
			setup.show(settings.keyboard);
		}
		
		public function onSigninCancel():void
		{
			message.hide();
			nes.play();
		}
		
		public override function onApiError(info:String):void
		{
			var callbacks:Object = 
				{
					cancelsign:onSigninCancel
				};
			
			message.show('<p>' + locale.error_occured + 
				'<br><br><a href="event:cancelsign">' + locale.close.toUpperCase() + 
				'</a></p>', callbacks);
		}
		
		public override function onApiSaved(state:ByteArray):void
		{
			lastState = state;
			actions.loadActive = true;
			this.state = EmulatorState.Playing;
			message.hide();
			nes.play();
		}
		
		public override function onApiLoaded(state:ByteArray):void
		{
			this.state = EmulatorState.Playing;
			
			lastState = state;
			
			if(state && state.length)
			{
				nes.load(state);
				actions.loadActive = true;
			}
			else
			{
				actions.loadActive = false;
			}
			
			message.hide();
			
			if(Focus.activated)
			{
				nes.play();
			}
		}
		
		public override function onApiNeedSign():void
		{
			var callbacks:Object = 
				{
					signin:onSignIn,
					signup:onSignUp,
					cancelsign:onSigninCancel
				};
			
			message.show('<p>' + 
				locale.you_need_to_be_signed_in_to_save + '<br><br>' +
				'<a href="event:signin">' + locale.sign_in.toUpperCase()+'</a> ' + 
				locale.or + ' <a href="event:signup">' + 
				locale.sign_up.toUpperCase() + '</a><br><br>' +
				'<a href="event:cancelsign">'+locale.cancel.toUpperCase()+'</a></p>', callbacks);
		}
		
		public override function onApiUserSigned(signed:Boolean):void
		{
			if(signed)
			{
				switch(state)
				{
					case EmulatorState.Loading:
						loadState();
						break;
					case EmulatorState.Saving:
						saveState();
						break;
				}
				
				nes.play();
			}
			else
			{
				
			}
		}
		
		public override function onApiState(userLogined:Boolean, state:ByteArray):void
		{
			if(state && state.length)
			{
				actions.loadActive = true;
				lastState = state;
				
				var callbacks:Object = 
					{
						yes:function():void
						{
							nes.load(lastState);
							nes.play();
							message.hide();
						},
						
						no:function():void
						{
							message.hide();
							nes.play();
						}
					};
				
				message.show('<p>'+locale.do_you_want_to_load_state + '<br><br>' +
					'<a href="event:yes">' + 
					locale.yes.toUpperCase() + '</a> ' + 
					locale.or + ' <a href="event:no">' + 
					locale.no.toUpperCase() + '</a></p>', callbacks);
			}
			else
			{
				actions.loadActive = false;
				
				Focus.activated ? nes.play() : pause();
			}
		}
		
		protected override function onScreenShot():void
		{
			api.screen(gameData.rom, nes.screen);
		}

		public override function onApiFavorited(value:Boolean):void
		{
//			actions.favoriteActive = true;
//			actions.favorited = value;
		}
	}
}
