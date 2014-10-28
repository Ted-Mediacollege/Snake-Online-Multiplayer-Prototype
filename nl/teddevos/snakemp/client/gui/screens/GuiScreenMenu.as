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
			var title:GuiText = new GuiText(400, 80, 55, 0x000000, "center");
			title.setText("Snake MP");
			addChild(title);
			
			var version:GuiText = new GuiText(730, 770, 15, 0x000000, "center");
			version.setText("Version 1.2 final");
			addChild(version);
			
			var info:GuiText = new GuiText(400, 150, 15, 0x000000, "center");
			info.setText("Multiplayer ports: 843, 2020-2030 UDP and TCP");
			addChild(info);
			
			var button_host:GuiButton = new GuiButton(0, 275, 250, 50, 250, 0x555555);
			button_host.setText("Host Game", 35, 0xFFFFFF);
			buttonList.push(button_host);
			addChild(button_host);
			
			var button_list:GuiButton = new GuiButton(2, 275, 335, 50, 250, 0x555555);
			button_list.setText("Join Game", 35, 0xFFFFFF);
			buttonList.push(button_list);
			addChild(button_list);
			
			var button_join:GuiButton = new GuiButton(1, 275, 415, 50, 250, 0x555555);
			button_join.setText("Direct Connect", 35, 0xFFFFFF);
			buttonList.push(button_join);
			addChild(button_join);
			
			var help:GuiText = new GuiText(271, 535, 22, 0x000000, "left");
			help.setText("player name:");
			addChild(help);
			
			graphics.lineStyle(3, 0x000000);
			graphics.drawRect(275, 565, 250, 40);
			
			inputField = new GuiTextInput(280, 565, 30, 0x000000, "left", 15, "a-zA-Z0-9_ ");
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
				inputField.tf.text = "guy12345";
			}
			SaveData.playerName = inputField.tf.text;
			
			if (b.id == 0)
			{
				client.switchGui(new GuiScreenJoinHosting());
			}
			else if (b.id == 1)
			{
				client.switchGui(new GuiScreenJoinInput(SaveData.lastIP));
			}
			else if (b.id == 2)
			{
				client.switchGui(new GuiScreenServerList());
			}
		}
	}
}