package nl.teddevos.snakemp 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import nl.teddevos.snakemp.client.Client;
	import nl.teddevos.snakemp.server.Server;
	import nl.teddevos.snakemp.client.input.*;

	public class Main extends Sprite 
	{
		public static var client:Client;
		public static var server:Server;
		
		public static var serverHosting:Boolean = false;
		
		public function Main()
		{			
			Key.init(this.stage);
			Mouse.init(this.stage);
			
			client = new Client();
			addChild(client);
			
			addEventListener(Event.ENTER_FRAME, tick);
		}
		
		public function tick(e:Event):void
		{
			client.tick();
			
			if (serverHosting)
			{
				server.tick();
			}
		}
		
		public static function startServer():void
		{
			if (!serverHosting)
			{
				server = new Server();
				server.start();
				serverHosting = true;
			}
		}
		
		public static function killServer():void
		{
			if (serverHosting)
			{
				server.kill();
				server = null;
				serverHosting = false;
			}
		}
	}
}