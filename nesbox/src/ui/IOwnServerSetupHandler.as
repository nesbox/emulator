package ui
{
	import model.ServerSettings;

	public interface IOwnServerSetupHandler
	{
		function onOwnServerSetupConnect(serverSettings:ServerSettings):void;
	}
}