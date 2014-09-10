package
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public interface ICoreModule extends IGamepadModule
	{
		function init(ntsc:Boolean, rom:ByteArray, region:String):void;
		function tick(input:uint, data:BitmapData):void;
		function sound(data:ByteArray):void;
		function save():ByteArray;
		function load(data:ByteArray):void;
		
		function set muted(value:Boolean):void;
		function get muted():Boolean;
		
		function getWidth():int;
		function getHeight():int;
	}
}