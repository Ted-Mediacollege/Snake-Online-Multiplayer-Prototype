package nl.teddevos.snakemp.server 
{
	import nl.teddevos.snakemp.server.network.client.ClientManager;
	import nl.teddevos.snakemp.server.network.policy.PolicyManager;
	import nl.teddevos.snakemp.server.data.ServerLog;
	import nl.teddevos.snakemp.server.world.WorldServer;
	
	public class Server 
	{
		private var policyManager:PolicyManager;
		public var clientManager:ClientManager;
		
		public var world:WorldServer;
		public var inWorld:Boolean;
		
		public function Server() 
		{
		}
		
		public function start():void
		{
			ServerLog.init();
			ServerLog.addMessage("[SERVER]: starting server...");
			policyManager = new PolicyManager();
			clientManager = new ClientManager();
		}
		
		public function kill():void
		{
			ServerLog.addMessage("[SERVER]: shutting down server...");
			policyManager.destroy();
			policyManager = null;
			clientManager.destroy();
			clientManager = null;
		}
		
		public function startWorld():void
		{
			inWorld = true;
			world = new WorldServer();
		}
		
		public function endWorld():void
		{
			inWorld = false;
			world = null;
		}
		
		public function tick():void
		{
			clientManager.tick();
			if (inWorld)
			{
				world.tick();
			}
		}
	}
}