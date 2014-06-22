package blaze.math
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Intersect 
	{
		public var points:Vector.<Vector3D> = new Vector.<Vector3D>();
		public var intersections:Vector.<Vector3D> = new Vector.<Vector3D>();
		private var averageIntersectionTarget:Vector3D = new Vector3D();
		private var intersectionPoints:Vector.<IntersectionPoints> = new Vector.<IntersectionPoints>();
		private var increase:Vector.<Boolean> = new Vector.<Boolean>();
		
		private static var METHOD_CENTER:int = 0;
		private static var METHOD_ANGLE:int = 1;
		private var method:int = Intersect.METHOD_CENTER;
		
		public var pointAverage:Vector3D = new Vector3D();
		private var maxRetries:int = 40;
		
		private var certainty:Number = 0;
		
		public function Intersect() 
		{
			
		}
		
		public function triangulate(position1:Vector3D, position2:Vector3D, position3:Vector3D):Vector3D 
		{
			return of(new <Vector3D>[position1, position2, position3]);
		}
		
		public function quadulate(position1:Vector3D, position2:Vector3D, position3:Vector3D, position4:Vector3D):Vector3D 
		{
			return of(new <Vector3D>[position1, position2, position3, position4]);
		}
		
		public function of(vec:Vector.<Vector3D>):Vector3D 
		{
			pointAverage.x = 0;
			pointAverage.y = 0;
			pointAverage.z = 0;
			
			for (var i:int = 0; i < vec.length; i++) 
			{
				points[i] = vec[i];
				pointAverage.x += vec[i].x;
				pointAverage.y += vec[i].y;
				pointAverage.z += vec[i].z;
				
				if (intersections.length <= i) intersections[i] = new Vector3D();
				if (increase.length <= i) increase[i] = false;
			}
			
			pointAverage.x /= vec.length;
			pointAverage.y /= vec.length;
			pointAverage.z /= vec.length;
			
			correctUnderPoweredSignals();
			updateTarget(0);
			
			return averageIntersectionTarget;
		}
		
		private function correctUnderPoweredSignals():void 
		{
			for (var i:int = 0; i < points.length; i++) 
			{
				correctUnderPoweredSignal(points[i], points[(i+i)%points.length]);
			}
		}
		
		private function correctUnderPoweredSignal(pointA:Vector3D, pointB:Vector3D):void 
		{
			var minDistance:Number = vecDif(pointA, pointB);
			var signalDistance:Number = pointA.w + pointB.w;
			
			var fractionDif:Number = signalDistance / minDistance;
			if (fractionDif < 1) {
				pointA.w = pointA.w / (fractionDif-0.01);
				pointB.w = pointB.w / (fractionDif-0.01);
			}
		}
		
		private function updateTarget(tryCount:int):void 
		{
			for (var i:int = 0; i < points.length; i++) 
			{
				intersectionPoints[i] = c2cIntersect(points[(i+0)%points.length], points[(i+1)%points.length]);
			}
			
			for (var j:int = 0; j < points.length; j++) 
			{
				var intersectionPointsVec:Vector.<IntersectionPoints> = new Vector.<IntersectionPoints>();
				for (var o:int = 0; o < intersectionPoints.length; o++) 
				{
					var index:int = (j + o) % points.length;
					intersectionPointsVec.push(intersectionPoints[index]);
				}
				pickClosest(intersectionPointsVec);
			}
			
			for (var k:int = 0; k < points.length; k++) 
			{
				if (intersectionPoints[k].closestPoint.length == 0) {
					if (tryCount < maxRetries) increaseSignalStrength(tryCount);
					return;
				}
			}
			
			for (var l:int = 0; l < points.length; l++) 
			{
				intersections[l].x = intersectionPoints[l].closestPoint.x;
				intersections[l].y = intersectionPoints[l].closestPoint.y;
			}
			
			for (var m:int = 0; m < points.length; m++) 
			{
				if (!intersectionPoints[m].valid) return;
			}
			
			
			if (method == Intersect.METHOD_CENTER){
				var divCount:int = 0;
				averageIntersectionTarget.x = 0;
				averageIntersectionTarget.y = 0;
				
				for (var n:int = 0; n < points.length; n++) 
				{
					if (intersectionPoints[n].valid) {
						averageIntersectionTarget.x += intersections[n].x;
						averageIntersectionTarget.y += intersections[n].y;
						divCount++;
					}
				}
				
				averageIntersectionTarget.x /= divCount;
				averageIntersectionTarget.y /= divCount;
			}
			else if (method == Intersect.METHOD_ANGLE) {
				var aveAngle:Number = 0;
				var aveH:Number = 0;
				for (var p:int = 0; p < points.length; p++) 
				{
					var difX:Number = (pointAverage.x - intersections[p].x);
					var difY:Number = (pointAverage.y - intersections[p].y);
					aveAngle += Math.atan2(difY, difX) * 180 / Math.PI;
					aveH += Math.sqrt(Math.pow(difX, 2) + Math.pow(difY, 2));
				}
				aveAngle /= points.length;
				aveH /= points.length;
				
				averageIntersectionTarget.x = pointAverage.x + Math.cos((180 + aveAngle) / 180 * Math.PI) * aveH;
				averageIntersectionTarget.y = pointAverage.y + Math.sin((180 + aveAngle) / 180 * Math.PI) * aveH;
			}
			
			findCertainty();
		}
		
		private function findCertainty():void 
		{
			certainty = 0;
			for (var i:int = 0; i < intersectionPoints.length; i++) 
			{
				certainty += vecDif(intersectionPoints[i].closestPoint, averageIntersectionTarget);
			}
			certainty /= intersectionPoints.length;
		}
		
		private function pickClosest(intersectionPointsVec:Vector.<IntersectionPoints>):void
		{
			
			var dif1:Number = 0;
			var dif2:Number = 0;
			for (var i:int = 1; i < intersectionPointsVec.length; i++) 
			{
				dif1 += vecDif(intersectionPointsVec[0].point1, intersectionPointsVec[i].point1);
				dif1 += vecDif(intersectionPointsVec[0].point1, intersectionPointsVec[i].point2);
				dif2 += vecDif(intersectionPointsVec[0].point2, intersectionPointsVec[i].point1);
				dif2 += vecDif(intersectionPointsVec[0].point2, intersectionPointsVec[i].point2);
			}
			
			if (dif1 < dif2) {
				intersectionPointsVec[0].closestPoint.x = intersectionPointsVec[0].point1.x;
				intersectionPointsVec[0].closestPoint.y = intersectionPointsVec[0].point1.y;
			}
			else {
				intersectionPointsVec[0].closestPoint.x = intersectionPointsVec[0].point2.x;
				intersectionPointsVec[0].closestPoint.y = intersectionPointsVec[0].point2.y;
			}
			
			
			/*var dif1:Number = 0;
			dif1 += vecDif(va.point1, vb.point1);
			dif1 += vecDif(va.point1, vb.point2);
			dif1 += vecDif(va.point1, vc.point1);
			dif1 += vecDif(va.point1, vc.point2);
			
			var dif2:Number = 0;
			dif2 += vecDif(va.point2, vb.point1);
			dif2 += vecDif(va.point2, vb.point2);
			dif2 += vecDif(va.point2, vc.point1);
			dif2 += vecDif(va.point2, vc.point2);
			
			if (dif1 < dif2) {
				va.closestPoint.x = va.point1.x;
				va.closestPoint.y = va.point1.y;
			}
			else {
				va.closestPoint.x = va.point2.x;
				va.closestPoint.y = va.point2.y;
			}*/
		}
		
		private function vecDif(point1:Vector3D, point2:Vector3D):Number 
		{
			var difX:Number = point1.x - point2.x;
			var difY:Number = point1.y - point2.y;
			return Math.sqrt(Math.pow(difX, 2) + Math.pow(difY, 2));
		}
		
		private function increaseSignalStrength(tryCount:int):void 
		{
			for (var i:int = 0; i < points.length; i++) 
			{
				if (points[0].w < points[1].w) increase[(i+0)%points.length] = true;
				else increase[(i+1)%points.length] = true;
			}
			for (var j:int = 0; j < increase.length; j++) 
			{
				if (increase[j]) {
					if (tryCount == 0) points[j].w = points[j].w * 0.7;
					else points[j].w = points[j].w * 1.05;
				}
			}
			
			tryCount++;
			updateTarget(tryCount);
		}
		
		private function c2cIntersect(pointA:Vector3D, pointB:Vector3D):IntersectionPoints
		{
			var x0:Number = pointA.x;
			var y0:Number = pointA.y;
			var r0:Number = pointA.w;
			var x1:Number = pointB.x;
			var y1:Number = pointB.y;
			var r1:Number = pointB.w;
			
			var intersection:IntersectionPoints = new IntersectionPoints();
			var dx:Number = x1 - x0;
			var dy:Number = y1 - y0;
			var d:Number = Math.sqrt((dy*dy) + (dx*dx))
		 
		 
			//' Check for solvability.
			if (d > (r0 + r1)) {
				//'no solution. circles do Not intersect
				//return 0;
				intersection.valid = false;
				return intersection;
			}
		 
			if (d < Math.abs(r0 - r1)) {
			//' no solution. one circle is contained in the other
				//return -1;
				intersection.valid = false;
				return intersection;
			}
		 
			//' 'point 2' is the point where the Line through the circle
			//' intersection points crosses the Line between the circle
			//' centers.
		 
			//' Determine the distance from point 0 To point 2.
			var a:Number = ((r0*r0) - (r1*r1) + (d*d)) / (2.0 * d)
		 
			//' Determine the coordinates of point 2.
			var x2:Number = x0 + (dx * a / d);
			var y2:Number = y0 + (dy * a / d);
		 
			//' Determine the distance from point 2 To either of the
			//' intersection points.
			var h:Number = Math.sqrt((r0*r0) - (a*a))
		 
			//' Now determine the offsets of the intersection points from
			//' point 2.
			var rx:Number = (0 - dy) * (h / d);
			var ry:Number = dx * (h / d);
		 
			//' Determine the absolute intersection points.
			intersection.point1.x = x2 + rx;
			intersection.point2.x = x2 - rx;
			intersection.point1.y = y2 + ry;
			intersection.point2.y = y2 - ry;
		 
			//return 1;
			
			return intersection;
		}
	}

}

import flash.geom.Point;
import flash.geom.Vector3D;

class IntersectionPoints
{
	public var valid:Boolean = true;
	public var point1:Vector3D = new Vector3D();
	public var point2:Vector3D = new Vector3D();
	public var closestPoint:Vector3D = new Vector3D();
	private var _average:Vector3D = new Vector3D();
	
	public function IntersectionPoints()
	{
		
	}
	
	public function get average():Vector3D 
	{
		_average.x = (point1.x + point2.x) / 2;
		_average.y = (point1.y + point2.y) / 2;
		return _average;
	}
	
	public function toString():String
	{
		return "valid = " + valid + "\n" + "point1 = " + point1 + "\n" + "point2 = " + point2 + "\n" + "closestPoint = " + closestPoint + "\n";
	}
}