package nl.teddevos.snakemp.client.network 
{
	import flash.net.DatagramSocket;
	import flash.events.DatagramSocketDataEvent;
	import flash.utils.ByteArray;
	import nl.teddevos.snakemp.common.Port;
	
	public class PingResponder 
	{
		public var socketUDP:DatagramSocket;
		private var delay:int;
		private var spamIP:String;
		
		public function PingResponder() 
		{
			socketUDP = new DatagramSocket();
			socketUDP.addEventListener(DatagramSocketDataEvent.DATA, onUDPdata);
			socketUDP.bind(Port.PING_CLIENT);
			socketUDP.receive();
		}
		
		public function onUDPdata(e:DatagramSocketDataEvent):void
		{
			socketUDP.send(e.data, 0, 0, e.srcAddress, Port.PING_SERVER);
		}
		
		public function startPing(ip:String):void
		{
			spamIP = ip;
			delay = -1;
			tick();
		}
		
		public function endPing():void
		{
			
		}
		
		public function tick():void
		{
			delay--;
			if (delay < 0)
			{
				delay = 15;
				var b:ByteArray = new ByteArray();
				b.writeInt(999);
				socketUDP.send(b, 0, 0, spamIP, Port.PING_SERVER);
			}
		}
	}
}