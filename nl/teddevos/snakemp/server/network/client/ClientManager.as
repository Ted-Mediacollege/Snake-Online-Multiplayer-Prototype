package nl.teddevos.snakemp.server.network.client 
{
	import flash.events.DatagramSocketDataEvent;
	import flash.net.DatagramSocket;
	import flash.net.ServerSocket;
	import flash.events.ServerSocketConnectEvent;
	import flash.utils.ByteArray;
	import nl.teddevos.snakemp.common.NetworkID;
	import nl.teddevos.snakemp.server.data.Settings;
	import nl.teddevos.snakemp.common.Port;
	import nl.teddevos.snakemp.server.data.ServerLog;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.server.network.ClientTCPdataEvent;
	
	public class ClientManager 
	{
		public var socketTCP:ServerSocket;
		public var socketUDP_GAME:DatagramSocket;
		public var socketUDP_QUICK:DatagramSocket;
		public var socketUDP_PING:DatagramSocket;
		
		private var updateTimer:int = 5;
		private var countDown:int = 300;
		private var waiting:Boolean = false;
		private var soloTesting:Boolean = false;
		
		public var clients:Vector.<ClientConnection>;
		
		public var LOBBY:Boolean = true;
		public var PREPARE:Boolean = false;
		public var GAME:Boolean = false;
		public var SCORE:Boolean = false;
		
		public function ClientManager() 
		{
			socketTCP = new ServerSocket();
			socketTCP.addEventListener(ServerSocketConnectEvent.CONNECT, onIncommingConnection);
			socketTCP.bind(Port.MAIN_TCP);
			socketTCP.listen();
			ServerLog.addMessage("[NETWORK]: TCP connection is ready!");
			
			socketUDP_GAME = new DatagramSocket();
			socketUDP_GAME.addEventListener(DatagramSocketDataEvent.DATA, onGameData);
			socketUDP_GAME.bind(Port.GAME_UDP_SERVER);
			socketUDP_GAME.receive();
			
			socketUDP_QUICK = new DatagramSocket();
			socketUDP_QUICK.addEventListener(DatagramSocketDataEvent.DATA, onQuickData);
			socketUDP_QUICK.bind(Port.QUICK_UDP_SERVER);
			socketUDP_QUICK.receive();
			
			socketUDP_PING = new DatagramSocket();
			socketUDP_PING.addEventListener(DatagramSocketDataEvent.DATA, onUDPping);
			socketUDP_PING.bind(Port.PING_SERVER);
			socketUDP_PING.receive();
			ServerLog.addMessage("[NETWORK]: UDP connections are ready!");
			
			clients = new Vector.<ClientConnection>();
		}
		
		public function destroy():void
		{
			socketTCP.close();
			socketTCP.removeEventListener(ServerSocketConnectEvent.CONNECT, onIncommingConnection);

			socketUDP_GAME.close();
			socketUDP_GAME.removeEventListener(DatagramSocketDataEvent.DATA, onGameData);
			
			socketUDP_QUICK.close();
			socketUDP_QUICK.removeEventListener(DatagramSocketDataEvent.DATA, onQuickData);
			
			socketUDP_PING.close();
			socketUDP_PING.removeEventListener(DatagramSocketDataEvent.DATA, onUDPping);
			
			for (var i:int = clients.length - 1; i > -1; i-- )
			{
				clients[i].forceClose();
			}
		}

		public function onIncommingConnection(e:ServerSocketConnectEvent):void
		{
			var b:ByteArray = new ByteArray();
			if (!LOBBY)
			{
				b.writeUTF(NetworkID.SERVER_REJECT_PLAYING + "empty");
			}
			else if (clients.length < Settings.MAX_PLAYERS)
			{
				var id:int = getNextAvailibleID();
				b.writeUTF(NetworkID.SERVER_WELCOME + "" + id);
				clients.push(new ClientConnection(e.socket, id));
			}
			else 
			{
				b.writeUTF(NetworkID.SERVER_REJECT_FULL + "empty");
			}
			e.socket.writeBytes(b);
			e.socket.flush();
		}
		
		public function onGameData(e:DatagramSocketDataEvent):void
		{
			var s:String = e.data.readUTF();
			var player:int = parseInt(s.substr(0, 3)) - 100;
			var id:int = parseInt(s.substr(3, 3));
			if (id == NetworkID.KEEP_ALIVE) { return; }
			var message:String = s.substr(6);
			
			
			if (GAME)
			{
				if (id == NetworkID.CLIENT_SNAKE_UPDATE)
				{
					sendGameUDPtoAll(NetworkID.SERVER_SNAKE_UPDATE, player + "#" + message, player);
				}
				else if (id == NetworkID.CLIENT_DEATH_UDP)
				{
					for (var i:int = clients.length - 1; i > -1; i-- )
					{
						if (clients[i].clientID == player)
						{
							sendGameUDPtoAll(NetworkID.SERVER_PLAYER_DEATH_UDP, player + "", player);
							sendTCPtoAll(NetworkID.SERVER_PLAYER_DEATH_TCP, player + "", player);
							clients[i].death = true;
						}
					}
				}
				else if (id == NetworkID.CLIENT_PICKUPREQUEST_UDP)
				{
					Main.server.world.checkPickup(player, message);
				}
			}
		}
		
		public function onQuickData(e:DatagramSocketDataEvent):void
		{
			var s:String = e.data.readUTF();
			var player:int = parseInt(s.substr(0, 3)) - 100;
			var id:int = parseInt(s.substr(3, 3));
			if (id == NetworkID.KEEP_ALIVE) { return; }
			var message:String = s.substr(6);
			
			for (var i:int = clients.length - 1; i > -1; i-- )
			{
				if (clients[i].clientID == player)
				{
					clients[i].onQuickUDPdata(id, message);
				}
			}
		}
		
		public function onUDPping(e:DatagramSocketDataEvent):void
		{
			var clientID:int = e.data.readInt();
			if(clientID < 100)
			{
				var time:Number = e.data.readDouble();
				var l:int = clients.length;
				for (var p:int = 0; p < l; p++ )
				{
					if (clientID == clients[p].clientID)
					{
						clients[p].calculatePing(time);
					}
				}
			}
		}
		
		public function tick():void
		{
			for (var i:int = clients.length - 1; i > -1; i-- )
			{
				if (clients[i] != null)
				{
					if (clients[i].disconnected)
					{
						if ((LOBBY && waiting) || GAME)
						{
							sendGameUDPtoAll(NetworkID.SERVER_PLAYER_DEATH_UDP, clients[i].clientID + "");
							sendTCPtoAll(NetworkID.SERVER_PLAYER_DEATH_TCP, clients[i].clientID + "");
						}
						
						clients[i] = null;
						clients.splice(i, 1);
					}
				}
				else
				{
					if ((LOBBY && waiting) || GAME)
					{
						sendGameUDPtoAll(NetworkID.SERVER_PLAYER_DEATH_UDP, clients[i].clientID + "");
						sendTCPtoAll(NetworkID.SERVER_PLAYER_DEATH_TCP, clients[i].clientID + "");
					}
					
					clients.splice(i, 1);
				}
			}
			
			if (LOBBY)
			{
				var allReady:Boolean = true;
				var rl:int = clients.length;
				if (rl == 0) { allReady = false; }
				for (var j:int = rl - 1; j > -1; j-- )
				{
					if (clients[j].ready == 0)
					{
						allReady = false;
					}
				}
			
				if (allReady)
				{
					if (countDown < 1)
					{
						sendTCPtoAll(NetworkID.SERVER_PREPARE);
						Main.server.startWorld();
						LOBBY = false;
						PREPARE = true;
						updateTimer += 10;
						
						
						if (clients.length < 2)
						{
							soloTesting = true;
						}
					}
					else
					{
						if (countDown % 30 == 0)
						{
							ServerLog.addMessage("The game will start in " + int(countDown / 30) + " seconds!");
						}
					}
					countDown--;
				}
				else
				{
					if (countDown < 300)
					{
						ServerLog.addMessage("Countdown interrupted!");
					}
					countDown = 300;
				}
			
				updateTimer--;
				if (updateTimer < 0)
				{
					var s:String = getPlayerListString();
					var c:String = ServerLog.getServerLogString();
					updateTimer += 15;
					for (var p:int = clients.length - 1; p > -1; p-- )
					{
						if (!clients[p].disconnected)
						{
							sendQuickUDP(clients[p], NetworkID.SERVER_LOBBY_LIST_UPDATE, s);
							sendQuickUDP(clients[p], NetworkID.SERVER_LOBBY_CHAT_SYNC, c);
							clients[p].pingClient(socketUDP_PING);
						}
					}
				}
			}
			else if (PREPARE)
			{
				updateTimer--;
				if (updateTimer < 0)
				{
					updateTimer += 10;
					
					var lg:int = clients.length;
					for (var k:int = 0; k < lg; k++ )
					{
						sendGameUDP(clients[k], NetworkID.SERVER_GAMETIME_UPDATE, Main.server.world.gameTime_current + ";" + int(clients[k].pingAverage / 2));
					}
				}
				
				var loaded:Boolean = true;
				for (var n:int = clients.length - 1; n > -1; n-- )
				{
					if (clients[j].loadReady == 0)
					{
						loaded = false;
					}
				}
				
				if (!waiting)
				{
					waiting = true;
					Main.server.world.startTime = Main.server.world.gameTime_current + 5000;
					var pString:String = "";
					var ml:int = clients.length;
					for (var m:int = 0; m < ml; m++)
					{
						if (m > 0)
						{
							pString += ";";
						}
						pString += clients[m].clientID + "$" + clients[m].posX + "$" + clients[m].posY + "$" + clients[m].posD + "$" + "8";
					}
					Main.server.clientManager.sendTCPtoAll(NetworkID.SERVER_GAMETIME_START, Main.server.world.startTime + ";" + Settings.SPEED + ";" + Settings.size + "#" + pString);
				}
				
				if (Main.server.world.gameTime_current > Main.server.world.startTime)
				{
					PREPARE = false;
					GAME = true;
					Main.server.world.gameTime_current -= Main.server.world.startTime;
					Main.server.world.start();
					countDown = 90;
				}
			}
			else if (GAME)
			{
				if (countDown < 90)
				{
					countDown--;
					//trace(countDown);
					if (countDown < 0)
					{
						LOBBY = true;
						GAME = false;
						PREPARE = false;
						updateTimer = 5;
						countDown = 300;
						waiting = false;
						sendTCPtoAll(NetworkID.SERVER_RETURN);
						Main.server.endWorld();
						ServerLog.addMessage("Round ended!");
					}
				}
				else
				{
					var xl:int = clients.length;
					var alive:int = 0;
					var winName:String = "Nobody";
					for (var x:int = 0; x < xl; x++)
					{
						if (!clients[x].death)
						{
							winName = clients[x].playerName;
							alive += 1;
						}
					}
					
					if (alive < 1 || (!soloTesting && alive < 2))
					{
						ServerLog.addMessage(winName + " won this round!");
						sendTCPtoAll(NetworkID.SERVER_PREPARE_RETURN, winName);
						countDown--;
					}
				}
			}
		}
		
		public function sendGameUDPtoAll(id:int, message:String = "empty", except:int = -1):void
		{
			var l:int = clients.length;
			for (var i:int = 0; i < l; i++ )
			{
				if (clients[i].clientID != except)
				{
					sendGameUDP(clients[i], id, message);
				}
			}
		}
		
		public function sendGameUDP(client:ClientConnection, id:int, message:String = "empty"):void
		{
			var b:ByteArray = new ByteArray();
			b.writeUTF(id + message);
			socketUDP_GAME.send(b, 0, 0, client.remoteAdress, Port.GAME_UDP_CLIENT);
		}
		
		public function sendQuickUDPtoAll(id:int, message:String = "empty", except:int = -1):void
		{
			var l:int = clients.length;
			for (var i:int = 0; i < l; i++ )
			{
				if (clients[i].clientID != except)
				{
					sendQuickUDP(clients[i], id, message);
				}
			}
		}
		
		public function sendQuickUDP(client:ClientConnection, id:int, message:String = "empty"):void
		{
			var b:ByteArray = new ByteArray();
			b.writeUTF(id + message);
			socketUDP_QUICK.send(b, 0, 0, client.remoteAdress, Port.QUICK_UDP_CLIENT);
		}
		
		public function sendTCPtoAll(id:int, message:String = "empty", except:int = -1):void
		{
			var l:int = clients.length;
			for (var i:int = 0; i < l; i++ )
			{
				if (clients[i].clientID != except)
				{
					sendTCP(clients[i], id, message);
				}
			}
		}
		
		public function sendTCP(client:ClientConnection, id:int, message:String = "empty"):void
		{
			client.sendTCP(id, message);
		}
		
		public function getPlayerListString():String
		{
			var l:int = clients.length;
			var s:String = "";
			for (var i:int = 0; i < l; i++ )
			{
				s += clients[i].playerName + ";" + clients[i].clientID + ";" + int(clients[i].pingAverage) + ";" + clients[i].ready;
				if (i < l - 1)
				{
					s += "#";
				}
			}
			return s;
		}
		
		public function getNextAvailibleID():int
		{
			if (clients.length == 0)
			{
				return 0;
			}
			
			for (var id:int = 0; id < 100; id++ )
			{
				var l:int = clients.length;
				for (var p:int = 0; p < l; p++ )
				{
					if (id == clients[p].clientID)
					{
						break;
					}
					if (p == l - 1)
					{
						return id;
					}
				}
			}
			return -1;
		}
	}
}