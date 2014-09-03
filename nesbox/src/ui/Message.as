package ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class Message extends Sprite
	{
		protected var scale:int = 1;
		
		public function Message()
		{
			visible = false;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void
		{
			x = y = 0;
			alpha = .95;
			
			graphics.beginFill(0x666666);
			graphics.drawRect(0, 0, Variables.Width, Variables.Height);
			graphics.endFill();
		}
		
		public function show(value:String, handler:Object = null):void
		{
			visible = value.length > 0;
			
			this.removeChildren();
			
			const LINE_HEIGHT:int = 10;
			var parts:Array = value.split('<br>');
			var vertPos:int = (height/scale - parts.length * LINE_HEIGHT) / 2;
			
			var onInfoLink:Function = function(event:TextEvent):void
			{
				if(handler && handler.hasOwnProperty(event.text))
				{
					if(handler[event.text] is Function)
					{
						handler[event.text]();
					}
				}
			}
			
			for each(var part:String in parts)
			{
				part = part.split('<p>').join('');
				part = part.split('</p>').join('');
				
				var field:Text = new Text;
				field.multiline = true;
				field.autoSize = TextFieldAutoSize.NONE;
				field.wordWrap = true;

				var style:Object = field.styleSheet.getStyle('p');
				style.textAlign = 'center';
				field.styleSheet.setStyle('p', style);

				field.addEventListener(TextEvent.LINK, onInfoLink);
				field.htmlText = ['<p>', part, '</p>'].join('');
				
				field.width = int((width-32)/scale);
				field.x = 16/scale;
				field.y = int(vertPos);
				
				vertPos += LINE_HEIGHT;
				
				addChild(field);
			}
		}
		
		public function hide():void
		{
			show('');
		}
	}
}