package 
{
	import blaze.math.Intersect;
	import display.Beacon;
	import display.Intersection;
	import display.Receiver;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import com.bit101.components.HUISlider;
	import com.bit101.components.HSlider;
	import com.bit101.components.HRangeSlider;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Main extends Sprite 
	{
		private var beacons:Vector.<Beacon>;
		private var intersections:Vector.<Intersection> = new Vector.<Intersection>();
		private var margin:Point = new Point(150, 150);
		private var receiver:Receiver;
		private var fractionErrors:Vector.<Number> = new <Number>[0,0,0,0];
		private var updateEveryXFramesCount:int = -1;
		private var updateEveryXFrames:int = 1;
		private var averageIntersection:Intersection;
		private var averageIntersectionTarget:Vector3D = new Vector3D();
		private var crossProductSmoothing:int = 5;
		private var signalSmoothing:int = 5;
		private var hUISlider1:HUISlider;
		private var hUISlider2:HUISlider;
		private var hUISlider3:HUISlider;
		
		public function Main():void 
		{
			addEventListener(Event.ADDED_TO_STAGE, OnAdd);
		}
		
		private function OnAdd(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, OnAdd);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			beacons = new Vector.<Beacon>();
			
			createBeacon(new Vector3D(margin.x, margin.y, 0));
			createBeacon(new Vector3D(stage.stageWidth - margin.x, margin.y, 0));
			createBeacon(new Vector3D(stage.stageWidth - margin.x, stage.stageHeight - margin.y, 0));
			createBeacon(new Vector3D(margin.x, stage.stageHeight - margin.y, 0));
			
			createReceiver();
			createIntersections();
			createAverageIntersection();
			
			hUISlider1 = new HUISlider(this, 5, 5, "Signal Error Percent", OnSlider);
			hUISlider1.maximum = 100;
			hUISlider1.value = 0;
			
			hUISlider2 = new HUISlider(this, 5, hUISlider1.y + hUISlider1.height + 5, "Signal Smoothing", OnSignalAveSlider);
			hUISlider2.maximum = 20;
			hUISlider2.value = 5;
			
			hUISlider3 = new HUISlider(this, 5, hUISlider2.y + hUISlider2.height + 5, "CrossSection Smoothing", OnCrossSectionAveSlider);
			hUISlider3.maximum = 20;
			hUISlider3.value = 5;
			
			addEventListener(Event.ENTER_FRAME, Update);
			//stage.addEventListener(MouseEvent.CLICK, OnClick);
		}
		
		private function OnSlider(e:Event):void 
		{
			for (var i:int = 0; i < fractionErrors.length; i++) 
			{
				fractionErrors[i] = hUISlider1.value / 100;
			}
		}
		
		private function OnSignalAveSlider(e:Event):void 
		{
			signalSmoothing = hUISlider2.value;
		}
		
		private function OnCrossSectionAveSlider(e:Event):void 
		{
			crossProductSmoothing = hUISlider3.value;
		}
		
		private function OnClick(e:MouseEvent):void 
		{
			Update(null);
		}
		
		private function createBeacon(v:Vector3D):void 
		{
			var beacon:Beacon = new Beacon(v);
			addChild(beacon);
			beacons.push(beacon);
		}
		
		private function createReceiver():void 
		{
			receiver = new Receiver(new Vector3D(stage.stageWidth / 2, stage.stageHeight / 2, 0), beacons);
			addChild(receiver);
		}
		
		private function createIntersections():void 
		{
			for (var i:int = 0; i < beacons.length; i++) 
			{
				var intersection:Intersection = new Intersection();
				addChild(intersection);
				intersections.push(intersection);
			}
		}
		
		private function createAverageIntersection():void 
		{
			averageIntersection = new Intersection(0xFF00FF, 0.3, 10);
			averageIntersection.x = receiver.x;
			averageIntersection.y = receiver.y;
			addChild(averageIntersection);
		}
		
		private function Update(e:Event):void 
		{
			receiver.x = stage.mouseX;
			receiver.y = stage.mouseY;
			
			setBeaconStrength();
			findCrossProduct();
			
			averageIntersection.x = ((averageIntersection.x * crossProductSmoothing) + averageIntersectionTarget.x) / (crossProductSmoothing+1);
			averageIntersection.y = ((averageIntersection.y * crossProductSmoothing) + averageIntersectionTarget.y) / (crossProductSmoothing + 1);
		}
		
		private function findCrossProduct():void 
		{
			updateEveryXFramesCount++;
			if (updateEveryXFramesCount % updateEveryXFrames != 0) return;
			
			//averageIntersectionTarget = intersect.triangulate(beacons[0].position, beacons[1].position, beacons[2].position);
			//averageIntersectionTarget = intersect.quadulate(beacons[0].position, beacons[1].position, beacons[2].position, beacons[3].position);
			var vec:Vector.<Vector3D> = new Vector.<Vector3D>(beacons.length, true);
			for (var m:int = 0; m < beacons.length; m++) 
			{
				vec[m] = beacons[m].position;
			}
			
			averageIntersectionTarget = Intersect.of(vec);
			
			for (var j:int = 0; j < intersections.length; j++) 
			{
				intersections[j].position = Intersect.intersections[j];
			}
			
			for (var i:int = 0; i < Intersect.intersections.length; i++) 
			{
				var beacon:Beacon = beacons[i];
				beacon.setRadius(Intersect.points[i].w, true);
			}
		}
		
		private function setBeaconStrength():void 
		{
			for (var i:int = 0; i < beacons.length; i++) 
			{
				var difPoint:Vector3D = new Vector3D(beacons[i].x - receiver.x, beacons[i].y - receiver.y);
				var dif:Number = Math.sqrt(Math.pow(difPoint.x, 2) + Math.pow(difPoint.y, 2));
				dif = dif * (1 + (Math.random() * fractionErrors[i]) - (fractionErrors[i] / 2));
				
				var beacon:Beacon = beacons[i];
				
				if (beacon.position.w != 0 && Math.abs(beacon.position.w) < 1000) {
					dif = ((beacon.position.w * signalSmoothing) + dif) / (signalSmoothing+1);
				}
				
				beacon.clear();
				beacon.setRadius(dif);
			}
		}
	}
}