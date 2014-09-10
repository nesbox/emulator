package ui
{
	import flash.events.Event;

	public class FullscreenMessage extends Message
	{
		public function FullscreenMessage()
		{
			super();
			scale = 2;
		}
		
		protected override function onAddedToStage(event:Event):void
		{
			x = y = 0;
			alpha = .95;
			
			graphics.beginFill(0x666666);
			graphics.drawRect(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
			graphics.endFill();
		}
	}
}