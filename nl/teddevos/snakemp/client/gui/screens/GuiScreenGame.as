package nl.teddevos.snakemp.client.gui.screens 
{
	import nl.teddevos.snakemp.client.gui.GuiScreen;
	import nl.teddevos.snakemp.client.gui.components.GuiButton;
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.client.network.ServerTCPdataEvent;
	import nl.teddevos.snakemp.common.NetworkID;

	public class GuiScreenGame extends GuiScreen
	{
		public var title:GuiText;
		
		public function GuiScreenGame() 
		{
			
		}
		
		override public function init():void 
		{ 
			addChild(client.world);
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			
			title = new GuiText(10, 10, 80, 0xBBBBBB, "left");
			title.setText("" + int(Main.client.world.gameTime / Main.client.world.speed));
			addChild(title);
		}
		
		override public function tick():void 
		{ 
			title.setText("" + int(Main.client.world.gameTime / Main.client.world.speed));
		}
		
		override public function action(b:GuiButton):void 
		{ 
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.SERVER_RETURN)
			{
				client.switchGui(new GuiScreenLobby(Main.serverHosting, ""));
			}
			else if (e.id == NetworkID.SERVER_PREPARE_RETURN)
			{
				var ending:GuiText = new GuiText(400, 400, 45, 0x333333, "center");
				ending.setText(e.data + " won this round!");
				addChild(ending);
			}
		}
		
		override public function destroy():void 
		{ 
			removeChild(client.world);
			client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			client.world.destroy();
		}
	}
}