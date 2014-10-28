package nl.teddevos.snakemp.client.gui.screens 
{
	import nl.teddevos.snakemp.client.gui.GuiScreen;
	import nl.teddevos.snakemp.client.gui.components.GuiButton;
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.common.NetworkID;
	import nl.teddevos.snakemp.client.network.ServerTCPdataEvent;
	import nl.teddevos.snakemp.client.network.ServerGameDataEvent;
	import nl.teddevos.snakemp.common.PlayerColor;
	
	public class GuiScreenPrepare extends GuiScreen
	{
		private var hosting:Boolean;
		private var serverinfo:GuiText;
		private var infoText:GuiText;
		private var pingText:GuiText;
		private var ready:Boolean;
		private var startTime:Number = 1000000;
		private var waitTime:Boolean;
		private var maxDifference:Number;
		private var gametimeSpam:int;
		
		public function GuiScreenPrepare(host:Boolean) 
		{
			hosting = host;
			ready = false;
			waitTime = false;
			maxDifference = 1;
			gametimeSpam = 10;
			
			if (hosting)
			{
				ready = true;
				waitTime = true;
				gametimeSpam = 10000;
			}
		}
		
		override public function init():void
		{
			Main.client.startWorld();
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			client.addEventListener(ServerGameDataEvent.DATA, onGameData);
			
			var title:GuiText = new GuiText(400, 260, 35, 0x000000, "center");
			title.setText("Preparing match");
			addChild(title);
			
			infoText = new GuiText(400, 310, 15, 0x000000, "center");
			infoText.setText("Waiting for other players.");
			addChild(infoText);
			
			pingText = new GuiText(400, 750, 15, 0x000000, "center");
			pingText.setText("Lowest ping: 999ms");
			addChild(pingText);
			
			var id:int = client.connection.playerID;
			var color:GuiText = new GuiText(400, 460, 45, PlayerColor.getColorForPlayer(id), "center");
			color.setText("You are " + PlayerColor.getColorNameForPlayer(id));
			addChild(color);
			
			if (hosting)
			{
				pingText.setText("Lowest ping: 0ms (you are hosting!)");
				Main.client.world.newGameTime(Main.server.world.gameTime_current, 0, true);
				Main.client.connection.sendTCP(NetworkID.CLIENT_GAMETIME_MATCH);
			}
		}
		
		override public function tick():void 
		{ 
			if (!hosting)
			{
				if (!Main.client.connection.socketTCP.connected)
				{
					client.switchGui(new GuiScreenLost("Lost connection to server!"));
				}
				
				pingText.setText("Lowest ping: " + int(Main.client.world.lowestPing) + "ms");
				
				gametimeSpam--;
				if (gametimeSpam < 0)
				{
					gametimeSpam += 15;
					var d:Date = new Date();
					Main.client.connection.sendGameUDP(NetworkID.CLIENT_GAMETIME_REQUEST, "" + d.time);
				}
				
				if (!ready)
				{
					if (maxDifference < 50)
					{
						maxDifference += 1;
					}
					else if (maxDifference < 100)
					{
						maxDifference += 0.3;
					}
					else if (!ready)
					{
						client.switchGui(new GuiScreenLost("Ping to high! 150+ for more than 8 seconds"));
					}
				}
				
				if (Main.client.inWorld)
				{
					if (Main.client.world.gameTimeDifference > -1 && (Main.client.world.gameTimeDifference < maxDifference || Main.client.world.lowestPing < maxDifference))
					{
						if (!ready)
						{
							Main.client.connection.sendTCP(NetworkID.CLIENT_GAMETIME_MATCH);
							infoText.setText("Waiting for other players.");
							ready = true;
						}
					}
				}
			}
			
			if (waitTime && Main.client.world.gameTime > startTime)
			{
				Main.client.world.gameTime -= startTime;
				Main.client.world.playing = true;
				client.switchGui(new GuiScreenGame());
			}
			else if (waitTime)
			{
				infoText.setText("Game will start in " + (int((startTime - Main.client.world.gameTime) / 1000) + 1) + " seconds!");
			}
		}
		
		override public function action(b:GuiButton):void 
		{ 
			
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.SERVER_GAMETIME_START)
			{
				var a:Array = e.data.split("#");
				var b:Array = String(a[0]).split(";");
				
				startTime = parseFloat(b[0]);
				waitTime = true;
			}
		}
		
		public function onGameData(e:ServerGameDataEvent):void
		{
		}
		
		override public function destroy():void
		{
			client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			client.removeEventListener(ServerGameDataEvent.DATA, onGameData);
		}
	}
}