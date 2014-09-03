package mode
{
	import core.CorePlayerNetwork;
	import core.ICorePlayerHandler;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.System;
	
	import model.Gamepad;
	
	import network.INetworkSessionHandler;
	import network.NetworkSession;
	
	import ui.Actions;
	import ui.ActionsMode;
	import ui.IBaseSetup;
	import ui.ISetupHandler;
	import ui.Message;
	import ui.Setup;
	import ui.SetupBuilder;

	public class Network extends Base 
		implements 
			ICorePlayerHandler, 
			INetworkSessionHandler,
			ISetupHandler
	{
		private var nes:CorePlayerNetwork;
		private var actions:Actions;
		private var setup:IBaseSetup;
		private var message:Message;
		private var session:NetworkSession;
		
		public function Network(gameData:GameData)
		{
			super(gameData);
			
			nes 			= new CorePlayerNetwork(gameData.core, this);
			actions 		= new Actions(this, ActionsMode.Network);
			setup 			= SetupBuilder.Make(this, gameData);
			message 		= new Message;
			session 		= new NetworkSession(this);
			
			actions.muted = nes.muted = settings.muted;
			actions.visible = false;
			actions.enableFullscreen = Tools.isInteractiveFullscreenSupported();
		}
		
		protected override function init():void
		{			
			addChild(nes);
			addChild(actions);
			addChild(setup.sprite);
			addChild(message);
			
			super.init();
		}
		
		protected override function startActionsShow():void 
		{
			super.showActions(actions);
		}
		
		protected override function stopActionsShow():void 
		{
			super.hideActions(actions);
		}
		
		protected override function resume():void
		{
			super.resume();
			
			if(!setup.visible
				&& !message.visible)
			{
				nes.play();
			}
		}
		
		protected override function pauseEmulation():void
		{
			nes.pause();
		}
		
		protected override function resumeEmulation():void
		{
			nes.play();
		}
		
//		protected override function updateGamepadCodes(codes:Array):void
//		{
//			nes.updateGamepadCodes(codes);
//		}
		
		protected override function enableFullscreen(enable:Boolean):void 
		{
			actions.enableFullscreen = enable;
		}
		
//		protected override function enableGamepad(enable:Boolean):void
//		{
//			actions.enableGamepad = enable;
//		}

		private function checkArena():void
		{
			if(gameData.value && gameData.value.length == 64)
			{
				message.show('<p>'+locale.waiting_for_connection +'...<br><br><br><br>' +
					locale.sprintf(locale.if_you_cannot_connect, '<a href="http://cc.rtmfp.net">http://cc.rtmfp.net</a>')+'</p>');
				
				session.connect(gameData.value);
			}
			else
			{
				message.show('<p>'+locale.connecting_to_server+'...</p>');
				session.connect();
			}
		}
		

		public override function onActionsMute():void
		{
			nes.muted = !nes.muted;
			settings.muted = nes.muted;
			actions.muted = nes.muted;
		}
		
		public override function onActionsSetup():void
		{
			nes.pause();
			setup.show(settings.keyboard);
		}
		
		public override function onActionsUpload():void {}
		
		public function onSetupSave(joystick:Gamepad):void
		{
			settings.keyboard = joystick;
			nes.updateKeyCodes(joystick.codes);
			nes.play();
			setup.visible = false;
		}
		
		public function onSetupCancel():void
		{
			nes.play();
			setup.visible = false;
		}
		
		protected override function start():void
		{
			nes.updateKeyCodes(settings.keyboard.codes);
			nes.play();
			
			checkArena();
		}
		
		public function sendInput(input:uint):void
		{
			session.sendInput(input);
		}
		
		public function sendDummy():void
		{
			session.sendDummy();
		}
		
		public function onNetworkPeer(value:String):void
		{
			if(!gameData.value || gameData.value.length != 64)
			{
				gameData.value = value;
				
				var arenaUrl:String = 
					[
						gameData.domain, 
						(gameData.locale == 'en' ? '' : '/' + gameData.locale),
						'/game/', gameData.system,
						'/', gameData.game,
						'/rom/', gameData.rom, 
						'#arena=', gameData.value
					].join('');
				
				Tools.shortLink(arenaUrl, function(shortUrl:String):void
				{
					if(shortUrl)
					{
						var callbacks:Object = 
						{
							clipboard:function():void
							{
								System.setClipboard(shortUrl);
								
								message.show('<p>'+locale.new_send_copied_url+'<br><br>' +
									locale.waiting_for_connection+'...<br><br>' +
									locale.sprintf(locale.also_you_can_find_partner, '<br><a href="/chat" target="_blank">'+locale.public_chat+'</a>')+'<br><br>' +
									locale.sprintf(locale.if_you_cannot_connect, '<a href="http://cc.rtmfp.net" target="_blank">cc.rtmfp.net</a>')+'</p>');
							}
						};
						
						message.show('<p>'+locale.connected_to_server+'...<br><br>' +
							locale.remote_url+': ' + shortUrl + '<br><br>' + 
							'<a href="event:clipboard">' +
							locale.click_here_to_copy_url_to_clipboard+'</a>,<br><br>' +
							locale.then_send_it_to_friend+'...</p>', callbacks);
					}
					else
					{
						message.show('<p>'+locale.connection_error+'</p>');
					}
				});
			}
		}
		
		public function onNetworkInput(input:uint):void
		{
			nes.recvInputValue(input);
		}
		
		public function onNetworkTest():void 
		{
			message.show('<p>'+locale.testing_connection+'...</p>');
			
			session.test();
		}
		
		public function onNetworkStart(isFirstPeer:Boolean, ping:uint):void
		{
			var callbacks:Object = 
				{
					ok:function():void
					{
						message.hide();
						nes.play();
						
						if(!Focus.activated)
						{
							pause();
						}
						
						nes.updateKeyCodes(settings.keyboard.codes);
						nes.initNetworkEmulation(gameData.ntsc, isFirstPeer, gameData.data, gameData.region);
					}
				};
			
			if(ping < 100) 
				callbacks.ok();
			else 
				message.show('<p>'+locale.sprintf(locale.ping_is, ping) +'<br>' +
					locale.the_game_will_be_uncomfortable + '<br><br>' +
					'<a href="event:ok">OK</a></p>', callbacks);
		}
		
		protected override function onScreenShot():void
		{
			api.screen(gameData.rom, nes.screen);
		}
	}
}