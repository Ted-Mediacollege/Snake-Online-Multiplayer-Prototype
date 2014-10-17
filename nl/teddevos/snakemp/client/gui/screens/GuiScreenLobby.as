package nl.teddevos.snakemp.client.gui.screens 
{
	import nl.teddevos.snakemp.client.gui.components.GuiChat;
	import nl.teddevos.snakemp.client.gui.components.GuiPlayerList;
	import nl.teddevos.snakemp.client.gui.GuiScreen;
	import nl.teddevos.snakemp.client.gui.components.GuiButton;
	import nl.teddevos.snakemp.client.network.Connection;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.client.network.ServerTCPdataEvent;
	import nl.teddevos.snakemp.common.NetworkID;
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class GuiScreenLobby extends GuiScreen
	{
		private var playerList:GuiPlayerList;
		private var chatbox:GuiChat;
		private var hosting:Boolean;
		private var ready:Boolean = false;
		private var button_ready:GuiButton;
		
		public function GuiScreenLobby(host:Boolean, pl:String) 
		{
			hosting = host;

			playerList = new GuiPlayerList();
			playerList.update(pl);
			playerList.x = 20;
			playerList.y = 100;
			addChild(playerList);
			
			chatbox = new GuiChat();
			chatbox.x = 20;
			chatbox.y = 585;
			addChild(chatbox);
		}
		
		override public function init():void
		{
			var title:GuiText = new GuiText(400, 20, 35, 0x000000, "center");
			title.setText("Snake Multiplayer Lobby");
			addChild(title);
			
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			client.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			button_ready = new GuiButton(1, 20, 515, 50, 150, 0xFF7777);
			button_ready.setText("Ready", 35, 0xFFFFFF);
			buttonList.push(button_ready);
			addChild(button_ready);
			
			var button_menu:GuiButton = new GuiButton(0, 190, 515, 50, 250, 0x777777);
			button_menu.setText("Back to menu", 35, 0xFFFFFF);
			buttonList.push(button_menu);
			addChild(button_menu);
		}
		
		override public function tick():void 
		{ 
			if (!Main.client.connection.socketTCP.connected)
			{
				Main.client.connection.kill();
				client.switchGui(new GuiScreenLost("Lost connection to server!"));
			}
		}
		
		override public function action(b:GuiButton):void 
		{ 
			if (b.id == 0)
			{
				if (hosting)
				{
					Main.server.clientManager.sendQuickUDPtoAll(NetworkID.SERVER_END, "end");
					Main.killServer();
				}
				client.connection.kill();
				client.switchGui(new GuiScreenMenu());
			}
			else if (b.id == 1)
			{
				ready = !ready;
				client.connection.sendQuickUDP(NetworkID.CLIENT_INFO_READY, ready ? 1 + "" : 0 + "");
				button_ready.updateBoxColor(ready ? 0x77FF77 : 0xFF7777);
			}
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.SERVER_LOBBY_LIST_UPDATE)
			{
				playerList.update(e.data);
			}
			else if (e.id == NetworkID.SERVER_LOBBY_CHAT_SYNC)
			{
				chatbox.chatSync(e.data);
			}
			else if (e.id == NetworkID.SERVER_KICK && !hosting)
			{
				Main.client.connection.kill();
				client.switchGui(new GuiScreenLost("You have been kicked by the host, Reason: " + e.data));
			}
			else if (e.id == NetworkID.SERVER_END && !hosting)
			{
				Main.client.connection.kill();
				client.switchGui(new GuiScreenLost("Host quit the game!"));
			}
			else if (e.id == NetworkID.SERVER_PREPARE)
			{
				client.switchGui(new GuiScreenPrepare(hosting));
			}
		}
		
		public function updatePlayerList(playerString:String):void
		{
			
		}
		
		override public function destroy():void
		{
			client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			client.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		public function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				chatbox.send();
			}
		}
	}
}