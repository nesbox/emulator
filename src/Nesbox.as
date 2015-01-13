package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mode.Contest;
	import mode.Network;
	import mode.Own;
	import mode.OwnServer;
	import mode.Single;
	import mode.Walk;
	
	import ui.Message;
	
	[SWF(width='640', height='480', backgroundColor='0x000000')]
	
	public class Nesbox extends Sprite implements IGameDataHandler
	{
		private var gameData:GameData;
		private var info:Message;
		private var message:Message;
		private var emulator:DisplayObject;
		private var locale:Locale;
		
		public function Nesbox()
		{
			if(stage)
			{
				init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, function():void
				{
					init();
				});
			}
		}
		
		public function setSize(width:int, height:int):void
		{
			Variables.Width = width;
			Variables.Height = height;
		}
		
		public function onInfoShow(value:String):void
		{
			info.show(value);
		}

		private function createContextMenu():void
		{
			var customMenu:ContextMenu = new ContextMenu();
			customMenu.hideBuiltInItems();
			
			var emulatorItem:ContextMenuItem = new ContextMenuItem(locale.hint_share);
			emulatorItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function():void
			{
				Tools.gotoNesboxPage();
			});
			
			customMenu.customItems.push(emulatorItem);
			
			contextMenu = customMenu;

		}
		
		private function init():void
		{
			setSize(stage.stageWidth / 2, stage.stageHeight / 2);
			
			scaleX = scaleY = 2;
			
			Focus.init(stage);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
				
			locale = Locale.instance;
			gameData = new GameData(this, stage.loaderInfo.loaderURL);
			
			gameData.loadParams(stage.loaderInfo.parameters);
			
			addChild(info = new Message);
			
			gameData.loadLocale();
		}
		
		public function onLoadLocale():void
		{
			createContextMenu();
			
			if (gameData.action == GameData.Own 
				&& gameData.url == null)
			{
				initOwnRomMode();
			}
			else
				gameData.init();			
		}
		
		public function onLoadRom():void
		{
			removeChild(info);
			
			if(gameData.action)
			{
				switch(gameData.action)
				{
					case GameData.One:
						startSingleMode();
						break;
					case GameData.Arena:
						startNetworkMode();
						break;
					case GameData.Save:
						startSingleMode();
						break;
					case GameData.Walk:
						gameData.value ? startWalkMode() : startContestMode();
						break;
					case GameData.Own:
						startOwnRomMode();
						break;
					case GameData.Room:
						startOwnServerMode();
						break;
					default:
						selectMode();
				}
			}
			else
			{
				selectMode();
			}
		}
		
		private function selectMode():void
		{
			message = new Message();
			addChild(message);
			
			var callbacks:Object = 
				{
					single:startSingleMode,
					network:startNetworkMode,
					contest:startContestMode,
					own:startOwnServerMode
				};
			
			message.show('<p>' + locale.select_mode.toUpperCase() + ':<br>' +
				'<br><br>1 - <a href="event:single">'+locale.one_player+'</a>' +
				'<br><br>2 - <a href="event:contest">'+locale.game_walkthrough+'</a>'+
				'<br><br>3 - <a href="event:network">'+locale.two_players_via_internet+'</a>' +
				'<br><br>4 - <a href="event:own">'+locale.your_own_server+'</a> (beta)' +
				'</p>' 
				, callbacks);
		}
		
		private function startSingleMode():void
		{
			Analytics.trackStartSingleEvent();
			addEmulator(new Single(gameData));
		}

		private function startOwnRomMode():void
		{
			Analytics.trackOwnRomEvent();
			JSProxy.resizeOwnEmulator(Variables.Width*2, Variables.Height*2);
			addEmulator(new Own(gameData));
		}
		
		private function initOwnRomMode():void
		{
			var callbacks:Object = 
				{
					own:function():void
					{
						Analytics.trackOwnRomEvent();
						
						var romsFilter:FileFilter = new FileFilter("Supported roms", "*.nes;*.smc;*.gen;*.gb;*.gbc;*.gba;*.zip");
						var ref:FileReference = new FileReference();
						ref.addEventListener(Event.SELECT, function():void
						{
							ref.load();
						});
						ref.addEventListener(Event.COMPLETE, function():void
						{
							gameData.data = ref.data;
							
							gameData.parseOwnRomName(ref.name);
							
							gameData.init();
						});
						ref.browse([romsFilter]);
					}
				};
			
			info.show('<p>'+locale.supported_rom_formats+':<br><br>NES (*.nes), SNES (*.smc), SEGA (*.gen),<br>GAMEBOY/COLOR/ADVANCE (*.gb, *.gbc, *.gba)<br><br><br>' +
				'<a href="event:own">'+
				locale.click_here_to_load_your_own_rom +
				'...</a></p>', callbacks);
		}

		private function startNetworkMode():void
		{
			Analytics.trackStartNetworkEvent();
			addEmulator(new Network(gameData));
		}
		
		private function startOwnServerMode():void
		{
			Analytics.trackOwnServerEvent();
			addEmulator(new OwnServer(gameData));
		}
		
		private function startWalkMode():void
		{
			Analytics.trackStartWalkEvent();
			addEmulator(new Walk(gameData));
		}
		
		private function startContestMode():void
		{
			Analytics.trackStartContestEvent();
			addEmulator(new Contest(gameData));
		}
		
		private function addEmulator(emulator:DisplayObject):void
		{
			if(message && contains(message))
			{
				this.removeChild(message);
				message = null;
			}
			
			this.emulator = emulator;
			addChild(emulator);
		}
	}
}
