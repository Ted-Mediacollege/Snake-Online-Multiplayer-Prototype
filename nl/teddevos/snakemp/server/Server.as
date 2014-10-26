package nl.teddevos.snakemp.server 
{
	import flash.net.NetworkInterface;
	import nl.teddevos.snakemp.server.network.client.ClientManager;
	import nl.teddevos.snakemp.server.network.policy.PolicyManager;
	import nl.teddevos.snakemp.server.data.ServerLog;
	import nl.teddevos.snakemp.server.world.WorldServer;
	import nl.teddevos.snakemp.server.network.serverlist.ServerListUpdater;
	
	public class Server 
	{
		private var policyManager:PolicyManager;
		public var clientManager:ClientManager;
		
		public var world:WorldServer;
		public var inWorld:Boolean;
		
		public var lastServerListUpdate:int;
		
		public var serverName:String = "Server Name";
		public var localIP:String = "127.0.0.1";
		public var localIPfound:Boolean = false;
		
		public function Server(s:String) 
		{
			serverName = s;
		}
		
		public function start():void
		{
			ServerLog.init();
			ServerLog.addMessage("[SERVER]: starting server...");
			localIPfound = false;
			policyManager = new PolicyManager();
			clientManager = new ClientManager();
			lastServerListUpdate = -99;
		}
		
		public function kill():void
		{
			ServerLog.addMessage("[SERVER]: shutting down server...");
			policyManager.destroy();
			policyManager = null;
			clientManager.destroy();
			clientManager = null;
			endWorld();
		}
		
		public function startWorld():void
		{
			inWorld = true;
			world = new WorldServer();
		}
		
		public function endWorld():void
		{
			if (inWorld)
			{
				inWorld = false;
				world.end();
				world = null;
			}
		}
		
		public function tick():void
		{
			clientManager.tick();
			if (inWorld)
			{
				world.tick();
			}
			
			if (localIPfound)
			{
				var d:Date = new Date();
				if (int(d.getMinutes()) != lastServerListUpdate)
				{
					if (lastServerListUpdate == -99)
					{
						ServerLog.addMessage("[SERVER]: Sending message to main server.");
					}
					lastServerListUpdate = int(d.getMinutes());
					
					ServerListUpdater.update();
				}
			}
		}
	}
}