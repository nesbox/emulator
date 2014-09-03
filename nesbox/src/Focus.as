package
{
	import flash.display.Stage;
	import flash.events.Event;

	public class Focus
	{
		public static var activated:Boolean = false;
		
		public static function init(stage:Stage):void
		{
			stage.addEventListener(Event.ACTIVATE, function():void
			{
				activated = true;
			});
			
			stage.addEventListener(Event.DEACTIVATE, function():void
			{
				activated = false;
			});
		}
	}
}