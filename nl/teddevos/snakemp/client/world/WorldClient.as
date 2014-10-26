package nl.teddevos.snakemp.client.world 
{
	import flash.display.Sprite;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.common.NetworkID;
	import nl.teddevos.snakemp.client.network.ServerTCPdataEvent;
	import nl.teddevos.snakemp.client.network.ServerGameDataEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class WorldClient extends Sprite
	{
		public var gameTimeDifference:int;
		public var gameTime:int;
		private var time_old:int;
		private var time:int;
		private var ticking:Boolean;
		public var playing:Boolean;
		
		public var oldframes:int;
		public var currentframes:int;
		public var frame:int;
		
		public var size:int = 80;
		public var blockSize:int = 10;
		public var speed:int = 500;
		
		public var clientPlayer:ClientPlayer;
		public var players:Vector.<Player>;
		public var dead:Vector.<Player>;
		
		public var death:Boolean = false;
		
		public var nextPickupX:int = -10;
		public var nextPickupY:int = -10;
		public var nextPickupFrame:int;
		
		public var collisionList:Vector.<CollisionCheck>;
		
		public var lowestPing:Number = 100000;
		
		public var backgroundGraphics:Sprite;
		public var snakeGraphics:Sprite;
		public var shadowGraphics:Sprite;
		public var deadGraphics:Sprite;
		
		public function WorldClient() 
		{
			gameTime = 0;
			frame = 0;
			ticking = false;
			playing = false;
			
			players = new Vector.<Player>();
			dead = new Vector.<Player>();
			collisionList = new Vector.<CollisionCheck>();
			
			Main.client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			Main.client.addEventListener(ServerGameDataEvent.DATA, onGameData);
			Main.client.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Main.client.stage.focus = Main.client;
			
			backgroundGraphics = new Sprite();
			snakeGraphics = new Sprite();
			shadowGraphics = new Sprite();
			deadGraphics = new Sprite();
			
			addChild(backgroundGraphics);
			addChild(shadowGraphics);
			addChild(deadGraphics);
			addChild(snakeGraphics);
		}
		
		public function tick():void
		{
			var newFrame:Boolean = false;
			if (ticking)
			{
				var d:Date = new Date();
				time = d.time - time_old;
				time_old = d.time;
				gameTime += time;
				
				var nF:int = int(gameTime / speed);
				if (nF > currentframes && playing)
				{
					newFrame = true;
					currentframes = nF;
					frame = currentframes + oldframes;
				}
			}
			
			if (newFrame)
			{
				if (currentframes == 100)
				{
					oldframes += 100;
					currentframes -= 100;
					frame = currentframes + oldframes;
					gameTime -= 100 * speed;
					if (speed > 50)
					{
						speed -= 3;
					}
				}
			}
			
			if (playing)
			{
				backgroundGraphics.graphics.clear();
				snakeGraphics.graphics.clear();
				shadowGraphics.graphics.clear();
				deadGraphics.graphics.clear();
				
				backgroundGraphics.graphics.lineStyle(2, 0x000000);
				backgroundGraphics.graphics.beginFill(0xFFFFFF);
				backgroundGraphics.graphics.drawRect(0, 0, 800, 800);
				
				var l:int = dead.length;
				for (var de:int = 0; de < l; de++)
				{
					deadGraphics.graphics.lineStyle(1, 0x000000, 0.05);
					deadGraphics.graphics.beginFill(dead[de].color, 0.2);
					var l66:int = dead[de].parts.length
					for (var j3:int = 0; j3 < l66; j3++ )
					{
						deadGraphics.graphics.drawRect(dead[de].parts[j3].posX * blockSize, dead[de].parts[j3].posY * blockSize, blockSize, blockSize);
					}
					deadGraphics.graphics.endFill();
				}
				
				shadowGraphics.graphics.lineStyle(1, 0xBBBBBB);
				shadowGraphics.graphics.beginFill(0xBBBBBB);
				
				snakeGraphics.graphics.lineStyle(1, 0x000000);
				snakeGraphics.graphics.beginFill((Math.random() * 0xFFFFFF) & 0xFFFFFF);
				snakeGraphics.graphics.drawRect(nextPickupX * blockSize, nextPickupY * blockSize, blockSize, blockSize);
				shadowGraphics.graphics.drawRect(nextPickupX * blockSize + 3, nextPickupY * blockSize + 3, blockSize, blockSize);
				
				snakeGraphics.graphics.lineStyle(1, 0x000000);
				
				l = players.length;
				for (var i:int = 0; i < l; i++)
				{
					if (newFrame)
					{
						players[i].moveForward();
					}
					
					if (players[i].posD == 3)
					{
						players[i].playerText.x = (players[i].posX * blockSize) - int(0.3 * blockSize);
						players[i].playerText.y = (players[i].posY * blockSize) + int(0.7 * blockSize);
					}
					else
					{
						players[i].playerText.x = (players[i].posX * blockSize) + int(1 * blockSize);
						players[i].playerText.y = (players[i].posY * blockSize) - int(0.5 * blockSize);
					}
				
					snakeGraphics.graphics.beginFill(players[i].color);
					var l2:int = players[i].parts.length
					for (var j:int = 0; j < l2; j++ )
					{
						snakeGraphics.graphics.drawRect(players[i].parts[j].posX * blockSize, players[i].parts[j].posY * blockSize, blockSize, blockSize);
						shadowGraphics.graphics.drawRect(players[i].parts[j].posX * blockSize + 3, players[i].parts[j].posY * blockSize + 3, blockSize, blockSize);
					}
					snakeGraphics.graphics.endFill();
				}
				
				if (newFrame && !death)
				{
					if (clientPlayer.posX == nextPickupX && clientPlayer.posY == nextPickupY)
					{
						Main.client.connection.sendGameUDP(NetworkID.CLIENT_PICKUPREQUEST_UDP, nextPickupX + ";" + nextPickupY);
						Main.client.connection.sendTCP(NetworkID.CLIENT_PICKUPREQUEST_TCP, nextPickupX + ";" + nextPickupY);
					}
					
					if (clientPlayer.posX < 0 || clientPlayer.posY < 0 || clientPlayer.posX >= size || clientPlayer.posY >= size || clientPlayer.insideCheck())
					{
						death = true;
						clientPlayer.death = true;
						removeChild(clientPlayer.playerText);
						var pl:int = players.length;
						for (var pi:int = 0; pi < pl; pi++ )
						{
							if (players[pi].playerID == clientPlayer.playerID)
							{
								dead.push(players[pi]);
								players.splice(pi, 1);
								break;
							}
						}
						
						Main.client.connection.sendGameUDP(NetworkID.CLIENT_DEATH_UDP);
						Main.client.connection.sendTCP(NetworkID.CLIENT_DEATH_TCP);
					}
					
					var lc:int = collisionList.length;
					l = players.length;
					for (var w:int = 0; w < lc; w++)
					{
						collisionList[w].waitingTime--;
						trace("waiting", collisionList[w].waitingTime);
						if (collisionList[w].waitingTime == 0)
						{
							for (var y:int = 0; y < l; y++)
							{
								if (players[y] != clientPlayer)
								{
									var col:int = players[y].isColliding(collisionList[w].posX, collisionList[w].posY);
									if (col > 5)
									{
										death = true;
										clientPlayer.death = true;
										removeChild(clientPlayer.playerText);
										var pl3:int = players.length;
										for (var pi3:int = 0; pi3 < pl3; pi3++ )
										{
											if (players[pi3].playerID == clientPlayer.playerID)
											{
												dead.push(players[pi3]);
												players.splice(pi3, 1);
												break;
											}
										}
										
										Main.client.connection.sendGameUDP(NetworkID.CLIENT_DEATH_UDP);
										Main.client.connection.sendTCP(NetworkID.CLIENT_DEATH_TCP);
									}
								}
							}
						}
					}
					
					l = players.length;
					for (var m:int = 0; m < l; m++)
					{
						if (players[m] != clientPlayer)
						{
							var col2:int = players[m].isColliding(clientPlayer.posX, clientPlayer.posY);
							if (col2 > 5)
							{
								death = true;
								clientPlayer.death = true;
								var pl2:int = players.length;
								for (var pi2:int = 0; pi2 < pl2; pi2++ )
								{
									if (players[pi2].playerID == clientPlayer.playerID)
									{
										players.splice(pi2, 1);
										break;
									}
								}
								
								Main.client.connection.sendGameUDP(NetworkID.CLIENT_DEATH_UDP);
								Main.client.connection.sendTCP(NetworkID.CLIENT_DEATH_TCP);
							}
							else if (col2 > -1)
							{
								collisionList.push(new CollisionCheck(clientPlayer.posX, clientPlayer.posY, 6 - col2));
							}
						}
					}
				}
			}
		}
		
		public function newGameTime(t:Number, time:Number):void
		{
			var d:Date = new Date();
			var p:Number = Number(d.time - time) / 2.0;
			
			if (!ticking)
			{
				gameTime = t + p;
				ticking = true;
				lowestPing = p;
				gameTimeDifference = p;
				
				time_old = d.time;
			}
			else
			{
				if (p < lowestPing)
				{
					lowestPing = p;
					var diff:Number = gameTime - (t + p);
					gameTimeDifference = int(Math.abs(diff));
					gameTime = t + p;
				}
			}
		}
		
		public function newSnakeUpdate(s:String):void
		{
			var a:Array = s.split("#");
			var l:int = players.length;
			var id:int = int(parseInt(a[0]));
			var f:int = int(parseInt(a[1]));
			var len:int = int(parseInt(a[3]));
			var ex:int = int(parseInt(a[4]));
			
			for (var i:int = 0; i < l; i++)
			{
				if (players[i].playerID == id)
				{
					players[i].newInfo(f, a[2], len, ex);
				}
			}
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.SERVER_GAMETIME_START)
			{
				var a:Array = e.data.split("#");
				var b:Array = String(a[0]).split(";");
				var c:Array = String(a[1]).split(";");
				
				speed = int(parseInt(b[1]));
				size = int(parseInt(b[2]));
				blockSize = int(800 / size);
				
				var l:int = c.length;
				for (var i:int = 0; i < l; i++)
				{
					var d:Array = String(c[i]).split("$");
					var id:int = int(parseInt(d[0]));
					if (id == Main.client.connection.playerID)
					{
						clientPlayer = new ClientPlayer(id, new String(d[1]), int(parseInt(d[2])), int(parseInt(d[3])), int(parseInt(d[4])), int(parseInt(d[5])));
						addChildAt(clientPlayer.playerText, 2);
						players.push(clientPlayer);
					}
					else
					{
						var pla:Player = new Player(id, new String(d[1]), int(parseInt(d[2])), int(parseInt(d[3])), int(parseInt(d[4])), int(parseInt(d[5])));
						addChildAt(pla.playerText, 2);
						players.push(pla);
					}
				}
			}
			else if (e.id == NetworkID.SERVER_PLAYER_DEATH_TCP)
			{
				var deathID:int = int(parseInt(e.data));
				var pl:int = players.length;
				for (var pi:int = 0; pi < pl; pi++ )
				{
					if (players[pi].playerID == deathID)
					{
						if (clientPlayer == players[pi])
						{
							death = true;
							clientPlayer.death = true;
						}
						removeChild(players[pi].playerText);
						dead.push(players[pi]);
						players.splice(pi, 1);
						break;
					}
				}
			}
			else if (e.id == NetworkID.SERVER_NEXT_PICKUP_TCP)
			{
				var q:Array = e.data.split(";");
				var f:int = int(parseInt(q[2]));
				
				if (f > nextPickupFrame)
				{
					nextPickupX = int(parseInt(q[0]));
					nextPickupY = int(parseInt(q[1]));
					nextPickupFrame = f;
				}
			}
			else if (e.id == NetworkID.SERVER_GROW_TCP)
			{
				if (clientPlayer.latestGrow != int(parseInt(e.data)))
				{
					clientPlayer.extra += 5;
				}
			}
		}
		
		public function onKeyDown(e:KeyboardEvent):void
		{
			if (!death)
			{
				if (e.keyCode == Keyboard.UP && clientPlayer.posD != 2 && clientPlayer.oldDir != 2)
				{
					clientPlayer.posD = 0;
				}
				else if (e.keyCode == Keyboard.RIGHT && clientPlayer.posD != 3 && clientPlayer.oldDir != 3)
				{
					clientPlayer.posD = 1;
				}
				else if (e.keyCode == Keyboard.DOWN && clientPlayer.posD != 0 && clientPlayer.oldDir != 0)
				{
					clientPlayer.posD = 2;
				}
				else if (e.keyCode == Keyboard.LEFT && clientPlayer.posD != 1 && clientPlayer.oldDir != 1)
				{
					clientPlayer.posD = 3;
				}
			}
		}
		
		public function onGameData(e:ServerGameDataEvent):void
		{
			if (e.id == NetworkID.SERVER_PLAYER_DEATH_UDP)
			{
				var deathID:int = int(parseInt(e.data));
				var pl:int = players.length;
				for (var pi:int = 0; pi < pl; pi++ )
				{
					if (players[pi].playerID == deathID)
					{
						if (clientPlayer == players[pi])
						{
							death = true;
							clientPlayer.death = true;
						}
						removeChild(players[pi].playerText);
						dead.push(players[pi]);
						players.splice(pi, 1);
						break;
					}
				}
			}
			else if (e.id == NetworkID.SERVER_NEXT_PICKUP_UDP)
			{
				var a:Array = e.data.split(";");
				var f:int = int(parseInt(a[2]));
				
				if (f >= nextPickupFrame)
				{
					nextPickupX = int(parseInt(a[0]));
					nextPickupY = int(parseInt(a[1]));
					nextPickupFrame = f;
				}
			}
			else if (e.id == NetworkID.SERVER_GROW_UDP)
			{
				if (clientPlayer.latestGrow != int(parseInt(e.data)))
				{
					clientPlayer.extra += 5;
					clientPlayer.sendNewSnakeString(0);
				}
			}
		}
		
		public function destroy():void
		{
			Main.client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			Main.client.removeEventListener(ServerGameDataEvent.DATA, onGameData);
			Main.client.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
	}
}