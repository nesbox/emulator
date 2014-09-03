package network
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;

	public class OwnServerSession
	{
		private var socket:Socket;
		private var ip:String;
		private var port:int;
		private var room:String;
		private var frameskip:int;
		
		private var connected:Boolean;
		
		public var handler:IOwnServerSessionHandler;
		
		public function OwnServerSession(handler:IOwnServerSessionHandler)
		{
			this.handler = handler;
			
			connected = false;
			
			socket = new Socket();
			
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(Event.CLOSE, onDisconnect);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
		}
		
		public function connect(ip:String, port:int, room:String, frameskip:int = 0):void
		{
			this.ip = ip;
			this.port = port;
			this.frameskip = frameskip;
			this.room = room;
			
			socket.connect(ip, port);
		}
		
		private function onConnect(event:Event):void
		{
			sendMessage(
				{
					type:'handshake',
					room:room,
					frameskip:frameskip
				});
		}
		
		private function onData(event:ProgressEvent):void
		{
			if(connected)
			{
				var input:uint = socket.readUnsignedInt() & 0xffffff;
				handler.onOwnServerInput(input);
			}
			else
			{
				var data:String = socket.readUTFBytes(socket.bytesAvailable);
				var response:Object = JSON.parse(data);
				
				switch(response.type)
				{
					case 'handshake':
					{
						var room:String = response.room;
						
						frameskip = response.frameskip;
						
						if(room)
						{
							connected = true;
							handler.onOwnServerConnected(ip, port, room, frameskip);
						}
					
						break;
					}	
				}
			}
		}
		
		private function onDisconnect(event:Event):void
		{
			handler.onOwnServerDisconnected();
		}
		
		private function onError(event:ErrorEvent):void
		{
			handler.onOwnServerError();
		}
		
		private function sendMessage(data:Object):void
		{
			socket.writeUTFBytes(JSON.stringify(data));
			socket.flush();
		}
		
		public function sendInput(input:uint):void
		{
			if(connected)
			{
				socket.writeUnsignedInt(input);
				socket.flush();
			}
		}
	}
}
