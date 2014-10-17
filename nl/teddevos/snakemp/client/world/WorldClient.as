package nl.teddevos.snakemp.client.world 
{
	import flash.display.Sprite;
	
	public class WorldClient extends Sprite
	{
		public var gameTimeDifference:int;
		public var gameTime:int;
		private var time_old:int;
		private var time:int;
		private var ticking:Boolean;
		public var playing:Boolean;
		
		public function WorldClient() 
		{
			gameTime = 0;
			ticking = false;
			playing = false;
		}
		
		public function tick():void
		{
			if (ticking)
			{
				var d:Date = new Date();
				time = d.time - time_old;
				time_old = d.time;
				gameTime += time;
			}
			if (playing)
			{
				
			}
		}
		
		public function newGameTime(t:Number, p:Number):void
		{
			if (!ticking)
			{
				gameTime = t + p;
				ticking = true;
				
				var d:Date = new Date();
				time_old = d.time;
			}
			else
			{
				var diff:Number = gameTime - (t + p);
				gameTimeDifference = int(Math.abs(diff));
				gameTime = t + p;
			}
		}
	}
}