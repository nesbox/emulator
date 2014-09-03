package
{
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class Text extends TextField
	{
		public function Text(color:String = '#ffffff')
		{
			selectable = false;
			autoSize = TextFieldAutoSize.LEFT;
			
			var style:StyleSheet = new StyleSheet();
			
			style.setStyle('p', 
			{
				color: color,
				fontFamily: 'verdana',
				fontSize: 8
			});
			
			style.setStyle('a', 
			{
				textDecoration : 'underline'
			});
			
			styleSheet = style;
		}
	}
}