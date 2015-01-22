﻿package {	import flash.errors.*;	import flash.events.*;	import flash.net.*;	import flash.utils.*;	import flash.xml.*;	public class mySocket extends EventDispatcher {		private var xmlSocket:XMLSocket;		private var socket:Socket;		private var host:String;		private var port:int;		private var reconnectInterval:int;		public static var DATA_COMPLETE:String="DATA_COMPLETE";		private var incomingMsg:String = "";						public var socketName:String;		public var socketValue:int;		public function mySocket(_host:String,_port:int):void {			host=_host;			port=_port;			this.xmlSocket=new XMLSocket  ;			try {				this.xmlSocket.connect(host,port);			} catch (error:Error) {			}			configureListener(this.xmlSocket);		}		private function configureListener(dispatcher:IEventDispatcher):void {			dispatcher.addEventListener(Event.CLOSE,closeHandler);			dispatcher.addEventListener(Event.CONNECT,connectHandler);			dispatcher.addEventListener(DataEvent.DATA,dataHandler);			dispatcher.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);			dispatcher.addEventListener(ProgressEvent.PROGRESS,progressHandler);			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);			/*dispatcher.addEventListener(Event.CONNECT,connectHandler);			dispatcher.addEventListener(Event.CLOSE,closeHandler);			dispatcher.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);			dispatcher.addEventListener(ProgressEvent.SOCKET_DATA,dataHandler);*/		}		private function connectHandler(e:Event):void {			trace("Connect : "+e);		}		private function closeHandler(e:Event):void {			trace("Close : "+e);			reconnectInterval=setInterval(reconnectHandler,1000);		}		private function ioErrorHandler(e:IOErrorEvent):void {			trace("IOError : "+e);			reconnectInterval=setInterval(reconnectHandler,1000);		}		private function securityErrorHandler(e:SecurityErrorEvent):void {			trace("SecurityError : "+e);		}		private function dataHandler(event:DataEvent):void {			trace("dataHandler: "+event.data);			// parse out the packet information			var xml:XMLDocument = new XMLDocument(event.data);									var e:XMLNode=xml.firstChild;			if (e!=null&&e.nodeName=="OSCPACKET") {				var packet:OSCPacket=new OSCPacket(e.attributes.address,e.attributes.port,e.attributes.time,xml);				displayPacketHeaders(packet);				parseMessages(xml);			}			//dispatchEvent(new Event(event.target.DATA_COMPLETE,true));		}		// *** display text information about an OSCPacket object		private function displayPacketHeaders(packet):void {			trace("** OSC Packet from "+packet.address+", port "+packet.port+" for time "+packet.time);			trace(packet.xmlData);		}		// *** parse the messages from some XML-encoded OSC packet		//		//     THIS IS WHERE YOU COULD DO SOMETHING COOL		//     (probably based on the value of the arguments)				private function parseMessages(node:XMLNode):void {			if (node.nodeName=="MESSAGE") {				trace("Message name: "+node.attributes.NAME);				// loop over the arguments of the message				for (var child=node.firstChild; child!=null; child=child.nextSibling) {					if (child.nodeName=="ARGUMENT") {						trace("Arg type " + child.attributes.TYPE + ", value " + child.attributes.VALUE);												socketName = node.attributes.NAME;						socketValue = int(child.attributes.VALUE);												dispatchEvent(new Event(Event.COMPLETE));					}				}			} else {// look recursively for a message node				for (child=node.firstChild; child!=null; child=child.nextSibling) {					parseMessages(child);				}			}		}		private function reconnectHandler():void {			trace("reconnectHandler");			clearInterval(reconnectInterval);			try {				this.xmlSocket.connect(host,port);			} catch (error:Error) {			}		}		private function progressHandler(event:ProgressEvent):void {			trace("progressHandler loaded:"+event.bytesLoaded+" total: "+event.bytesTotal);		}		public function sendMessage(name:String,arg:String="",destAddr:String="",destPort:int=0):void {			if (destAddr=="") {				destAddr=host;			}			if (destPort==0) {				destPort=port;			}			//trace("send message to flash server : "+name);			try {				var xmlOut:XMLDocument=new XMLDocument  ;				var osc:XMLNode=xmlOut.createElement("OSCPACKET");				osc.attributes.TIME=0;				osc.attributes.PORT=destPort;				osc.attributes.ADDRESS=destAddr;				var message:XMLNode=xmlOut.createElement("MESSAGE");				message.attributes.NAME=name;				var argument:XMLNode=xmlOut.createElement("ARGUMENT");				// NOTE : the server expects all strings to be encoded				// with the escape function.				var argInt=parseInt(arg);				if (isNaN(argInt)) {					argument.attributes.VALUE=escape(arg);					argument.attributes.TYPE="s";				} else {					argument.attributes.VALUE=parseInt(arg);					argument.attributes.TYPE="i";				}				// NOTE : to send more than one argument, just create				// more elements and appendChild them to the message.				// the same goes for multiple messages in a packet.				message.appendChild(argument);				osc.appendChild(message);				xmlOut.appendChild(osc);				if (xmlSocket&&xmlSocket.connected) {					xmlSocket.send(xmlOut);					trace("xml: "+xmlOut.toString());				}			} catch (error:Error) {				trace("send msg error!");			}		}		public function getIncomingMsg():String {			return incomingMsg;		}	}}