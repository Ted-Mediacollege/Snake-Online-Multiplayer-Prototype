package nl.teddevos.snakemp.client.world 
{
	import nl.teddevos.snakemp.common.PlayerColor;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.client.gui.components.GuiText;
	
	public class Player 
	{
		public var playerID:int;
		public var color:uint;
		
		public var posX:int;
		public var posY:int;
		public var posD:int;
		public var extra:int;
		
		public var parts:Vector.<SnakePart>;
		
		public var playerText:GuiText;
		
		private var lastFrame:int;
		
		public function Player(id:int, n:String, x:int, y:int, d:int, l:int) 
		{
			playerID = id;
			color = PlayerColor.getColorForPlayer(id);
			
			posX = x;
			posY = y;
			posD = d;
			extra = 0;
			
			playerText = new GuiText(0, 0, 15, 0x000000, "left");
			playerText.setText(n);
			
			parts = new Vector.<SnakePart>();
			for (var i:int = 0; i < l; i++ )
			{
				parts.push(new SnakePart(posD == 1 ? posX - i : posD == 3 ? posX + i : posX, posD == 0 ? posY + i : posD == 2 ? posY - i : posY, posD));
			}
			
			lastFrame = 0;
		}
		
		//CLIENT PLAYER OVERRIDES THIS MAKE SURE TO UPDATE
		public function moveForward():void
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
		}
		
		public function isColliding(x:int, y:int):int
		{
			var l:int = parts.length;
			for (var i:int = 0; i < l; i++ )
			{
				if (parts[i].posX == x && parts[i].posY == y)
				{
					return i;
				}
			}
			
			return -1;
		}
		
		public function newInfo(f:int, s:String, len:int, ex:int):void
		{
			if (f > lastFrame)
			{
				lastFrame = f;
				parts.splice(0, parts.length);
				extra = ex;
				
				var a:Array = s.split("$");
				var b:Array = String(a[0]).split(";");
				var l:int = a.length;
				
				var cx:int = int(parseInt(b[0]));
				var cy:int = int(parseInt(b[1]));
				var d:int = int(parseInt(b[2]));
				
				posX = cx;
				posY = cy;
				posD = d;

				parts.push(new SnakePart(cx, cy, d));
				
				b = String(a[1]).split(";");
				var nx:int = int(parseInt(b[0]));
				var ny:int = int(parseInt(b[1]));
				var nd:int = int(parseInt(b[2]));
				
				var c:int = 1;
				
				for (var i:int = 0; i < len; i++ )
				{
					if (cx == nx && cy == ny)
					{
						c++;
						if (c >= l)
						{
							break;
						}
						else
						{
							b = String(a[c]).split(";");
							nx = int(parseInt(b[0]));
							ny = int(parseInt(b[1]));
							d = nd;
							nd = int(parseInt(b[2]));
						}
					}
					
					cx += d == 1 ? -1 : d == 3 ? 1 : 0;
					cy += d == 0 ? 1 : d == 2 ? -1 : 0;
					
					parts.push(new SnakePart(cx, cy, d));
				}
				
				var diff:int = Main.client.world.frame - f;
				for (var j:int = 0; j < diff; j++ )
				{
					moveForward();
				}
			}
		}
	}
}