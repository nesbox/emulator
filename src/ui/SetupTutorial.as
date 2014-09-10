package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import model.Gamepad;
	
	
	public class SetupTutorial extends Sprite implements IBaseSetup
	{
		private var locale:Locale;
		private var gamepadModule:IGamepadModule;
		private var joystickData:Gamepad;
		private var keyNames:Array;
		
		private var title:Text;
		private var keysText:Text;
		private var message:Message;
		private var assigning:String;
		private var defaults:Text;
		private var buttons:Text;
		
		private var handler:ISetupHandler;
		
		public function SetupTutorial(handler:ISetupHandler, gamepadModule:IGamepadModule)
		{
			super();
			
			locale = Locale.instance;
			
			this.handler = handler;
			this.gamepadModule = gamepadModule;
			
			keyNames = gamepadModule.getGamepadKeysNames();
			
			visible = false;
			
			{
				title = new Text;
				title.htmlText = '<p>' + locale.keyboard_setup.toUpperCase() + '</p>';
				addChild(title);
			}

			{
				keysText = new Text();
				keysText.multiline = true;
				
				var style:StyleSheet = keysText.styleSheet;
				
				style.setStyle('a', {textDecoration : 'none'});
				style.setStyle('a:hover', {textDecoration : 'underline'});
				
				keysText.styleSheet = style;
				addChild(keysText);
				
				keysText.addEventListener(TextEvent.LINK, assignButton);
			}
			
			{
				defaults = new Text;
				defaults.htmlText = '<p><a href="event:defaults">' + 
					locale.load_defaults + '</a></p>';
				addChild(defaults);
				defaults.addEventListener(TextEvent.LINK, onLink);
			}
			
			{
				buttons = new Text;
				buttons.htmlText = '<p><a href="event:save">' + 
					locale.save.toUpperCase() + 
					'</a> ' + locale.or + ' <a href="event:cancel">' + 
					locale.cancel.toUpperCase() + '</a></p>';
				addChild(buttons);
				buttons.addEventListener(TextEvent.LINK, onLink);
			}
			
			message = new Message();
			addChild(message);
			
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
		
		private function loadDefaults():void
		{
			joystickData.codes = gamepadModule.getGamepadDefaultKeys();
			
			updateKeys();
		}

		private function onKey(event:KeyboardEvent):void
		{
			var key:uint = event.keyCode;
			
			joystickData.codes[keyNames.indexOf(assigning)] = key;
			assigning = '';
			updateKeys();
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			message.hide();
		}
		
		private function assignButton(event:TextEvent):void
		{
			assigning = event.text;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			
			var callbacks:Object = 
				{
					cancel:function():void
					{
						stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
						message.hide();	
					}
				};
			
			message.show('<p>Please, press button on your keyboard to assign...<br><br><br>' +
				'<a href="event:cancel">CANCEL</a></p>', callbacks);
		}
		
		public function get sprite():DisplayObject
		{
			return this;
		}
		
		public function show(joystick:Gamepad):void
		{
			visible = true;
			
			joystickData = new Gamepad(0);
			joystickData.codes = joystick.codes.slice();
			
			update();
		}
		
		private function update():void
		{
			graphics.clear();
			graphics.beginFill(0x666666);
			graphics.drawRect(0, 0, Variables.Width, Variables.Height);
			graphics.endFill();
			
			title.x = (Variables.Width - title.width) / 2;
			title.y = 4;
			
			updateKeys();
			
			defaults.x = (Variables.Width - defaults.width) / 2;
			defaults.y = 110;
			
			buttons.x = (Variables.Width - buttons.width) / 2;
			buttons.y = defaults.y + defaults.height;
		}
		
		private function updateKeys():void
		{
			var htmlText:String = '';
			
			for each(var item:String in keyNames)
			{
				htmlText += '<a href="event:'+item+'">' + item + ' - ' 
					+ getKeyText(keyNames.indexOf(item)) + '</a><br>';
			}
			
			keysText.x = 10;
			keysText.y = 16;
			
			keysText.htmlText = '<p>' + htmlText + '</p>';
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
	}
}
