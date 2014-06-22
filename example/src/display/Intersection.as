package display
{
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Intersection extends Sprite 
	{
		private var _position:Vector3D = new Vector3D();
		
		public function Intersection(colour:uint=0x0000FF, alpha:Number=0.2, size:int=5) 
		{
			super();
			
			this.graphics.beginFill(colour, alpha);
			this.graphics.drawCircle(0, 0, size);
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
	}

}