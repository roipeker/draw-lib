// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.builders {
import com.roipeker.starling.draw.GraphData;
import com.roipeker.starling.draw.GraphGeom;
import com.roipeker.starling.draw.math.shapes.MeshShape;

public class MeshBuilder extends AbsShapeBuilder {

    public function MeshBuilder() {
        super();
    }

    override public function build(shapeData:GraphData):void {
        const shape:MeshShape = shapeData.shape as MeshShape;
        // vectors vs array.
        const len:int = shape.vertices.length;
        for (var i:int = 0; i < len; i++) {
            shapeData.points[i] = shape.vertices[i];
        }
    }

    override public function triangulate(shapeData:GraphData, geometry:GraphGeom):void {

        // TODO: doesnt work well with lineStyle, only fills.

        const shapePoints:Vector.<Number> = MeshShape(shapeData.shape).vertices;
        const shapeIndices:Vector.<int> = MeshShape(shapeData.shape).indices;

        const verts:Array = geometry.points;
        const indices:Array = geometry.indices;

        // vectors vs array.
        for (var i:int = 0, ilen:int = shapePoints.length; i < ilen; i++) {
            verts[verts.length] = shapePoints[i];
        }

        if (shapeIndices && shapeIndices.length) {
            ilen = shapeIndices.length;
            for (i = 0; i < ilen; i++) {
                indices[indices.length] = shapeIndices[i];
            }
        } else {
            // validate amount of vertices...
            var numPoints:int = shapePoints.length / 2;
            if (numPoints % 3 != 0) {
                trace("[MeshBuilder] Error in triangulation, must be divisible by 3");
            } else {
                const vertPos:int = geometry.points.length >> 1;
                for (i = 0; i < numPoints; i += 3) {
                    indices.push(
                            vertPos + i, vertPos + 1 + i, vertPos + 2 + i
                    );
                }
            }
        }
    }
}
}
