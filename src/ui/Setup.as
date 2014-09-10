package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	import model.Gamepad;
	
	internal class Setup extends Sprite implements IBaseSetup
	{
		private var joystickSprite:Sprite;
		private var title:Text;
		private var info:Text;
		private var leftKeys:Sprite;
		private var middleKeys:Sprite;
		private var rightKeys:Sprite;
		private var buttons:Text;
		private var defaults:Text;
		private var joystickData:Gamepad;
		private var assigning:String;
		private var gamepadModule:IGamepadModule;
		private var keyNames:Array;
		private var locale:Locale;
		
		private var handler:ISetupHandler;
		
		public function Setup(handler:ISetupHandler, gamepadModule:IGamepadModule)
		{
			super();
			
			locale = Locale.instance;
			
			this.handler = handler;
			this.gamepadModule = gamepadModule;
			
			keyNames = gamepadModule.getGamepadKeysNames();
			
			visible = false;
			
			initJoystick();
			
			title = new Text;
			title.htmlText = '<p>' + locale.keyboard_setup.toUpperCase() + '</p>';
			addChild(title);
			
			info = new Text;
			info.htmlText = '<p>' + locale.select_joystick_button + '...</p>';
			addChild(info);
			
			leftKeys = new Sprite;
			addChild(leftKeys);
			
			middleKeys = new Sprite;
			addChild(middleKeys);
			
			rightKeys = new Sprite;
			addChild(rightKeys);
			
			defaults = new Text;
			defaults.htmlText = '<p><a href="event:defaults">' + locale.load_defaults + '</a></p>';
			addChild(defaults);
			defaults.addEventListener(TextEvent.LINK, onLink);
			
			buttons = new Text;
			buttons.htmlText = '<p><a href="event:save">' + 
				locale.save.toUpperCase() + 
				'</a> ' + locale.or + ' <a href="event:cancel">' + 
				locale.cancel.toUpperCase() + '</a></p>';
			addChild(buttons);
			buttons.addEventListener(TextEvent.LINK, onLink);
		}
		
		public function get sprite():DisplayObject
		{
			return this;
		}
		
		public function show(joystick:Gamepad):void
		{
			visible = true;
			buttons.htmlText = '<p><a href="event:save">' + 
				locale.save.toUpperCase() + 
				'</a> ' + locale.or + ' <a href="event:cancel">' + 
				locale.cancel.toUpperCase() + '</a></p>';
			
			joystickData = new Gamepad(0);
			joystickData.codes = joystick.codes.slice();
			
			update();
		}
		
		private function initJoystick():void
		{
			joystickSprite = new Sprite;
			joystickSprite.addChild(gamepadModule.getGamepadImage());
			addChild(joystickSprite);
			
			var keyNames:Array = gamepadModule.getGamepadKeysNames();
			
			for each(var name:String in keyNames)
			{
				var gamepadButton:GamepadButton = gamepadModule.getGamepadButton(name);
				var button:Sprite = new Sprite;
				
				button.addChild(gamepadButton.bitmap);
				joystickSprite.addChild(button);
				
				button.x = gamepadButton.x;
				button.y = gamepadButton.y;
				button.buttonMode = true;
				button.name = gamepadButton.name;
				
				button.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void
				{
					Sprite(event.target).alpha = .6;
				});
				
				button.addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void
				{
					Sprite(event.target).alpha = 1;
				});
				
				button.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
				{
					assignKey(Sprite(event.target).name);
				});
			}
		}
		
		private function assignKey(name:String):void
		{
			assigning = name;
			
			joystickData.codes[keyNames.indexOf(assigning)] = 0;
			
			updateKeys();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			var key:uint = event.keyCode;
			
			joystickData.codes[keyNames.indexOf(assigning)] = key;
			
			assigning = '';
			
			updateKeys();
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function update():void
		{
			graphics.clear();
			graphics.beginFill(0x666666);
			graphics.drawRect(0, 0, Variables.Width, Variables.Height);
			graphics.endFill();
			
			title.x = (Variables.Width - title.width) / 2;
			title.y = 4;
			
			info.x = (Variables.Width - info.width) / 2;
			info.y = title.y + title.height;
			
			joystickSprite.x = (Variables.Width - joystickSprite.width) / 2;
			joystickSprite.y = info.y + info.height;
			
			defaults.x = (Variables.Width - defaults.width) / 2;
			defaults.y = joystickSprite.y + joystickSprite.height;
			
			updateKeys();
			
			leftKeys.x = 10;
			middleKeys.x = int(Variables.Width / 3) + leftKeys.x;
			rightKeys.x = int(Variables.Width / 3) + middleKeys.x;
			
			leftKeys.y = middleKeys.y = rightKeys.y = defaults.y + defaults.height;
			
			buttons.x = (Variables.Width - buttons.width) / 2;
			buttons.y = leftKeys.y + leftKeys.height - 4;
			
		}
		
		private function getKeyText(value:int):String
		{
			if(joystickData && joystickData.codes)
			{
				var text:String = Keyboard.Keys[joystickData.codes[value]];
				
				if(text && text.length)
				{
					return text.toUpperCase();
				}
				
			}
			
			return '...';
		}
		
		private function updateKeys():void
		{
			var fill:Function = function(parent:Sprite, data:Array):void
			{
				var vertPos:int = 0;
				
				for each(var item:String in data)
				{
					var text:Text = new Text(assigning == item ? '#ffffff' : '#cccccc');
					
					text.styleSheet.setStyle('.' + item, 
						{
							color: assigning == item ? '#ffffff' : '#cccccc'
						});
					
					text.htmlText += '<p class="' 
						+ item + '">' + item + ' - ' 
						+ getKeyText(keyNames.indexOf(item)) + '</p>';
					
					text.y = vertPos;
					vertPos += 12;
					
					parent.addChild(text);
				}
			};
			
			leftKeys.removeChildren();
			middleKeys.removeChildren();
			rightKeys.removeChildren();
			
			if(keyNames.length >= 4)
			{
				fill(leftKeys, keyNames.slice(0, 4));
			}
			
			if(keyNames.length >= 8)
			{
				fill(middleKeys, keyNames.slice(4, 8));
			}
			
			if(keyNames.length >= 12)
			{
				fill(rightKeys, keyNames.slice(8, 12));
			}
			
			buttons.visible = !joystickData.empty;
		}
		
		private function onLink(event:TextEvent):void
		{
			switch(event.text)
			{
				case 'save':
					save();
					break;
				case 'cancel':
					cancel();
					break;
				//				case 'done':
				//					done();
				//					break;
				case 'defaults':
					loadDefaults();
					break;
			}
		}
		
		private function save():void
		{
			handler.onSetupSave(joystickData);
		}
		
		private function cancel():void
		{
			handler.onSetupCancel();
		}
		
		//		private function done():void
		//		{
		//			handler.onSetupDone(joystickData);
		//		}
		
		private function loadDefaults():void
		{
			joystickData.codes = gamepadModule.getGamepadDefaultKeys();
			
			updateKeys();
		}
	}
}
