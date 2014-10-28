package nl.teddevos.snakemp 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import nl.teddevos.snakemp.client.Client;
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	import nl.teddevos.snakemp.server.Server;
	import nl.teddevos.snakemp.client.input.*;
	import nl.teddevos.snakemp.client.data.SaveData;
	
	public class Main extends Sprite 
	{
		public static var main:Main;
		public static var client:Client;
		public static var server:Server;
		
		public static var serverHosting:Boolean = false;
		
		public function Main()
		{			
			Mouse.init(this.stage);
			
			main = this;
			
			SaveData.playerName = "Guy" + (int(Math.random() * 89999) + 10000);
			
			client = new Client();
			addChild(client);
			
			stage.stageFocusRect = false;
			
			addEventListener(Event.ENTER_FRAME, tick);
			stage.addEventListener(Event.ACTIVATE, onFocus);
			stage.addEventListener(Event.DEACTIVATE, unFocus);
		}
		
		public function tick(e:Event):void
		{
			client.tick();
			
			if (serverHosting)
			{
				server.tick();
			}
		}
		
		public static function startServer(s:String):void
		{
			if (!serverHosting)
			{
				server = new Server(s);
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
		
		private function onFocus(e:Event):void
		{
			stage.focus = client;
			stage.stageFocusRect = false;
		}
		
		private function unFocus(e:Event):void
		{
		}
	}
}