package nl.teddevos.snakemp.client.gui.components 
{
	import flash.display.Sprite;
	import nl.teddevos.snakemp.server.data.Settings;
	
	public class GuiPlayerList extends Sprite
	{
		private var playerList:Vector.<GuiPlayerListPlayer>;
		
		public function GuiPlayerList() 
		{
			playerList = new Vector.<GuiPlayerListPlayer>();
			
			var text_name:GuiText = new GuiText(0, 0, 20, 0x000000, "left");
			var text_ping:GuiText = new GuiText(520, 0, 20, 0x000000, "left");
			var text_ready:GuiText = new GuiText(630, 0, 20, 0x000000, "left");
			
			text_name.setText("PLAYER");
			text_ping.setText("PING");
			text_ready.setText("READY");
			
			addChild(text_name);
			addChild(text_ping);
			addChild(text_ready);
		}
		
		public function update(list:String):void
		{
			var a:Array = list.split("#");
			var l:int = 0;
			var al:int = a.length;
			var sortAgain:Boolean = false;
			
			l = playerList.length;
			if (l == 0)
			{
				for (var ai2:int = 0; ai2 < al; ai2++)
				{
					var info3:Array = a[ai2].split(";");
					var plp2:GuiPlayerListPlayer = new GuiPlayerListPlayer(info3[0], parseInt(info3[1]), parseInt(info3[2]), parseInt(info3[3]));
					playerList.push(plp2);
					addChild(plp2);
					sortAgain = true;
				}
			}
			else
			{
				for (var ai:int = 0; ai < al; ai++)
				{
					l = playerList.length;
					for (var pi:int = 0; pi < l; pi++)
					{
						var info:Array = a[ai].split(";");
						if (info[0] == playerList[pi].playerName)
						{
							playerList[pi].update(parseInt(info[2]), parseInt(info[3]));
							playerList[pi].updated = true;
							break;
						}
						
						if (pi == l - 1)
						{
							var info2:Array = a[ai].split(";");
							var plp:GuiPlayerListPlayer = new GuiPlayerListPlayer(info2[0], parseInt(info2[1]), parseInt(info2[2]), parseInt(info2[3]));
							playerList.push(plp);
							addChild(plp);
							sortAgain = true;
						}
					}
				}
			}
			
			l = playerList.length;
			for (var pi2:int = l - 1; pi2 > -1; pi2--)
			{
				if (playerList[pi2].updated == false)
				{
					removeChild(playerList[pi2]);
					playerList.splice(pi2, 1);
					sortAgain = true;
				}
				else
				{
					playerList[pi2].updated = false;
				}
			}
			
			if (sortAgain)
			{
				l = playerList.length;
				for (var pi3:int = 0; pi3 < l; pi3++)
				{
					playerList[pi3].y = 30 + (pi3 * 45);
				}
			}
			
			l = playerList.length;
			graphics.clear();
			for (var ov:int = l; ov < Settings.MAX_PLAYERS; ov++ )
			{
				graphics.lineStyle(0, 0x777777);
				graphics.beginFill(0x777777, 1);
				graphics.drawRect(0, 30 + (ov * 45), 760, 40);
			}
		}
	}
}