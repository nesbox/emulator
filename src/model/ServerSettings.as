package model
{
	public class ServerSettings
	{
		public var ip:String;
		public var port:int;
		public var frameskip:int;
		
		public function ServerSettings(ip:String, port:int, frameskip:int)
		{
			this.ip = ip;
			this.port = port;
			this.frameskip = frameskip;
		}
	}
}