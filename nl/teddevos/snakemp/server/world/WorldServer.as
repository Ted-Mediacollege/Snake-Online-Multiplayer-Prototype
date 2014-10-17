package nl.teddevos.snakemp.server.world 
{
	public class WorldServer 
	{
		public var gameTime_start:Number;
		public var gameTime_current:Number;
		public var startTime:Number;
		public var playing:Boolean;
		
		public function WorldServer() 
		{
			var d:Date = new Date();
			gameTime_start = d.time;
			playing = false;
		}
		
		public function tick():void
		{
			var d:Date = new Date();
			gameTime_current = d.time - gameTime_start;
			
			if (playing)
			{
				
			}
		}
	}
}