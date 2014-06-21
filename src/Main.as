package 
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Main extends Sprite 
	{
		private var beacons:Vector.<Beacon>;
		private var intersections:Vector.<Intersection> = new Vector.<Intersection>();
		private var margin:Point = new Point(350, 250);
		private var receiver:Receiver;
		private var fractionErrors:Vector.<Number> = new <Number>[0.2,0.2,0.2,0.9];
		private var count:int = -1;
		private var t:int = 10;
		private var averageIntersection:Intersection;
		private var averageIntersectionTarget:Vector3D = new Vector3D();
		private var crossProductSmoothing:int = 10;
		private var signalSmoothing:int = 10;
		private var intersect:Intersect;
		
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
			
			intersect = new Intersect();
			
			createReceiver();
			createIntersections();
			createAverageIntersection();
			
			
			addEventListener(Event.ENTER_FRAME, Update);
			//stage.addEventListener(MouseEvent.CLICK, OnClick);
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
			count++;
			
			if (count % t != 0) return;
			
			//averageIntersectionTarget = intersect.triangulate(beacons[0].position, beacons[1].position, beacons[2].position);
			//averageIntersectionTarget = intersect.quadulate(beacons[0].position, beacons[1].position, beacons[2].position, beacons[3].position);
			var vec1:Vector.<Vector3D> = new Vector.<Vector3D>(beacons.length, true);
			for (var m:int = 0; m < beacons.length; m++) 
			{
				vec1[m] = beacons[m].position;
			}
			
			averageIntersectionTarget = intersect.of(vec1);
			
			for (var j:int = 0; j < intersections.length; j++) 
			{
				intersections[j].position = intersect.intersections[j].position;
			}
			/*intersections[0].position = intersect.intersections[0].position;
			intersections[1].position = intersect.intersections[1].position;
			intersections[2].position = intersect.intersections[2].position;*/
			
			for (var i:int = 0; i < intersect.intersections.length; i++) 
			{
				var beacon:Beacon = beacons[i];
				//beacon.clear();
				beacon.setRadius(intersect.points[i].w, true);
			}
		}
		
		private function setBeaconStrength():void 
		{
			for (var i:int = 0; i < beacons.length; i++) 
			{
				var difPoint:Vector3D = new Vector3D(beacons[i].x - receiver.x, beacons[i].y - receiver.y);
				var dif:Number = Math.sqrt(Math.pow(difPoint.x, 2) + Math.pow(difPoint.y, 2));
				dif = dif * (1 + (Math.random() * fractionErrors[i]) - (fractionErrors[i] / 2));
				//dif *= 1.05;
				
				
				
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