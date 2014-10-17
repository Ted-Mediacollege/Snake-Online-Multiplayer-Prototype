package nl.teddevos.snakemp.client.gui.screens 
{
	import nl.teddevos.snakemp.client.gui.components.GuiButton;
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	import nl.teddevos.snakemp.client.gui.GuiScreen;
	import nl.teddevos.snakemp.client.data.SaveData;
	import nl.teddevos.snakemp.client.gui.components.GuiTextInput;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class GuiScreenMenu extends GuiScreen
	{
		private var inputField:GuiTextInput;
		
		public function GuiScreenMenu() 
		{
		}
		
		override public function init():void
		{
			var title:GuiText = new GuiText(400, 100, 55, 0x000000, "center");
			title.setText("Snake MP");
			addChild(title);
			
			var button_host:GuiButton = new GuiButton(0, 275, 250, 50, 250, 0x555555);
			button_host.setText("Host", 35, 0xFFFFFF);
			buttonList.push(button_host);
			addChild(button_host);
			
			var button_join:GuiButton = new GuiButton(1, 275, 325, 50, 250, 0x555555);
			button_join.setText("Join IP", 35, 0xFFFFFF);
			buttonList.push(button_join);
			addChild(button_join);
			
			var help:GuiText = new GuiText(271, 515, 22, 0x000000, "left");
			help.setText("player name:");
			addChild(help);
			
			graphics.lineStyle(3, 0x000000);
			graphics.drawRect(275, 545, 250, 40);
			
			inputField = new GuiTextInput(280, 545, 30, 0x000000, "left", 15, "a-zA-Z0-9");
			inputField.setText(SaveData.playerName);
			addChild(inputField);
		}
		
		override public function tick():void 
		{ 
		}
		
		override public function action(b:GuiButton):void 
		{ 
			if (inputField.tf.text.length == 0)
			{
				inputField.tf.text = "guy";
			}
			SaveData.playerName = inputField.tf.text;
			
			if (b.id == 0)
			{
				client.switchGui(new GuiScreenJoinHosting());
			}
			if (b.id == 1)
			{
				client.switchGui(new GuiScreenJoinInput(SaveData.lastIP));
			}
		}
	}
}