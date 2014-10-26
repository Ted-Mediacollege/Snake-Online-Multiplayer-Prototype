package nl.teddevos.snakemp.common 
{
	public class PlayerColor 
	{
		public static var colors:Vector.<uint> = new <uint>[0xFF0000, 0x0000FF, 0x00FF00, 0xFFFF00, 0x00FFFF, 0xFF00FF, 0xFF6600, 0x6600FF];
		public static var colorNames:Vector.<String> = new < String > ["Red", "Blue", "Green", "Yellow", "Cyan", "Pink", "Orange", "Purple"];
		
		public static function getColorForPlayer(id:int):uint
		{
			if (id < 8)
			{
				return colors[id];
			}
			else
			{
				return (Math.random() * 0xFFFFFF) & 0xFFFFFF;
			}
		}
		
		public static function getColorNameForPlayer(id:int):String
		{
			if (id < 8)
			{
				return colorNames[id];
			}
			else
			{
				return "Random color";
			}
		}
	}
}