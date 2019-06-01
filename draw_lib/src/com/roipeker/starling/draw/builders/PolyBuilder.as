// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.builders {
import com.roipeker.starling.draw.GraphData;
import com.roipeker.starling.draw.GraphGeom;
import com.roipeker.starling.draw.math.shapes.Poly;
import com.roipeker.starling.draw.utils.earcut.Earcut;

public class PolyBuilder extends AbsShapeBuilder {

    public function PolyBuilder() {
        super();
    }

    override public function build(shapeData:GraphData):void {
        const points:Array = Poly(shapeData.shape).points;
        for (var i:int = 0, ilen:int = points.length; i < ilen; i++) {
            shapeData.points[i] = points[i];
        }
    }

    override public function triangulate(shapeData:GraphData, geometry:GraphGeom):void {
        var points:Array = shapeData.points;
        if (points.length >= 6) {
            const verts:Array = geometry.points;
            const indices:Array = geometry.indices;
            var ilen:int;
            var holes:Array = [];

            ilen = shapeData.holes.length;
            if (ilen) {
                for (var i:int = 0; i < ilen; i++) {
//                    holes.push(points.length / 2);
                    holes[holes.length] = points.length / 2;
                    points = points.concat(shapeData.holes[i].points);
                }
            }

            var triangles:Array = Earcut.earcut(points, holes );
            if (!triangles) return;

            const vertPos:int = verts.length >> 1;

            ilen = triangles.length;
            for (i = 0; i < ilen; i += 3) {
                /*indices.push(
                        triangles[i] + vertPos,
                        triangles[i + 1] + vertPos,
                        triangles[i + 2] + vertPos
                );*/
                indices[indices.length] = triangles[i] + vertPos;
                indices[indices.length] = triangles[i + 1] + vertPos;
                indices[indices.length] = triangles[i + 2] + vertPos;
            }

            ilen = points.length;
            for (i = 0; i < ilen; i++) {
                verts[verts.length] = points[i];
            }
        }
    }
}
}
