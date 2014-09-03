package ui
{
	import flash.display.Sprite;
	import flash.events.TextEvent;
	
	import model.ServerSettings;
	
	public class OwnServerSetup extends Sprite
	{
		private var title:Text;
		
		private var howToLabel:Text;
		
		private var ipLabel:Text;
		private var ipInput:TextInput;
		
		private var portLabel:Text;
		private var portInput:TextInput;

		private var frameskipLabel:Text;
		private var frameskipInput:TextInput;

		private var buttons:Text;
		
		private var handler:IOwnServerSetupHandler;
		
		private var locale:Locale;
		
		public function OwnServerSetup(handler:IOwnServerSetupHandler)
		{
			super();
			
			locale = Locale.instance;
			
			this.handler = handler;
			
			visible = false;
			
			title = new Text;
			title.htmlText = '<p>'+locale.server_setup.toUpperCase()+'</p>';
			addChild(title);
			
			howToLabel = new Text();
			howToLabel.htmlText = '<p>'
				+ locale.please_read
				+ ': <a href="/labs" target="_blank">'+locale.how_start_own_server+'?</a></p>';
			addChild(howToLabel);
			
			ipLabel = new Text;
			ipLabel.htmlText = '<p>IP:</p>';
			addChild(ipLabel);
			
			portLabel = new Text;
			portLabel.htmlText = '<p>'+locale.server_port+':</p>';
			addChild(portLabel);
			
			ipInput = new TextInput();
			addChild(ipInput);
			
			portInput = new TextInput();
			addChild(portInput);
			
			frameskipLabel = new Text;
			frameskipLabel.htmlText = '<p>'+locale.server_frameskip+':</p>';
			addChild(frameskipLabel);
			
			frameskipInput = new TextInput();
			addChild(frameskipInput);
			
			buttons = new Text();
			buttons.htmlText = '<p>' +
				'<a href="event:connect">'+locale.connect.toLocaleUpperCase()+'</a></p>';
			buttons.addEventListener(TextEvent.LINK, onLink);
			addChild(buttons);
		}
		
		public function show(serverSettings:ServerSettings):void
		{
			ipInput.text = serverSettings.ip;
			portInput.text = serverSettings.port.toString();
			frameskipInput.text = serverSettings.frameskip.toString();
			
			update();
			
			visible = true;
		}
		
		private function update():void
		{
			graphics.clear();
			graphics.beginFill(0x666666);
			graphics.drawRect(0, 0, Variables.Width, Variables.Height);
			graphics.endFill();
			
			const Gap:int = 10;
			
			title.x = (Variables.Width - title.width) / 2;
			title.y = Gap;
			
			howToLabel.x = Gap;
			howToLabel.y = title.y + title.height + Gap;
				
			ipLabel.x = Gap;
			ipLabel.y = howToLabel.y + howToLabel.height + Gap;
			
			ipInput.x = ipLabel.x + ipLabel.width;
			ipInput.y = ipLabel.y;
			ipInput.width = 80;
			ipInput.height = ipLabel.height;
			
			portLabel.x = ipLabel.x;
			portLabel.y = ipInput.y + ipInput.height + Gap;
			
			portInput.x = portLabel.x + portLabel.width;
			portInput.y = portLabel.y;
			portInput.width = 40;
			portInput.height = portLabel.height;
			
			frameskipLabel.x = portLabel.x;
			frameskipLabel.y = portInput.y + portInput.height + Gap;
			
			frameskipInput.x = frameskipLabel.x + frameskipLabel.width;
			frameskipInput.y = frameskipLabel.y;
			frameskipInput.width = 40;
			frameskipInput.height = frameskipLabel.height;
			
			buttons.x = (Variables.Width - buttons.width) / 2;
			buttons.y = portInput.y + portInput.height + Gap*5;
		}
		
		private function onLink(event:TextEvent):void
		{
			switch(event.text)
			{
				case 'connect':
					connect();
					break;
			}
		}
		
		private function connect():void
		{
			handler.onOwnServerSetupConnect(new ServerSettings(ipInput.text, int(portInput.text), int(frameskipInput.text)));
		}
	}
}