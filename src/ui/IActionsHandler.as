package ui
{
	public interface IActionsHandler
	{
		function onActionsMute():void;
		function onActionsFullscreen():void;
		function onActionsFullscreenInteractive():void;
		function onActionsLoad():void;
		function onActionsSave():void;
		function onActionsSetup():void;
		function onActionsUpload():void;
		function onActionsGamepad():void;
		function onActionsFavorite():void;
		
		function onActionsShareFacebook():void;
		function onActionsShareGoogle():void;
		function onActionsShareTwitter():void;
		function onActionsShareVkontakte():void;
		function onActionsShareGithub():void;
	}
}