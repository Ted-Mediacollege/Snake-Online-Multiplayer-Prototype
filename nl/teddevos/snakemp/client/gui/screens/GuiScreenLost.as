package nl.teddevos.snakemp.client.gui.screens 
{
	import nl.teddevos.snakemp.client.gui.GuiScreen;
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	import nl.teddevos.snakemp.client.gui.components.GuiButton;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.client.network.Connection;
	
	public class GuiScreenLost extends GuiScreen
	{
		private var connectText:GuiText;
		private var reason:String;
		
		public function GuiScreenLost(r:String) 
		{
			reason = r;
		}
		
		override public function init():void
		{
			connectText = new GuiText(400, 295, 20, 0x000000, "center");
			connectText.setText(reason);
			addChild(connectText);

			var button_menu:GuiButton = new GuiButton(0, 275, 650, 50, 250, 0x555555);
			button_menu.setText("Back to menu", 35, 0xFFFFFF);
			buttonList.push(button_menu);
			addChild(button_menu);
		}
		
		override public function tick():void 
		{ 
		}
		
		override public function action(b:GuiButton):void 
		{ 
			if (b.id == 0)
			{
				client.switchGui(new GuiScreenMenu());
			}
		}
	}
}