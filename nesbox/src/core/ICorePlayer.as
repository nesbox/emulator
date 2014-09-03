package core
{
	import flash.utils.ByteArray;

	public interface ICorePlayer
	{
		function set muted(value:Boolean):void;
		function get muted():Boolean;
		function load(state:ByteArray):void;
		function save():ByteArray;
		function initEmulation(isNtsc:Boolean, rom:ByteArray, region:String):void;
	}
}