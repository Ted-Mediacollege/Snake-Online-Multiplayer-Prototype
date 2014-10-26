package nl.teddevos.snakemp.client 
{
	import flash.display.Sprite;
	import nl.teddevos.snakemp.client.gui.GuiScreen;
	import nl.teddevos.snakemp.client.gui.screens.GuiScreenMenu;
	import nl.teddevos.snakemp.client.network.Connection;
	import nl.teddevos.snakemp.client.network.ConnectionTest;
	import nl.teddevos.snakemp.client.network.PingResponder;
	import nl.teddevos.snakemp.client.world.WorldClient;
	import nl.teddevos.snakemp.Main;
	
	public class Client extends Sprite
	{
		public var gui:GuiScreen;
		public var connection:Connection;
		public var pingResponder:PingResponder;
		public var connectionTester:ConnectionTest;
		
		public var world:WorldClient;
		public var inWorld:Boolean;
		
		public function Client() 
		{
			switchGui(new GuiScreenMenu());
			pingResponder = new PingResponder();
			connectionTester = new ConnectionTest();
		}
		
		public function tick():void
		{
			if (connection != null)
			{
				connection.tick();
			}
			if (inWorld)
			{
				world.tick();
			}
			gui.tick();
		}
		
		public function startWorld():void
		{
			world = new WorldClient();
			inWorld = true;
		}
		
		public function endWorld():void
		{
			world.destroy();
			world = null;
			inWorld = false;
		}
		
		public function switchGui(g:GuiScreen):void
		{
			if (gui != null)
			{
				gui.destroy();
				removeChild(gui);
			}
			gui = g;
			addChildAt(gui, 0);
			gui.preInit(this);
			Main.main.stage.focus = this;
			gui.init();
		}
	}
}