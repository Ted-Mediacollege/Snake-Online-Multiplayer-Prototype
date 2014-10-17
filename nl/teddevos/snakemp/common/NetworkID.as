package nl.teddevos.snakemp.common 
{
	public class NetworkID 
	{
		public static var KEEP_ALIVE:int = 999;
		
		//============= TCP & QUICK UDP ====================================================================

		//CLIENT -> SERVER
		public static var CLIENT_INFO_UPDATE:int = 100; 		//X - name
		public static var CLIENT_INFO_READY:int = 101;			//X - 0=false 1=true
		public static var CLIENT_LOBBY_CHAT_NEW:int = 102;		//X - message
		public static var CLIENT_HOST_CMD:int = 103;			//X - type;arg1;arg2;arg3...
		
		public static var CLIENT_GAMETIME_MATCH:int = 110;		//X - 
		
		//SERVER -> CLIENT
		public static var SERVER_WELCOME:int = 100;				//X - playerID
		public static var SERVER_REJECT_FULL:int = 101;			//X - 
		public static var SERVER_REJECT_PLAYING:int = 102;		//X - 
		public static var SERVER_REJECT_NAME:int = 103;			//X - 
		public static var SERVER_ACCEPT:int = 104;				//X - player;id;ping;ready#player;id;ping;ready#player;id;ping;ready...
		public static var SERVER_KICK:int = 105;				//X - reason
		public static var SERVER_END:int = 106;					//X -
		
		public static var SERVER_LOBBY_LIST_UPDATE:int = 110;	//X - player;id;ping;ready#player;id;ping;ready#player;id;ping;ready...
		public static var SERVER_LOBBY_CHAT_SYNC:int = 111;		//X - id;message#id;message#id;message...
		
		public static var SERVER_PREPARE:int = 120;				//X - 
		public static var SERVER_GAMETIME_START:int = 121;		//0 - time
		
		//============= GAME UDP ==========================================================================
		
		//CLIENT -> SERVER
		
		//SERVER -> CLIENT
		public static var SERVER_GAMETIME_UPDATE:int = 200;		//X - time(double);ping(half)
	}
}