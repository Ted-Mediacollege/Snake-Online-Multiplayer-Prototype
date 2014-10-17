package nl.teddevos.snakemp.client.gui.screens 
{
	import nl.teddevos.snakemp.client.gui.GuiScreen;
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	import nl.teddevos.snakemp.client.gui.components.GuiButton;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.client.network.Connection;
	import nl.teddevos.snakemp.client.network.ServerTCPdataEvent;
	import nl.teddevos.snakemp.common.NetworkID;
	import nl.teddevos.snakemp.client.data.SaveData;
	
	public class GuiScreenJoinHosting extends GuiScreen
	{
		private var connectText:GuiText;
		
		public function GuiScreenJoinHosting() 
		{
		}
		
		override public function init():void
		{
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			
			connectText = new GuiText(400, 295, 20, 0x000000, "center");
			connectText.setText("Creating server... ");
			addChild(connectText);
			
			Main.startServer();
			Main.client.connection = new Connection();
			Main.client.connection.connect("127.0.0.1");
		}
		
		override public function tick():void 
		{ 
			if (Main.client.connection.failed)
			{
				connectText.setText("Failed to create server!");
				if (client.connection.socketTCP.connected)
				{
					client.connection.kill();
				}
				Main.killServer();
				
				var button_menu:GuiButton = new GuiButton(0, 275, 650, 50, 250, 0x555555);
				button_menu.setText("Back to menu", 35, 0xFFFFFF);
				buttonList.push(button_menu);
				addChild(button_menu);
			}
		}
		
		override public function action(b:GuiButton):void 
		{ 
			if (b.id == 0)
			{
				client.switchGui(new GuiScreenMenu());
			}
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.SERVER_WELCOME)
			{
				client.connection.playerID = parseInt(e.data);
				client.connection.sendTCP(NetworkID.CLIENT_INFO_UPDATE, SaveData.playerName + "");
			}
			else if (e.id == NetworkID.SERVER_ACCEPT)
			{
				client.switchGui(new GuiScreenLobby(true, e.data));
			}
		}
		
		override public function destroy():void
		{
			client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
		}
	}
}