package ui
{
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	internal class TextInput extends TextField
	{
		private var format:TextFormat;
		
		public function TextInput(defaultText:String = '')
		{
			background = true;
			backgroundColor = 0x888888;
			type = TextFieldType.INPUT;
			tabEnabled = true;
			
			format = new TextFormat;
			
			format.font = 'verdana';
			format.color = 0xffffff;
			format.size = 8;
			
			text = defaultText;
		}
		
		public override function set text(value:String):void
		{
			super.text = value;
			
			setTextFormat(format);
		}
	}
}