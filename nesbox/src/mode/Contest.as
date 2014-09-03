package mode
{
	import core.CorePlayerContest;
	
	import flash.events.KeyboardEvent;
	
	import model.Gamepad;
	
	import ui.Actions;
	import ui.ActionsMode;
	import ui.IBaseSetup;
	import ui.ISetupHandler;
	import ui.Message;
	import ui.Setup;
	import ui.SetupBuilder;

	public class Contest extends Base 
		implements 
			ISetupHandler
	{
		private var nes:CorePlayerContest;
		private var setup:IBaseSetup;
		private var message:Message;
		private var actions:Actions;
		private var state:EmulatorState;
		
		public function Contest(gameData:GameData)
		{
			super(gameData);
			
			nes 		= new CorePlayerContest(gameData.core, this);
			actions 	= new Actions(this, ActionsMode.Contest);
			setup 		= SetupBuilder.Make(this, gameData);
			message 	= new Message();
			
			actions.muted = nes.muted = settings.muted;
			actions.visible = false;
			actions.enableFullscreen = Tools.isInteractiveFullscreenSupported();
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
			
			if(!setup.visible
				&& !message.visible)
			{
				nes.play();
			}
		}
		
		protected override function pause():void
		{
			if(!setup.visible
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
		
		private function uploadWalk():void
		{
			nes.pause();
			message.show('<p>'+locale.uploading_walkthrough+'...</p>');
			
			api.uploadWalk(gameData.rom, nes.getWalk());
		}
		
		private function initUploadShortcut():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent):void
			{
				switch(event.keyCode)
				{
					case UploadHotkeyCode:
						onActionsUpload();
						break;
				}
			});
		}
		
		private function onSignIn():void
		{
			nes.pause();
			JSProxy.showSignInModal();
		}
		
		private function onSignUp():void
		{
			nes.pause();
			JSProxy.showSignUpModal();
		}
		
		public function onSetupSave(joystick:Gamepad):void
		{
			settings.keyboard = joystick;
			nes.updateKeyCodes(joystick.codes);
			nes.play();
			setup.visible = false;
		}
		
		public function onSetupCancel():void
		{
			nes.play();
			setup.visible = false;
		}
		
		protected override function start():void
		{
			nes.updateKeyCodes(settings.keyboard.codes);
			
			initUploadShortcut();
			nes.initContestEmulation(gameData.ntsc, gameData.data, gameData.region);
			Focus.activated ? nes.play() : pause();
		}
		
		public override function onActionsMute():void
		{
			nes.muted = !nes.muted;
			settings.muted = nes.muted;
			actions.muted = nes.muted;
		}
		
		public override function onActionsSetup():void
		{
			nes.pause();
			setup.show(settings.keyboard);
		}
		
		public override function onActionsUpload():void
		{
			state = EmulatorState.Uploadig;
			uploadWalk();
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
		
		public override function onApiNeedSign():void
		{
			var callbacks:Object = 
				{
					signin:onSignIn,
					signup:onSignUp,
					cancelsign:onSigninCancel
				};
			
			message.show('<p>'+locale.you_need_to_be_signed_in_to_upload_walk+'<br><br>' +
				'<a href="event:signin">'+locale.sign_in.toUpperCase()+'</a> ' + 
				locale.or + 
				' <a href="event:signup">'+locale.sign_up.toUpperCase()+'</a><br><br>' +
				'<a href="event:cancelsign">'+locale.cancel.toUpperCase()+'</a></p>', callbacks);
		}
		
		public override function onApiUserSigned(signed:Boolean):void
		{
			if(signed)
			{
				switch(state)
				{
					case EmulatorState.Uploadig:
						uploadWalk();
						break;
				}
	
				nes.play();
			}
			else
			{
				
			}
		}
		
		public override function onApiUploaded():void
		{
			state = EmulatorState.Playing;
			message.hide();
			nes.play();
		}
		
		protected override function onScreenShot():void
		{
			api.screen(gameData.rom, nes.screen);
		}
	}
}
