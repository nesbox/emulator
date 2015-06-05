Nesbox Emulator
========

NESbox is an emulator of NES, Super Nintendo, Sega Mega Drive and GameBoy video consoles, built on Adobe Flash technology and it can only be run directly in your browser's window.

How to embed the emulator to your webpage?
--------

Get all .swf files in /bin folder and upload to your server (for example to /flash folder).
Add the following html to page where you want to place the emulator.

```html

<div>
	<div id="emulator">
		<p>To play this game, please, download the latest Flash player!</p>
		<br>
		<a href="http://www.adobe.com/go/getflashplayer">
			<img src="//www.adobe.com/images/shared/download_buttons/get_adobe_flash_player.png" alt="Get Adobe Flash player"/>
		</a>
	</div>
</div>

<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js"></script>

<script type="text/javascript">

	var resizeOwnEmulator = function(width, height)
	{
		var emulator = $('#emulator');
		emulator.css('width', width);
		emulator.css('height', height);
	}

	$(function()
	{
		function embed()
		{
			var emulator = $('#emulator');
			if(emulator)
			{
				var flashvars = 
				{
					system : 'sega',
					url : '/roms/Flappy Bird (PD) v1.0.gen'
				};
				var params = {};
				var attributes = {};
				
				params.allowscriptaccess = 'sameDomain';
				params.allowFullScreen = 'true';
				params.allowFullScreenInteractive = 'true';
				
				swfobject.embedSWF('flash/Nesbox.swf', 'emulator', '640', '480', '11.2.0', 'flash/expressInstall.swf', flashvars, params, attributes);
			}
		}
		
		embed();
	});
	
</script>

```

Supported systems: nes, snes, sega, gb, gba

License
----

MIT
