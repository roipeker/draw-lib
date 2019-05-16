// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.builders {
import com.roipeker.starling.draw.GraphData;
import com.roipeker.starling.draw.GraphGeom;
import com.roipeker.starling.draw.math.shapes.Circle;
import com.roipeker.starling.draw.math.shapes.Ellipse;

public class CircleBuilder extends AbsShapeBuilder {

    // Defines a global factor to reduce by the radius of width and height
    // Higher number = less segments.
    public static var segmentReduceFactor:Number = 2.5;

    public function CircleBuilder() {
        super();
    }

    override public function build(shapeData:GraphData):void {
        const points:Array = shapeData.points;
        var x:Number, y:Number, w:Number = 0, h:Number = 0;
        var totalSegments:int;

        if (shapeData.type.isCircle()) {
            const circleData:Circle = shapeData.shape as Circle;
            x = circleData.x;
            y = circleData.y;
            w = h = circleData.radius;
//            totalSegments = Math.floor(30 * Math.sqrt(halfW)) / segmentReduceFactor;
        } else if (shapeData.type.isEllipse()) {
            const ellipseData:Ellipse = shapeData.shape as Ellipse;
            x = ellipseData.x;
            y = ellipseData.y;
            w = ellipseData.halfW;
            h = ellipseData.halfH;
//            totalSegments = Math.floor(15 * Math.sqrt(halfW + halfH)) / segmentReduceFactor;
        }

        if (w == 0 || h == 0) return;
        totalSegments = 15 * Math.sqrt(w + h) | 0;
        totalSegments /= segmentReduceFactor;
        points.length = 0;

        const segment:Number = (Math.PI * 2) / totalSegments;

        for (var i:int = 0; i < totalSegments; i++) {
            const angle:Number = segment * i;
            points.push(
                    x + (-Math.sin(angle) * w),
                    y + (-Math.cos(angle) * h)
            );
        }
        points.push(points[0], points[1]);
    }

    override public function triangulate(shapeData:GraphData, geometry:GraphGeom):void {
        const points:Array = shapeData.points;
        const verts:Array = geometry.points;
        const indices:Array = geometry.indices;
        const center:int = verts.length >> 1;
        var vertPos:int = center;

        // Circle and Ellipse have x,y
        verts.push(shapeData.shape['x'], shapeData.shape['y']);
        for (var i:int = 0, ilen:int = points.length; i < ilen; i += 2) {
            verts.push(points[i], points[int(i + 1)]);
            indices.push(vertPos, center, ++vertPos);
        }
    }
}
}
