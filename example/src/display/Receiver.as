package display
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Receiver extends Sprite 
	{
		private var beacons:Vector.<Beacon> = new Vector.<Beacon>();
		private var _position:Vector3D = new Vector3D();
		
		public function Receiver(_position:Vector3D, _beacons:Vector.<Beacon>) 
		{
			position = _position;
			beacons = _beacons;
			this.graphics.lineStyle(1, 0x000000, 0.5);
			this.graphics.beginFill(0x00FF00, 0.2);
			this.graphics.drawCircle(0, 0, 15);
			
			
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