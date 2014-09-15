package mode
{
	import core.CorePlayerSingle;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import model.Gamepad;
	
	import ui.Actions;
	import ui.ActionsMode;
	import ui.IBaseSetup;
	import ui.ISetupHandler;
	import ui.Message;
	import ui.Setup;
	import ui.SetupBuilder;

	public class Own extends Base 
		implements 
			ISetupHandler 
	{
		private var nes:CorePlayerSingle;
		private var setup:IBaseSetup;
		private var message:Message;
		private var actions:Actions;
		private var state:EmulatorState;
		
		private var lastState:ByteArray;
		
		public function Own(gameData:GameData)
		{
			super(gameData);
			
			nes 			= new CorePlayerSingle(gameData.core, this);
			actions 		= new Actions(this, ActionsMode.Custom);
			setup 			= SetupBuilder.Make(this, gameData);
			message 		= new Message();
			
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
		
		private function loadState():void
		{
			nes.pause();
			
			message.show('<p>' + locale.loading_game + '...</p>');
			
			var onComplete:Function = function():void
			{
				this.state = EmulatorState.Playing;
				nes.load(lastState);
				message.hide();
				nes.play();
			}
			
			if(lastState 
				&& lastState.length)
			{
				onComplete();
			}
			else
			{
				var ref:FileReference = new FileReference();
				ref.addEventListener(Event.CANCEL, function():void
				{
					this.state = EmulatorState.Playing;
					message.hide();
					nes.play();
				});
				ref.addEventListener(Event.COMPLETE, function():void
				{
					lastState = ref.data;
					onComplete();
				});
				ref.addEventListener(Event.SELECT, function():void
				{
					ref.load();
				});
				ref.browse([new FileFilter('Saved files', '*.save')]);
			}
		}
		
		private function saveState():void
		{
			var data:ByteArray = nes.save();
			
			if(data && data.bytesAvailable)
			{
				nes.pause();
				message.show('<p>' + locale.saving_game + '...</p>');
				
				var onComplete:Function = function():void
				{
					this.state = EmulatorState.Playing;
					message.hide();
					nes.play();
				}
					
				var ref:FileReference = new FileReference();
				ref.addEventListener(Event.CANCEL, function():void
				{
					onComplete();
				});
				ref.addEventListener(Event.COMPLETE, function():void
				{
					lastState = data;
					onComplete();
				});
				ref.save(data, gameData.rom + '.save');
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
						break;
				}
			});
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
			
			initSaveLoadShortcuts();
			nes.initSingleEmulation(gameData.ntsc, gameData.data, gameData.region);
			
			Focus.activated ? resume() : pause();
		}
		
		public override function onActionsMute():void
		{
			nes.muted = !nes.muted;
			settings.muted = nes.muted;
			actions.muted = nes.muted;
		}
		
		public override function onActionsLoad():void
		{
			loadState();
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
		
		protected override function onScreenShot():void
		{
			api.screen(gameData.rom, nes.screen);
		}

	}
}
