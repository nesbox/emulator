package mode
{
	import core.CorePlayerWalk;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import server.IApiHandler;
	
	import ui.Actions;
	import ui.ActionsMode;
	import ui.IActionsHandler;
	import ui.Message;

	public class Walk extends Base implements IActionsHandler, IApiHandler
	{
		private var nes:CorePlayerWalk;
		private var actions:Actions;
		private var message:Message;
		
		private var frames:uint;
		
		public function Walk(gameData:GameData)
		{
			super(gameData);
			
			nes 		= new CorePlayerWalk(gameData.core, this);
			actions 	= new Actions(this, ActionsMode.Walk);
			message 	= new Message;
			
			actions.muted = nes.muted = settings.muted;
			actions.visible = false;
		}
		
		protected override function init():void
		{			
			addChild(nes);
			addChild(actions);
			addChild(message);

			initActivateEngine();
			
			nes.pause();
			message.show('<p>'+locale.loading_walkthrough+'...</p>');
			
			api.loadWalk(gameData.rom, gameData.value);
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
			
			if(!message.visible)
			{
				nes.play();
			}
		}
		
		protected override function pause():void
		{
			if(!message.visible)
			{
				super.pause();
				nes.pause();
			}
		}
		
		public override function onActionsMute():void
		{
			nes.muted = !nes.muted;
			settings.muted = nes.muted;
			actions.muted = nes.muted;
		}
		
		public override function onApiError(info:String):void
		{
			var callbacks:Object = 
				{
					close:function():void
					{
						nes.play();
					}
				};
			
			message.show('<p>Error occurred,<br>please, try again later...' +
				'<br><br><a href="event:close">CLOSE</a></p>', callbacks);
		}	
			
		public override function onApiLoaded(walk:ByteArray):void
		{
			if(walk)
			{
				walk.uncompress();
				
				frames = walk.length >> 1;
				
				stage.addEventListener(Event.ENTER_FRAME, onUpdateTime);
				
				nes.initWalkEmulation(gameData.ntsc, walk, gameData.data, gameData.region);
				message.hide();
				
				Focus.activated ? nes.play() : pause();
			}
		}
		
		private function onUpdateTime(event:Event):void
		{
			if(nes.paused)return;
			
			var seconds:int = frames / stage.frameRate;
			var minutes:int = seconds / 60;
			var hours:int = minutes / 60;
			
			minutes -= hours*60;
			seconds -= hours*60*60 + minutes*60;
			
			actions.info = '<p>' + 
				[
					hours < 10 ? '0' + hours.toString() : hours
					, minutes < 10 ? '0' + minutes.toString() : minutes
					, seconds < 10 ? '0' + seconds.toString() : seconds
				].join(':') + '</p>';
			
			frames--;
			
			if(frames == 0)
			{
				stage.removeEventListener(Event.ENTER_FRAME, onUpdateTime);
			}
		}
		
		protected override function onScreenShot():void
		{
			api.screen(gameData.rom, nes.screen);
		}
	}
}