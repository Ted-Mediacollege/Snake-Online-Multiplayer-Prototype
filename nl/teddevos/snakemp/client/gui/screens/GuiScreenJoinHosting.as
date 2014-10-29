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
	import nl.teddevos.snakemp.client.gui.components.GuiTextInput;
	
	public class GuiScreenJoinHosting extends GuiScreen
	{
		private var connectText:GuiText;
		private var inputField:GuiTextInput;
		private var connecting:Boolean;
		private var button_host:GuiButton;
		
		public function GuiScreenJoinHosting() 
		{
		}
		
		override public function init():void
		{
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			
			connectText = new GuiText(400, 295, 25, 0x000000, "center");
			connectText.setText("Server name?");
			addChild(connectText);
			
			inputField = new GuiTextInput(230, 340, 30, 0x000000, "left", 25, "a-zA-Z0-9_ ");
			if (SaveData.serverName.length == 0)
			{
				inputField.setText(SaveData.playerName + "s server");
				SaveData.serverName = SaveData.playerName + "s server";
			}
			else
			{
				inputField.setText(SaveData.serverName);
			}
			addChild(inputField);
			
			graphics.lineStyle(3, 0x000000);
			graphics.drawRect(225, 340, 350, 40);
			
			button_host = new GuiButton(1, 275, 440, 50, 250, 0x555555);
			button_host.setText("Host Game", 35, 0xFFFFFF);
			buttonList.push(button_host);
			addChild(button_host);
			
			connecting = false;
		}
		
		override public function tick():void 
		{ 
			if (connecting && Main.client.connection.failed)
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
			else if (b.id == 1)
			{	
				if (inputField.tf.text.length == 0)
				{
					inputField.tf.text = SaveData.playerName + " server";
					SaveData.serverName = inputField.tf.text;
				}
				
				button_host.enabled = false;
				removeChild(button_host);
				removeChild(inputField);
				graphics.clear();
				
				connectText.setText("Creating server... ");		
				Main.startServer(inputField.tf.text);
				Main.client.connection = new Connection();
				Main.client.connection.connect("127.0.0.1");
				connecting = true;
			}
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.SERVER_WELCOME)
			{
				var q:Array = e.data.split("#");
				client.connection.serverName = q[1];
				client.connection.maxPlayers = int(parseInt(q[2]));
				client.connection.playerID = parseInt(q[0]);
				connectText.setText("Sending data...");
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