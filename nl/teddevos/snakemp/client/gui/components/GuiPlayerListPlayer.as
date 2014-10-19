package nl.teddevos.snakemp.client.gui.components 
{
	import flash.display.Sprite;
	import nl.teddevos.snakemp.common.PlayerColor;
	
	public class GuiPlayerListPlayer extends Sprite
	{
		public var playerName:String;
		private var ping:int;
		private var ready:int;
		private var playerID:int;
		
		private var nameText:GuiText;
		private var pingText:GuiText;
		
		public var updated:Boolean;
		
		public function GuiPlayerListPlayer(n:String, i:int, p:int, r:int) 
		{
			playerName = n;
			ping = p;
			playerID = i;
			ready = r;
			updated = true;
			
			nameText = new GuiText(70, 5, 25, 0xFFFFFF, "left");
			nameText.setText(playerID + " - " + playerName);
			addChild(nameText);
			pingText = new GuiText(520, 5, 25, 0xFFFFFF, "left");
			pingText.setText("" + ping + "ms");
			addChild(pingText);
			
			graphics.clear();
			graphics.lineStyle(0, 0x000000);
			graphics.beginFill(0x000000, 1);
			graphics.drawRect(0, 0, 760, 40);
			graphics.beginFill(PlayerColor.getColorForPlayer(playerID));
			graphics.drawRect(5, 5, 60, 30);
			graphics.beginFill(r == 0 ? 0xFF0000 : 0x00FF00);
			graphics.drawRect(650, 5, 30, 30);
		}
		
		public function update(p:int, r:int):void
		{
			ping = p;
			ready = r;
			
			graphics.clear();
			graphics.lineStyle(0, 0x000000);
			graphics.beginFill(0x000000, 1);
			graphics.drawRect(0, 0, 760, 40);
			graphics.beginFill(PlayerColor.getColorForPlayer(playerID));
			graphics.drawRect(5, 5, 60, 30);
			graphics.beginFill(r == 0 ? 0xFF0000 : 0x00FF00);
			graphics.drawRect(650, 5, 30, 30);
			
			pingText.setText("" + ping + "ms");
		}
	}
}