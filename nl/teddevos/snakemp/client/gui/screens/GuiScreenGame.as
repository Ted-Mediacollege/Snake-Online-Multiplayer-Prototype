package nl.teddevos.snakemp.client.gui.screens 
{
	import nl.teddevos.snakemp.client.gui.GuiScreen;
	import nl.teddevos.snakemp.client.gui.components.GuiButton;
	import nl.teddevos.snakemp.client.gui.components.GuiText;

	public class GuiScreenGame extends GuiScreen
	{
		public function GuiScreenGame() 
		{
			
		}
		
		override public function init():void 
		{ 
			addChild(client.world);
			
			var title:GuiText = new GuiText(400, 200, 35, 0x000000, "center");
			title.setText("Ik ben een koel spel doei");
			addChild(title);
		}
		
		override public function tick():void 
		{ 
		}
		
		override public function action(b:GuiButton):void 
		{ 
		}
		
		override public function destroy():void 
		{ 
		}
	}
}