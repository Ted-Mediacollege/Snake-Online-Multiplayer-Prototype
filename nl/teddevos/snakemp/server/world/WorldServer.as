package nl.teddevos.snakemp.server.world 
{
	import nl.teddevos.snakemp.server.data.Settings;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.server.network.client.ClientConnection;
	import nl.teddevos.snakemp.server.network.client.ClientManager;
	import nl.teddevos.snakemp.common.NetworkID;
	
	public class WorldServer 
	{
		public var gameTime_start:Number;
		public var gameTime_current:Number;
		public var startTime:Number;
		public var turn:int;
		public var playing:Boolean;
		public var speed:int;
		public var frame:int;
		
		public var clientManager:ClientManager;
		
		public var pickupX:int;
		public var pickupY:int;
		
		public function WorldServer() 
		{
			var d:Date = new Date();
			gameTime_start = d.time;
			playing = false;
			speed = Settings.SPEED;
			
			var w:int = int((Settings.size - 10) / Settings.MAX_PLAYERS);
			clientManager = Main.server.clientManager;
			var l:int = clientManager.clients.length;
			for (var i:int = 0; i < l; i++)
			{
				clientManager.clients[i].posX = 5 + (w * i);
				clientManager.clients[i].posY = 10;
				clientManager.clients[i].posD = 2;
			}
		}
		
		public function start():void
		{
			nextPickup();
			playing = true;
			frame = 0;
		}
		
		public function checkPickup(id:int, s:String):void
		{
			var a:Array = s.split(";");
			if (pickupX == int(parseInt(a[0])) && pickupY == int(parseInt(a[1])))
			{
				var c:ClientConnection;
				var l:int = Main.server.clientManager.clients.length;
				for (var i:int = 0; i < l; i++)
				{
					if (Main.server.clientManager.clients[i].clientID == id)
					{
						c = Main.server.clientManager.clients[i];
						break;
					}
				}
				
				nextPickup();
				Main.server.clientManager.sendGameUDP(c, NetworkID.SERVER_GROW_UDP, frame + "");
				Main.server.clientManager.sendTCP(c, NetworkID.SERVER_GROW_TCP, frame + "");
			}
		}
		
		public function nextPickup():void
		{
			pickupX = 1 + int(Math.random() * (Settings.size - 2));
			pickupY = 1 + int(Math.random() * (Settings.size - 2));
			Main.server.clientManager.sendGameUDPtoAll(NetworkID.SERVER_NEXT_PICKUP_UDP, pickupX + ";" + pickupY + ";" + frame);
			Main.server.clientManager.sendTCPtoAll(NetworkID.SERVER_NEXT_PICKUP_TCP, pickupX + ";" + pickupY + ";" + frame);
		}
		
		public function tick():void
		{
			var d:Date = new Date();
			gameTime_current = d.time - gameTime_start;
			
			if (playing)
			{
				var newFrame:Boolean = false;
				var nF:int = int(gameTime_current / speed);
				if (nF > frame)
				{
					newFrame = true;
					frame = nF;
				}
				//turn = int((startTime - Main.client.world.gameTime) / speed);
			}
		}
		
		public function end():void
		{
			var l:int = clientManager.clients.length;
			for (var i:int = 0; i < l; i++ )
			{
				clientManager.clients[i].resetVariables();
			}
		}
	}
}