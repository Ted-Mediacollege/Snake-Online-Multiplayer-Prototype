package nl.teddevos.snakemp.client.world 
{
	public class CollisionCheck 
	{
		public var posX:int;
		public var posY:int;
		public var waitingTime:int;
		
		public function CollisionCheck(x:int, y:int, time:int) 
		{
			posX = x;
			posY = y;
			waitingTime = time;
		}
	}
}