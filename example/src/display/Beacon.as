package display
{
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Beacon extends Sprite
	{
		private var c:Sprite;
		private var _position:Vector3D = new Vector3D();
		private var colour:uint;
		
		public function Beacon(_position:Vector3D) 
		{
			position = _position;
			
			c = new Sprite();
			c.graphics.beginFill(0xFF0000);
			c.graphics.drawCircle(0, 0, 5);
			addChild(c);
		}
		
		public function get position():Vector3D 
		{
			return _position;
		}
		
		public function set position(value:Vector3D):void 
		{
			_position = value;
			this.x = position.x;
			this.y = position.y;
		}
		
		public function clear():void
		{
			this.graphics.clear();
		}
		
		public function setRadius(radius:Number, clear:Boolean = true):void 
		{
			this.position.w = radius;
			
			if (clear) {
				this.graphics.clear();
				colour = 0x0000FF;
				this.graphics.lineStyle(1, 0x000000, 0.2);
				this.graphics.beginFill(colour, 0.05);
				this.graphics.drawCircle(0, 0, radius);
			}
			else {
				colour = 0x000000;
			}
			
		}
	}
}