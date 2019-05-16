// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.builders {
import com.roipeker.starling.draw.GraphData;
import com.roipeker.starling.draw.GraphGeom;
import com.roipeker.starling.draw.math.shapes.Rect;

public class RectBuilder extends AbsShapeBuilder {

    public function RectBuilder() {
        super();
    }

    override public function build(shapeData:GraphData):void {
        const rect:Rect = shapeData.shape as Rect;
        shapeData.points.length = 0;
        shapeData.points.push(
                rect.x, rect.y,
                rect.x + rect.w, rect.y,
                rect.x + rect.w, rect.y + rect.h,
                rect.x, rect.y + rect.h,
                rect.x, rect.y
        );
    }

    override public function triangulate(shapeData:GraphData, geometry:GraphGeom):void {
        const points:Array = shapeData.points;
        const vertPos:int = geometry.points.length >> 1;
        geometry.points.push(
                points[0], points[1],
                points[2], points[3],
                points[6], points[7],
                points[4], points[5]
        );
        geometry.indices.push(
                vertPos, vertPos + 1, vertPos + 2,
                vertPos + 1, vertPos + 2, vertPos + 3
        );
    }
}
}
