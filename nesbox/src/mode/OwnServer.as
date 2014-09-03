package mode
{
	import com.hurlant.util.Base64;
	
	import core.CorePlayerOwnServer;
	import core.ICorePlayerHandler;
	
	import flash.system.System;
	
	import model.Gamepad;
	import model.ServerSettings;
	
	import network.IOwnServerSessionHandler;
	import network.OwnServerSession;
	
	import ui.Actions;
	import ui.ActionsMode;
	import ui.IBaseSetup;
	import ui.IOwnServerSetupHandler;
	import ui.ISetupHandler;
	import ui.Message;
	import ui.OwnServerSetup;
	import ui.Setup;
	import ui.SetupBuilder;

	public class OwnServer extends Base 
		implements 
			ICorePlayerHandler, 
			IOwnServerSessionHandler,
			ISetupHandler,
			IOwnServerSetupHandler
	{
		private var nes:CorePlayerOwnServer;
		private var actions:Actions;
		private var setup:IBaseSetup;
		private var message:Message;
		private var session:OwnServerSession;
		private var ownServerSetup:OwnServerSetup;
		private var isFirstPeer:Boolean;
		
		public function OwnServer(gameData:GameData)
		{
			super(gameData);
			
			nes 			= new CorePlayerOwnServer(gameData.core, this);
			actions 		= new Actions(this, ActionsMode.Network);
			setup 			= SetupBuilder.Make(this, gameData);
			message 		= new Message();
			session 		= new OwnServerSession(this);
			ownServerSetup	= new OwnServerSetup(this);
			
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
			addChild(ownServerSetup);
			
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
		
		protected override function enableFullscreen(enable:Boolean):void 
		{
			actions.enableFullscreen = enable;
		}
		
		private function checkRoom():void
		{
			if(gameData.value && gameData.value.length > 0)
			{
				var data:Object = JSON.parse(Base64.decode(gameData.value));
				
				if(data && data.ip && data.port)
				{
					if(data.room)
					{
						isFirstPeer = false;
					
						message.show('<p>'+locale.waiting_for_connection +'...</p>');
					
						session.connect(data.ip, data.port, data.room);
					}
					else
					{
						isFirstPeer = true;
						var serverSettings:ServerSettings = new ServerSettings(data.ip, data.port, 0);
						ownServerSetup.show(serverSettings);						
					}
				}
				else
				{
					onOwnServerError();
				}
			}
			else
			{
				isFirstPeer = true;
				
				ownServerSetup.show(settings.server);
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
			
			checkRoom();
		}
		
		public function sendInput(input:uint):void
		{
			session.sendInput(input);
		}
		
		public function sendDummy():void {}
		
		public function onOwnServerConnected(ip:String, port:int, room:String, frameskip:int):void
		{
			if(isFirstPeer)
			{
				var value:String = Base64.encode(JSON.stringify(
					{
						ip:ip,
						port:port,
						room:room
					}));
					
				var roomUrl:String = 
					[
						gameData.domain, 
						(gameData.locale == 'en' ? '' : '/' + gameData.locale),
						'/game/', gameData.system,
						'/', gameData.game,
						'/rom/', gameData.rom, 
						'#room=', value
					].join('');
				
				Tools.shortLink(roomUrl, function(shortUrl:String):void
				{
					if(shortUrl)
					{
						var callbacks:Object = 
						{
							clipboard:function():void
							{
								System.setClipboard(shortUrl);
								
								message.show('<p>'+locale.new_send_copied_url+'<br><br>' +
									locale.waiting_for_connection+'...<br><br></p>');
								
								startPlaying(frameskip);
							}
						};
						
						message.show('<p>'+locale.you_are_connected+'.<br><br>' +
							locale.remote_url_is+': '+shortUrl+'.<br><br><br><br>' +
							'<a href="event:clipboard">'+locale.click_here_to_copy_url_to_clipboard+'</a><br><br>' +
							locale.and_send_to_friend+'.</p>', callbacks);
					}
					else
					{
						message.show('<p>'+locale.connection_error+'</p>');
					}
				});
			}
			else
			{
				startPlaying(frameskip);
			}
		}
		
		private function startPlaying(frameskip:int):void
		{
			nes.play();
			nes.updateKeyCodes(settings.keyboard.codes);
			nes.initNetworkEmulation(gameData.ntsc, gameData.data, gameData.region, frameskip);
		}
		
		public function onOwnServerDisconnected():void
		{
			nes.pause();
			message.show('<p>'+locale.connection_has_closed+'!</p>');
		}
		
		public function onOwnServerError():void
		{
			var callbacks:Object = 
				{
					again:function():void
					{
						ownServerSetup.show(settings.server);
					}
				};
			
			message.show('<p>'+locale.server_connection_error+',<br>' +
				locale.make_sure_entered_correct_ip+'.' +
				'<br><br><br><br>' +
				'<a href="event:again">'+locale.try_again.toUpperCase()+'</a></p>', callbacks);
		}
		
		protected override function onScreenShot():void
		{
			api.screen(gameData.rom, nes.screen);
		}
		
		public function onOwnServerSetupConnect(serverSettings:ServerSettings):void
		{
			ownServerSetup.visible = false;
			
			message.show('<p>'+locale.waiting_for_connection +'...</p>');
			
			settings.server = serverSettings;
			
			session.connect(serverSettings.ip
				, serverSettings.port
				, null
				, serverSettings.frameskip);
		}
		
		public function onOwnServerInput(input:uint):void
		{
			if(message.visible)
				message.hide();
			
			nes.recvInputValue(input);
		}
	}
}