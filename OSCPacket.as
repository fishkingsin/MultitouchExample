package {
	import flash.xml.*;
	public class OSCPacket {

		var address:String;
			var port:int;
			var time:Number;
			var xmlData:XMLDocument;
		// *** OSCPacket constructor / class definition
		function OSCPacket(address:String,port:int,time:Number,xmlData:XMLDocument) {
			this.address=address;
			this.port=port;
			this.time=time;
			this.xmlData=xmlData;
		}
	}
}