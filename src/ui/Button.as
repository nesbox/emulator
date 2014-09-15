package ui
{
	import flash.display.Bitmap;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	internal final class Button extends SimpleButton
	{
		private var index:int;
		private var upIcon:Bitmap;
		private var hintTimerId:uint;
		private var hintName:String;
		
		private static var hint:Text;
		
		public function Button(name:String, icon:Object, handler:Object, hintName:String, isAlpha:Boolean = false)
		{
			this.name = name;
			this.hintName = hintName;
	
			tabEnabled = false;
			
			var up:Sprite = new Sprite;
			var over:Sprite = new Sprite;
			
			upIcon = new icon;
			var overIcon:Bitmap = new icon;
			
			if(isAlpha)
			{
				overIcon.alpha = .8;
			}
			else
			{
				setStateColor(overIcon, 0xffffff);
			}
			
			up.addChild(upIcon);
			over.addChild(overIcon);
			
			super(up, over, up, up);
			
			addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
			{
				hideHint();
				
				if(handler != null && enabled)
				{
					handler();
				}
			});
			
			addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void
			{
				if(!hintTimerId)
				{
					hintTimerId = setTimeout(function():void
					{
						showHint();
						hintTimerId = 0;
					}, 300);
				}
			});
			
			addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void
			{
				hideHint();
			});
			
			addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void
			{
				if(!hint)
				{
					hint = new Text('#000000');
					hint.visible = false;
					hint.background = true;
					hint.backgroundColor = 0xffffff;
					
					parent.addChild(hint);
				}
			});
		}
		
		private function showHint():void
		{
			hint.visible = true;
			
			hint.htmlText = '<p>' + Locale.instance['hint_' + hintName] + '</p>';
			
			const HINT_GAP:int = 2;
			hint.x = int(x - (hint.width-16)/2);
			hint.y = -(hint.height + HINT_GAP);
			
			if(hint.x <= 0)
			{
				hint.x = HINT_GAP;
			}
			
			if(hint.x + hint.width > stage.stageWidth/2)
			{
				hint.x = stage.stageWidth/2 - hint.width - HINT_GAP;
			}
			
		}
		
		private function hideHint():void
		{
			hint.visible = false;
			hint.htmlText = '';
			
			if(hintTimerId)
			{
				clearTimeout(hintTimerId);
				hintTimerId = 0;
			}
		}
		
		private static function setStateColor(stateIcon:Bitmap, color:uint):void
		{
			var transform:ColorTransform = new ColorTransform;
			
			transform.color = color;
			stateIcon.bitmapData.colorTransform(new Rectangle(0, 0, stateIcon.width, stateIcon.height), transform);
		}
		
		public function set upColor(value:uint):void
		{
			setStateColor(upIcon, value);
		}
	}
}