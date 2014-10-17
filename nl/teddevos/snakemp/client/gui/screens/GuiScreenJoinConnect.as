package nl.teddevos.snakemp.client.gui.screens 
{
	import nl.teddevos.snakemp.client.gui.GuiScreen;
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	import nl.teddevos.snakemp.client.gui.components.GuiButton;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.common.NetworkID;
	import nl.teddevos.snakemp.client.network.ServerTCPdataEvent;
	import nl.teddevos.snakemp.client.network.Connection;
	import nl.teddevos.snakemp.client.data.SaveData;
	
	public class GuiScreenJoinConnect extends GuiScreen
	{
		private var ipaddress:String;
		private var connectText:GuiText;
		private var errorText:GuiText;
		private var frameDelay:Boolean = false;
		private var killed:Boolean = false;
		
		public function GuiScreenJoinConnect(ip:String) 
		{
			ipaddress = ip;
		}
		
		override public function init():void
		{
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			
			connectText = new GuiText(400, 295, 20, 0x000000, "center");
			connectText.setText("Connecting to " + ipaddress);
			addChild(connectText);
			
			errorText = new GuiText(400, 335, 20, 0x000000, "center");
			errorText.setText("");
			addChild(errorText);
			
			var button_menu:GuiButton = new GuiButton(0, 275, 650, 50, 250, 0x555555);
			button_menu.setText("Cancel", 35, 0xFFFFFF);
			buttonList.push(button_menu);
			addChild(button_menu);
		}
		
		override public function tick():void 
		{ 
			if (!frameDelay)
			{
				frameDelay = true;
				Main.client.connection = new Connection();
				Main.client.connection.connect(ipaddress);
			}

			if (Main.client.connection.failed)
			{
				killed = true;
				connectText.setText("Connection failed!");
				errorText.setText("Reason: " + Main.client.connection.error);
				client.connection.kill();
			}
		}
		
		override public function action(b:GuiButton):void 
		{ 
			if (b.id == 0)
			{
				if (!killed)
				{
					client.connection.kill();
				}
				client.switchGui(new GuiScreenJoinInput(ipaddress));
			}
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.SERVER_WELCOME)
			{
				client.connection.playerID = parseInt(e.data);
				connectText.setText("Sending data...");
				client.connection.sendTCP(NetworkID.CLIENT_INFO_UPDATE, SaveData.playerName + "");
			}
			else if (e.id == NetworkID.SERVER_ACCEPT)
			{
				client.switchGui(new GuiScreenLobby(false, e.data));
			}
			else if (e.id == NetworkID.SERVER_REJECT_FULL)
			{
				killed = true;
				connectText.setText("Cannot join game!");
				errorText.setText("Reason: Server is full!");
				client.connection.kill();
			}
			else if (e.id == NetworkID.SERVER_REJECT_PLAYING)
			{
				killed = true;
				connectText.setText("Cannot join game!");
				errorText.setText("Reason: Cannot join during game!");
				client.connection.kill();
			}
			else if (e.id == NetworkID.SERVER_REJECT_NAME)
			{
				killed = true;
				connectText.setText("Cannot join game!");
				errorText.setText("Reason: Name already in use!");
				client.connection.kill();
			}
		}
		
		override public function destroy():void
		{
			client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
		}
	}
}