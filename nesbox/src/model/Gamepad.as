package model
{
	public class Gamepad
	{
		public var codes:Array;
		
		private var size:int;
		
		public function Gamepad(size:int)
		{
			this.size = size;
			codes = new Array(size);
		}
		
		public function get empty():Boolean
		{
			for(var index:int = 0; index < size; index++)
				if(!codes[index])
					return true;
			
			return false;
		}
	}
}