package nl.teddevos.snakemp.client.input 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class Key 
	{
		public static var UP:Boolean = false;
		public static var DOWN:Boolean = false;
		public static var LEFT:Boolean = false;
		public static var RIGHT:Boolean = false;
		
		public static function init(stage:Stage):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		public static function onKeyDown(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.UP: UP = true; break;
				case Keyboard.DOWN: DOWN = true; break;
				case Keyboard.LEFT: LEFT = true; break;
				case Keyboard.RIGHT: RIGHT = true; break;
			}
		}
		
		public static function onKeyUp(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.UP: UP = false; break;
				case Keyboard.DOWN: DOWN = false; break;
				case Keyboard.LEFT: LEFT = false; break;
				case Keyboard.RIGHT: RIGHT = false; break;
			}
		}
	}
}