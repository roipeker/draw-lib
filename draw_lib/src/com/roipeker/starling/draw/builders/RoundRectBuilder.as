// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.builders {
import com.roipeker.starling.draw.GraphData;
import com.roipeker.starling.draw.GraphGeom;
import com.roipeker.starling.draw.math.shapes.RoundRect;
import com.roipeker.starling.draw.utils.earcut.Earcut;

import starling.utils.MathUtil;

public class RoundRectBuilder extends AbsShapeBuilder {

    // number of segments per corner, is NOT a divider, but the actual segment number.
    public static var cornerNumSegments:uint = 20;

    private static function quadraticBezierCurve(fromX:Number, fromY:Number, cpX:Number, cpY:Number, toX:Number, toY:Number, out:Array = null) {
        if (!out) out = [];
        var n:int = cornerNumSegments;
        var xa:Number = 0;
        var ya:Number = 0;
        var xb:Number = 0;
        var yb:Number = 0;
        var x:Number = 0;
        var y:Number = 0;


        for (var i:int = 0, j:Number = 0; i <= n; ++i) {


            j = i / n;
            xa = getPt(fromX, cpX, j);
            ya = getPt(fromY, cpY, j);
            xb = getPt(cpX, toX, j);
            yb = getPt(cpY, toY, j);

            x = getPt(xa, xb, j);
            y = getPt(ya, yb, j);

            /* if ( constrain ){
                 if ( x < constrain.x || y < constrain.y
                         || x > constrain.right || y > constrain.bottom ){
                     violated = true ;
                     break ;
                     trace('vuiolation')
                 }
             }*/
//            out.push(x, y);
            out[out.length] = x;
            out[out.length] = y;
        }
        return out;
    }

    [Inline]
    private static function getPt(n1:Number, n2:Number, perc:Number):Number {
        return n1 + ((n2 - n1) * perc);
    }

    public function RoundRectBuilder() {
        super();
    }

    override public function build(shapeData:GraphData):void {
        const rrect:RoundRect = shapeData.shape as RoundRect;
        const points:Array = shapeData.points;

        const x:Number = rrect.x,
                y:Number = rrect.y,
                w:Number = rrect.w,
                h:Number = rrect.h;

        var tlr:Number = rrect.tlr,
                trr:Number = rrect.trr,
                blr:Number = rrect.blr,
                brr:Number = rrect.brr;

        // constrains the radius to the maximun size.
        const MIN_SIZE:Number = 0.0000000001;

        // TODO: fix MAX_SIZE and clamp(), when using complex round rect, corners can be larger than h/2 || w/2.
        const MAX_SIZE:Number = MathUtil.min(w, h) / 2;

        tlr = MathUtil.clamp(tlr, MIN_SIZE, MAX_SIZE);
        trr = MathUtil.clamp(trr, MIN_SIZE, MAX_SIZE);
        blr = MathUtil.clamp(blr, MIN_SIZE, MAX_SIZE);
        brr = MathUtil.clamp(brr, MIN_SIZE, MAX_SIZE);

        points.length = 0;

        var allSame:Boolean = tlr == trr && tlr == blr && tlr == brr;

        // special case for "pill" shapes, the quad curve doesn't make a proper half circle.
        // although Circle or Bezier curves should be an optional setting maybe.
        if (allSame && tlr == MAX_SIZE) {
            const len:int = cornerNumSegments;
            var hpi:Number = Math.PI / 2;
            const segment:Number = hpi / len;
            var cx:Number = x + tlr;
            var cy:Number = y + tlr;
            var offsetAngle:Number = Math.PI;

            // top left
            addSegments(points, len, segment, cx, cy, offsetAngle, tlr);

            cx = x + w - tlr;
            offsetAngle += hpi;
            // top right
            addSegments(points, len, segment, cx, cy, offsetAngle, tlr);

            offsetAngle += hpi;
            cy = y + h - tlr;
            // bottom right
            addSegments(points, len, segment, cx, cy, offsetAngle, tlr);

            offsetAngle += hpi;
            cx = x + tlr;
            // bottom left
            addSegments(points, len, segment, cx, cy, offsetAngle, tlr);

            points.push(points[0], points[1]);

        } else {
            points.push(x, y + tlr);
            quadraticBezierCurve(x, y + h - blr, x, y + h, x + blr, y + h, points);
            quadraticBezierCurve(x + w - brr, y + h, x + w, y + h, x + w, y + h - brr, points);
            quadraticBezierCurve(x + w, y + trr, x + w, y, x + w - trr, y, points);
            quadraticBezierCurve(x + tlr, y, x, y, x, y + tlr + MIN_SIZE, points);
        }
    }

    private function addSegments(points:Array, len:int, segment:Number, cx:Number, cy:Number, offsetAngle:Number, radius:Number):void {
        var angle:Number;
        for (var i:int = 0; i < len; i++) {
            angle = segment * i + offsetAngle;
            points.push(
                    cx + (Math.cos(angle) * radius),
                    cy + (Math.sin(angle) * radius)
            );
        }
    }

    override public function triangulate(shapeData:GraphData, geometry:GraphGeom):void {
        const points:Array = shapeData.points;
        const indices:Array = geometry.indices;
        const verts:Array = geometry.points;
        const vertPos:int = verts.length >> 1;

        // reduce the triangulation.
        const triangles:Array = Earcut.earcut( points );

//        const triangles:Array = points;
        var ilen:int;

        ilen = triangles.length;
        for (var i:int = 0; i < ilen; i += 3) {
            indices[indices.length] = vertPos + triangles[i];
            indices[indices.length] = vertPos + triangles[i + 1];
            indices[indices.length] = vertPos + triangles[i + 2];
        }

        /*ilen = points.length;
        for (i = 0; i < ilen; i++) {
//            verts.push(points[i], points[++i]);
            verts[verts.length] = points[i];
            verts[verts.length] = points[++i];
        }*/
        ilen = points.length;
        for (i = 0; i < ilen; i++) {
            verts[verts.length] = points[i];
        }
    }
}
}
