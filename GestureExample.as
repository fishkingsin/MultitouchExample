package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.TransformGestureEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import com.greensock.TweenLite;
	import flash.events.KeyboardEvent;
	import flash.display.StageDisplayState;
	[SWF(width=1024, height=768, frameRate=60, backgroundColor=0x000000)]
	public class GestureExample extends Sprite
	{
		[Embed(source="african_elephant.jpg")]
		public var ElephantImage:Class;
		[Embed(source="sunset_landscape.jpg")]
		public var sunsetLandscapeImage:Class;
		[Embed(source="lake.jpg")]
		public var lakeImage:Class;
		
		
		public var scaleDebug:TextField;
		public var rotateDebug:TextField;
		
		private var socket:mySocket;
		private var port:int=3000;
			private var host:String = "10.0.1.14";
		public function GestureExample()
		{
			// Debug
			var tf:TextFormat = new TextFormat();
			tf.color = 0xffffff;
			tf.font = "Helvetica";
			tf.size = 11;
			this.scaleDebug = new TextField();
			this.scaleDebug.width = 310;
			this.scaleDebug.defaultTextFormat = tf;
			this.scaleDebug.x = 2;
			this.scaleDebug.y = 2;
			this.stage.addChild(this.scaleDebug);
			this.rotateDebug = new TextField();
			this.rotateDebug.width = 310;
			this.rotateDebug.defaultTextFormat = tf;
			this.rotateDebug.x = 2;
			this.rotateDebug.y = 15;
			this.stage.addChild(this.rotateDebug);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);

			socket = new mySocket(host, port);
				socket.addEventListener(Event.COMPLETE, socketHandler);
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			
		}
		public function socketHandler(e:Event) {
			var name:String = socket.socketName;
			var value:int = socket.socketValue;
			trace(name + ":" + value);
			switch(name) {
				case '/fire':
					createPhotoObject(value);
				break;
			}
		}
		function startMove(evt:MouseEvent):void {
			evt.target.startDrag();
		}
		
		 
		function stopMove(e:MouseEvent):void {
			e.target.stopDrag();
		}
		private function onZoom(e:TransformGestureEvent):void
		{
			this.scaleDebug.text = (e.scaleX + ", " + e.scaleY);
			var elephant:Sprite = e.target as Sprite;
			
			elephant.scaleX *= e.scaleX;
			elephant.scaleY *= e.scaleY;
		}
		
		private function onRotate(e:TransformGestureEvent):void
		{
			var elephant:Sprite = e.target as Sprite;
			this.rotateDebug.text = String(e.rotation);
			elephant.rotation += e.rotation;
		}
		private function keyDown(e:KeyboardEvent):void
		{
			trace(e.charCode);
			switch(e.charCode)
			{
				case 102:
				if(stage.displayState == StageDisplayState.NORMAL)
				{
					stage.displayState = StageDisplayState.FULL_SCREEN; 
				}
				else
				{
					stage.displayState = StageDisplayState.NORMAL; 
				}
				break;
				case 98:
				{
					var r:int = randomRange(0,2);
					createPhotoObject(r);
				}
					break;
				
			}
			//createPhotoObject();
		}
		private function createPhotoObject( i:int):void
		{
			
			var bitmap:Bitmap ;
			
			switch(i)
			{
				case 0:
					bitmap = new ElephantImage();
				break;
				case 1:
					bitmap = new sunsetLandscapeImage();
					break;
				case 2:
					bitmap = new lakeImage();
					break;
			}
			var sprite:Sprite = new Sprite();
			sprite.addChild(bitmap);
			
			sprite.x = 512;
			sprite.y = 1400;
			TweenLite.to(sprite, 1, {x:randomRange((stage.width*0.5)-10,(stage.width*0.5)+10),y:randomRange((stage.height*0.5)-10,(stage.height*0.5)+10)});
			
			bitmap.x = (300 - (bitmap.bitmapData.width / 2)) * -1;
			bitmap.y = (400 - (bitmap.bitmapData.height / 2)) *-1;
			sprite.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			sprite.addEventListener(TransformGestureEvent.GESTURE_ROTATE, onRotate);
			sprite.addEventListener(MouseEvent.MOUSE_DOWN, startMove);			 
			sprite.addEventListener(MouseEvent.MOUSE_UP, stopMove);
			this.addChild(sprite);
		}
		function randomRange(minNum:Number, maxNum:Number):Number 
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
	}
}