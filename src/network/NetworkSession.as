package network
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.getTimer;

	public class NetworkSession
	{
		private static const ServerAddress:String 	= 'rtmfp://p2p.rtmfp.net';
		private static const DeveloperKey:String 	= '48faff0c77b9daf283b09c73-c7547fd7f58f';
		private static const PublisherType:String 	= 'snesbox';
		private static const TestIterations:uint	= 100;
		
		private var nc:NetConnection;
		
		private var myPeerId:String;
		private var farPeerId:String;
		
		private var sendStream:NetStream;
		private var recvStream:NetStream;
		
		private var sendStreamStarted:Boolean;
		private var recvStreamStarted:Boolean;
		private var isFirstPeer:Boolean;
		
		public var handler:INetworkSessionHandler;
		
		public function NetworkSession(handler:INetworkSessionHandler)
		{
			this.handler = handler;
			
			nc = new NetConnection();
			
			var client:Object = {};
			client.onRelay = function(id:String):void
			{
				if (!farPeerId || !farPeerId.length)
				{
					farPeerId = id;
					initStreams();
				}
			};
			
			nc.client = client;
			
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus)
		}
		
		public function connect(farPeerId:String = ''):void
		{
			this.farPeerId = farPeerId;
			
			nc.connect(ServerAddress, DeveloperKey);
		}
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			switch(event.info.code)
			{
				case 'NetConnection.Connect.Success':
				{
					if (!myPeerId)
					{
						myPeerId = nc.nearID;
						
						handler.onNetworkPeer(myPeerId);
						
						var isSecondPeer:Boolean = farPeerId && farPeerId.length == 64;
						
						isFirstPeer = !isSecondPeer;
						
						if (isSecondPeer)
						{
							nc.call('relay', null, farPeerId);
							initStreams();
						}
					}
				}
					break;
				
				case 'NetStream.Connect.Success':
					break;
				case 'NetStream.Connect.Closed':
					break;
			}
		}
		
		private function initStreams():void
		{
			sendStream = new NetStream(nc, NetStream.DIRECT_CONNECTIONS);
			sendStream.addEventListener(NetStatusEvent.NET_STATUS, sendStreamStatusHandler);
			sendStream.publish(PublisherType);
			
			recvStream = new NetStream(nc, farPeerId);
			recvStream.addEventListener(NetStatusEvent.NET_STATUS, recvStreamStatusHandler);
			recvStream.play(PublisherType);
			
			var recvClient:Object = { };
			var testIndex:uint = TestIterations;
			var totalPing:uint = 0;
			
			recvClient.i = function(value:uint):void
			{
				var input:uint = value & 0xffffff;
				
				handler.onNetworkInput(input);
			};
			
			recvClient.d = function(value:uint):void {};
			
			recvClient.ping = function(time:uint):void
			{
				sendStream.send('pong', time);
			}
				
			recvClient.pong = function(time:uint):void
			{
				var delta:uint = getTimer() - time;
				testIndex--;
				totalPing += delta;
				
				if(testIndex)
				{
					test();
				}
				else
				{
					var ping:uint = totalPing / TestIterations;
					handler.onNetworkStart(isFirstPeer, ping);
				}
			}
			
			recvStream.client = recvClient;
		}
		
		private function sendStreamStatusHandler(event:NetStatusEvent):void
		{
			switch(event.info.code)
			{
				case 'NetStream.Play.Start':
					sendStreamStarted = true;
					break;
			}
			
			checkStart();
		}
		
		private function recvStreamStatusHandler(event:NetStatusEvent):void
		{
			switch(event.info.code)
			{
				case 'NetStream.Play.Start':
					recvStreamStarted = true;
					break;
			}
			
			checkStart();
		}
		
		private function checkStart():void
		{
			if (sendStreamStarted 
				&& recvStreamStarted)
			{
				sendStream.removeEventListener(NetStatusEvent.NET_STATUS, sendStreamStatusHandler);
				recvStream.removeEventListener(NetStatusEvent.NET_STATUS, recvStreamStatusHandler);
				
				handler.onNetworkTest();
			}
		}
		
		public function sendInput(input:uint):void
		{
			sendStream.send('i', input);
		}
		
		public function sendDummy():void
		{
			sendStream.send('d', 555);
		}
		
		public function test():void
		{
			sendStream.send('ping', getTimer());
		}
	}
}
