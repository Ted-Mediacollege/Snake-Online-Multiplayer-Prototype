package nl.teddevos.snakemp.client.gui.screens 
{
	import nl.teddevos.snakemp.client.gui.GuiScreen;
	import nl.teddevos.snakemp.client.gui.components.GuiButton;
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.common.NetworkID;
	import nl.teddevos.snakemp.client.network.ServerTCPdataEvent;
	import nl.teddevos.snakemp.client.network.ServerGameDataEvent;
	
	public class GuiScreenPrepare extends GuiScreen
	{
		private var hosting:Boolean;
		private var serverinfo:GuiText;
		private var infoText:GuiText;
		private var ready:Boolean;
		private var startTime:Number = 1000000;
		private var waitTime:Boolean;
		
		public function GuiScreenPrepare(host:Boolean) 
		{
			hosting = host;
			ready = false;
			waitTime = false;
		}
		
		override public function init():void
		{
			Main.client.startWorld();
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			client.addEventListener(ServerGameDataEvent.DATA, onGameData);
			
			var title:GuiText = new GuiText(400, 360, 35, 0x000000, "center");
			title.setText("Preparing match");
			addChild(title);
			
			infoText = new GuiText(400, 410, 15, 0x000000, "center");
			infoText.setText("Matching game time...");
			addChild(infoText);
			
			if (hosting)
			{
				serverinfo = new GuiText(400, 600, 15, 0x000000, "center");
				serverinfo.setText("");
				addChild(serverinfo);
			}
		}
		
		override public function tick():void 
		{ 
			if (Main.client.inWorld)
			{
				if (Main.client.world.gameTimeDifference > 0 && Main.client.world.gameTimeDifference < 100)
				{
					if (!ready)
					{
						Main.client.connection.sendTCP(NetworkID.CLIENT_GAMETIME_MATCH);
						infoText.setText("Waiting for other players.");
						ready = true;
					}
				}
			}
			
			if (waitTime && Main.client.world.gameTime > startTime)
			{
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
				startTime = parseFloat(e.data);
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