function initInput()
{
	var UP_BUTTON 		= 0;
	var DOWN_BUTTON 	= 1;
	var LEFT_BUTTON 	= 2;
	var RIGHT_BUTTON 	= 3;
	var START_BUTTON 	= 4;
	var SELECT_BUTTON 	= 5;
	var MODE_BUTTON 	= 6;
	var A_BUTTON 		= 7;
	var B_BUTTON 		= 8;
	var C_BUTTON 		= 9;
	var L_BUTTON 		= 10;
	var R_BUTTON 		= 11;
	var X_BUTTON 		= 12;
	var Y_BUTTON 		= 13;
	var Z_BUTTON 		= 14;

	var DefaultKeyCodes = [38, 40, 37, 39, 13, 32, 32, 90, 88, 67, 67, 68, 65, 83, 68];

	var processKey = function(code, down)
	{
		var index = DefaultKeyCodes.indexOf(code);

		if(index != -1)
		{
			down ? Module._PressButton(index) : Module._ReleaseButton(index);
		}
	}

	document.onkeydown = function(e)
	{
		e = e || window.event;
		processKey(e.keyCode, true);
		return true;
	}

	document.onkeyup = function(e)
	{
		e = e || window.event;
		processKey(e.keyCode, false);
		return true;
	}
	
}

// SOund DEMO
function initSound()
{
	var context = null;
	window.addEventListener('load', function()
	{
		try
		{
			window.AudioContext = window.AudioContext || window.webkitAudioContext;
			context = new window.AudioContext();

			var buffer = context.createBuffer(1, 44100 / 4, 44100);
			var data = buffer.getChannelData(0);

			for (var i = 0; i < data.length; i++)
				data[i] = ((~~(i / 100) % 2) == 0) ? 1 : -1;

			var source = context.createBufferSource();
			source.buffer = buffer;
			source.connect(context.destination);
			source.start(0);
		}
		catch(error)
		{
			console.log('Your browser doesn\'t support Web Audio API :(');
		}
	}, false);
}

initInput();