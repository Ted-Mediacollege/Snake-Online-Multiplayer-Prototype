package nl.teddevos.snakemp.client.world 
{
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.common.NetworkID;
	
	public class ClientPlayer extends Player
	{
		public var oldDir:int;
		public var death:Boolean;
		public var latestGrow:int;
		public var sendDelay:int;
		
		public function ClientPlayer(id:int, n:String, x:int, y:int, d:int, l:int) 
		{
			super(id, n, x, y, d, l);
			oldDir = d;
			death = false;
			latestGrow = 0;
			sendDelay = 60;
		}
		
		override public function moveForward():void
		{
			if (!death)
			{
				posX += posD == 1 ? 1 : posD == 3 ? -1 : 0;
				posY += posD == 0 ? -1 : posD == 2 ? 1 : 0;
				
				parts.unshift(new SnakePart(posX, posY, posD));
					
				if (extra > 0)
				{
					extra--;
				}
				else
				{
					parts.pop();
				}
				
				if (oldDir != posD)
				{
					oldDir = posD;
					sendNewSnakeString(0);
					sendDelay = 60;
				}
				
				sendDelay--;
				if (sendDelay < 0)
				{
					sendNewSnakeString(0);
				}
			}
		}
		
		public function insideCheck():Boolean
		{
			for (var i:int = parts.length - 1; i > 0; i-- )
			{
				if (parts[0].posX == parts[i].posX && parts[0].posY == parts[i].posY)
				{
					return true;
				}
			}
			return false;
		}
		
		public function sendNewSnakeString(forward:int):void
		{
			if (!death)
			{
				var fakeX:int = posX;
				var fakeY:int = posY;
				var fakeD:int = posD;
				var fakeExtra:int = extra;
				
				var fakeParts:Vector.<SnakePart> = parts.concat();
				
				for (var j:int = 0; j < forward; j++)
				{
					fakeX += fakeD == 1 ? 1 : fakeD == 3 ? -1 : 0;
					fakeX += fakeD == 0 ? -1 : fakeD == 2 ? 1 : 0;
					
					fakeParts.unshift(new SnakePart(fakeX, fakeY, fakeD));
					
					if (fakeExtra > 0)
					{
						fakeExtra--;
					}
					else
					{
						fakeParts.pop();
					}
				}
				
				var l:int = fakeParts.length;
				var s:String = "";
				
				for (var i:int = 0; i < l; i++ )
				{
					if (i == 0)
					{
						s += fakeParts[i].posX + ";" + fakeParts[i].posY + ";" + fakeParts[i].posD;
					}
					else if (i == l - 1)
					{
						s += "$" + fakeParts[i].posX + ";" + fakeParts[i].posY + ";" + fakeParts[i].posD;
					}
					else if (parts[i].posD != parts[i - 1].posD)
					{
						s += "$" + fakeParts[i].posX + ";" + fakeParts[i].posY + ";" + fakeParts[i].posD;
					}
				}
				
				Main.client.connection.sendGameUDP(NetworkID.CLIENT_SNAKE_UPDATE, (Main.client.world.frame + forward) + "#" + s + "#" + l + "#" + extra);
			}
		}
		
		override public function newInfo(f:int, s:String, len:int, ex:int):void
		{
		}
	}
}