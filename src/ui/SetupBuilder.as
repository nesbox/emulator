package ui
{
	public class SetupBuilder
	{
		public static function Make(handler:ISetupHandler, gameData:GameData):IBaseSetup
		{
			var isTutorial:Boolean = gameData.system == 'gb' || gameData.system == 'gba';
			
			return isTutorial 
				? new SetupTutorial(handler, gameData.core) 
				: new Setup(handler, gameData.core);
		}
	}
}