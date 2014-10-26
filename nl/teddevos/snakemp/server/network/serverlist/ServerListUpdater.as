package nl.teddevos.snakemp.server.network.serverlist 
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	import nl.teddevos.snakemp.server.data.ServerLog;
	import nl.teddevos.snakemp.common.PHPdatabase;
	import nl.teddevos.snakemp.Main;
	
	public class ServerListUpdater 
	{
		public static function update():void
		{
			if (Main.serverHosting)
			{
				try 
				{
					var ipLocal:String = Main.server.localIP.replace(new RegExp(/([.]+)/g), "D");
					var serverName:String = Main.server.serverName.replace(new RegExp(/ /g), "_");
					
					var loader:URLLoader = new URLLoader;
					var urlreq:URLRequest = new URLRequest(PHPdatabase.SERVER_SEND + "/?s=1&l=" + ipLocal + "&n=" + serverName);
					var urlvars: URLVariables = new URLVariables;
					loader.dataFormat = URLLoaderDataFormat.TEXT;
					loader.load(urlreq);					
				}
				catch (e:Error)
				{
					trace("[SERVER]: Failed to contact main server.");
				}
			}
		}
	}
}