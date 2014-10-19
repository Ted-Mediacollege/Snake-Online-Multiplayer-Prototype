package nl.teddevos.snakemp.server.network.client 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.DatagramSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import nl.teddevos.snakemp.Main;
	import nl.teddevos.snakemp.server.network.ClientTCPdataEvent;
	import nl.teddevos.snakemp.common.NetworkID;
	import nl.teddevos.snakemp.common.Port;
	import nl.teddevos.snakemp.server.data.ServerLog;
	import nl.teddevos.snakemp.server.data.CMDexecute;
	
	public class ClientConnection 
	{
		public var socket:Socket;
		public var remoteAdress:String;
		public var disconnected:Boolean;
		public var clientID:int;
		
		public var playerName:String = "player";
		public var ping:int = 0;
		public var pingAverage:Number = 0;
		
		public var ready:int = 0;
		public var loadReady:Boolean = false;
		
		public var muted:Boolean = false;
		
		public var posX:int;
		public var posY:int;
		public var posD:int;
		public var death:Boolean;
		
		public function ClientConnection(s:Socket, id:int) 
		{
			socket = s;
			socket.addEventListener(Event.CLOSE, onClientLost);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onNetworkError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onRecieveData);
			socket.timeout = 2000;
			pingAverage = 0;
			ping = 0;
			
			clientID = id;
			
			remoteAdress = socket.remoteAddress;
			disconnected = false;
		}
		
		public function forceClose():void
		{
			socket.removeEventListener(Event.CLOSE, onClientLost);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, onNetworkError);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, onRecieveData);
			socket.close();
			disconnected = true;
		}
		
		public function onClientLost(e:Event):void
		{
			ServerLog.addMessage(playerName + " disconnected");
			disconnected = true;
		}
		
		public function onNetworkError(e:IOErrorEvent):void
		{
			ServerLog.addMessage(playerName + " disconnected");
			socket.close();
			disconnected = true;
		}
		
		public function onRecieveData(e:ProgressEvent):void
		{
			var s:String = socket.readUTF();
			var id:int = parseInt(s.substr(0, 3));
			if (id == NetworkID.KEEP_ALIVE) { return; }
			var message:String = s.substr(3);
			Main.client.dispatchEvent(new ClientTCPdataEvent(ClientTCPdataEvent.DATA, clientID, id, message));
			
			if (id == NetworkID.CLIENT_INFO_UPDATE)
			{
				var accepted:Boolean = true;
				var l:int = Main.server.clientManager.clients.length;
				
				for (var i:int = 0; i < l; i++)
				{
					if (Main.server.clientManager.clients[i].playerName == message)
					{
						accepted = false;
					}
				}
				
				if (accepted)
				{
					playerName = message;
					sendTCP(NetworkID.SERVER_ACCEPT, Main.server.clientManager.getPlayerListString());
					ServerLog.addMessage(playerName + " joined the game!");
				}
				else
				{
					sendTCP(NetworkID.SERVER_REJECT_NAME, "name");
				}
			}
			else if (id == NetworkID.CLIENT_GAMETIME_MATCH)
			{
				loadReady = true;
			}
			else if (id == NetworkID.CLIENT_DEATH_TCP)
			{
				if (!death)
				{
					Main.server.clientManager.sendGameUDPtoAll(NetworkID.SERVER_PLAYER_DEATH_UDP, clientID + "", clientID);
					Main.server.clientManager.sendTCPtoAll(NetworkID.SERVER_PLAYER_DEATH_TCP, clientID + "", clientID);
					death = true;
				}
			}
			else if (id == NetworkID.CLIENT_PICKUPREQUEST_TCP)
			{
				Main.server.world.checkPickup(clientID, message);
			}
		}
		
		public function onQuickUDPdata(id:int, message:String):void
		{
			if (id == NetworkID.CLIENT_LOBBY_CHAT_NEW && !muted)
			{
				ServerLog.addMessage(playerName + ": " + message);
			}
			else if (id == NetworkID.CLIENT_HOST_CMD && clientID == 0)
			{
				CMDexecute.Execute(message);
			}
			else if (id == NetworkID.CLIENT_INFO_READY)
			{
				ready = parseInt(message);
			}
			else
			{
				Main.client.dispatchEvent(new ClientTCPdataEvent(ClientTCPdataEvent.DATA, clientID, id, message));
			}
		}
		
		public function onGameUDPdata(id:int, message:String):void
		{
		}
		
		public function sendTCP(id:int, message:String):void
		{
			if (!disconnected)
			{
				var b:ByteArray = new ByteArray();
				b.writeUTF(id + message);
				socket.writeBytes(b);
				socket.flush();
			}
		}
		
		public function pingClient(pingSocket:DatagramSocket):void
		{
			var d:Date = new Date();
			var b:ByteArray = new ByteArray();
			b.writeInt(clientID);
			b.writeDouble(d.time);
			pingSocket.send(b, 0, 0, remoteAdress, Port.PING_CLIENT);
		}
		
		public function calculatePing(pingStart:Number):void
		{
			var d:Date = new Date();
			var p:int = d.time - pingStart;
			
			if (p > 0 && pingStart > 0)
			{
				ping = p;
				if (pingAverage == 0)
				{
					pingAverage = ping;
				}
				else
				{
					pingAverage = (pingAverage * 9 + ping) / 10;
				}
			}
		}
		
		public function resetVariables():void
		{
			ready = 0;
			loadReady = false;
			
			posX = 0;
			posY = 0;
			posD = 0;
			death = false;
			
			trace("RESET");
		}
	}
}