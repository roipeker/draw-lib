// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 10/01/2019.
//
// =================================================================================================

package com.roipeker.starling.draw.utils.lines {
import flash.display.CapsStyle;
import flash.display.JointStyle;

/**
 * Ported from
 * https://hypertolosana.github.io/efficient-webgl-stroking
 *
 * Not optimized in any way.
 *
 */

public class ComplexLineStroke {
    public function ComplexLineStroke() {
    }

    public static var EPSILON:Number = 0.0001;
    public static var minSegmentPixels:Number = 6;

    public static const PI_M_EP:Number = Math.PI - EPSILON;
    public static const PI_P_EP:Number = Math.PI + EPSILON;
    public static const PI_2:Number = 2 * Math.PI;


    public static function getStrokeGeometry(points:Array, attrs:Object, vert:Array = null):Array {
        // trivial reject
        if (points.length < 2) {
            return null;
        }
        var cap:String = attrs.cap || CapsStyle.NONE;
        var join:String = attrs.join || JointStyle.BEVEL;
        var lineWidth:Number = (attrs.width || 1) / 2;
        var miterLimit:Number = attrs.miterLimit || 10;
//        var vertices:Array = [];
        if (!vert) vert = [];
        var middlePnts:Array = []; // middle points per each line segment.
        var closed:Boolean = false;
        if (points.length === 2) {
            join = JointStyle.BEVEL;
            createTriangles(points[0], Pnt.Middle(points[0], points[1]), points[1], vert, lineWidth, join, miterLimit);
        } else {
//            * Disable for simulation purposes, but uncomment for have the system working otherwise.
            if (points[0] === points[points.length - 1] ||
                    (points[0].x === points[points.length - 1].x && points[0].y === points[points.length - 1].y)) {
                var p0:Pnt = points.shift();
                p0 = Pnt.Middle(p0, points[0]);
                points.unshift(p0);
                points.push(p0);
                closed = true;
            }
            const npoints:uint = points.length;
            var i:int, len:int;
            for (i = 0, len = npoints - 1; i < len; i++) {
                if (i == 0) {
                    middlePnts.push(points[0]);
                } else if (i == npoints - 2) {
                    middlePnts.push(points[uint(npoints - 1)])
                } else {
                    middlePnts.push(Pnt.Middle(points[i], points[uint(i + 1)]));
                }
            }
            for (i = 1, len = middlePnts.length; i < len; i++) {
                createTriangles(middlePnts[uint(i - 1)], points[i], middlePnts[i], vert, lineWidth, join, miterLimit);
            }
        }

        const numPoints:uint = points.length;

        if (!closed) {
            var p00:Pnt;
            var p01:Pnt;
            if (cap === CapsStyle.ROUND) {
                p00 = vert[0];
                p01 = vert[1];
                var p02:Pnt = points[1];
                var p10:Pnt = vert[vert.length - 1];
                var p11:Pnt = vert[vert.length - 3];
                var p12:Pnt = points[numPoints - 2];
                createRoundCap(points[0], p00, p01, p02, vert);
                createRoundCap(points[numPoints - 1], p10, p11, p12, vert);

            } else if (cap === CapsStyle.SQUARE) {
                p00 = vert[vert.length - 1];
                p01 = vert[vert.length - 3];
                createSquareCap(
                        vert[0],
                        vert[1],
                        Pnt.Sub(points[0], points[1]).normalize().scalarMult(Pnt.Sub(points[0], vert[0]).length()),
                        vert);
                createSquareCap(
                        p00,
                        p01,
                        Pnt.Sub(points[numPoints - 1], points[numPoints - 2]).normalize().scalarMult(Pnt.Sub(p01, points[numPoints - 1]).length()),
                        vert);
            }
        }
        return vert;
    }

    public static function createSquareCap(p0:Pnt, p1:Pnt, dir:Pnt, verts:Array) {
        const p1dir:Pnt = Pnt.Add(p1, dir);
        verts.push(p0, Pnt, p1dir, p1, p1dir, p0);
    }


    public static function createRoundCap(center:Pnt, _p0:Pnt, _p1:Pnt, nextPntInLine:Pnt, verts:Array):void {
        var radius:Number = Pnt.Sub(center, _p0).length();
        var angle0:Number = Math.atan2((_p1.y - center.y), (_p1.x - center.x));
        var angle1:Number = Math.atan2((_p0.y - center.y), (_p0.x - center.x));
        var orgAngle0:Number = angle0;
        if (angle1 > angle0) {
            if (angle1 - angle0 >= PI_M_EP) {
                angle1 = angle1 - PI_2;
            }
        } else {
            if (angle0 - angle1 >= PI_M_EP) {
                angle0 = angle0 - PI_2;
            }
        }
        var angleDiff:Number = angle1 - angle0;
        const absDiff:Number = Math.abs(angleDiff);
        if (absDiff >= PI_M_EP && absDiff <= PI_P_EP) {
            var r1:Pnt = Pnt.Sub(center, nextPntInLine);
            if (r1.x === 0) {
                if (r1.y > 0) {
                    angleDiff = -angleDiff;
                }
            } else if (r1.x >= -EPSILON) {
                angleDiff = -angleDiff;
            }
        }
        var nsegments:uint = (Math.abs(angleDiff * radius) / minSegmentPixels) >> 0;
        nsegments++;
        var angleInc:Number = angleDiff / nsegments;
        for (var i:int = 0; i < nsegments; i++) {

            verts.push(new Pnt(center.x, center.y));
            verts.push(new Pnt(
                    center.x + radius * Math.cos(orgAngle0 + angleInc * i),
                    center.y + radius * Math.sin(orgAngle0 + angleInc * i)
            ));
            verts.push(new Pnt(
                    center.x + radius * Math.cos(orgAngle0 + angleInc * (1 + i)),
                    center.y + radius * Math.sin(orgAngle0 + angleInc * (1 + i))
            ));
        }
    }

    [Inline]
    public static function signedArea(p0:Pnt, p1:Pnt, p2:Pnt):Number {
        return (p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y);
    }

    [Inline]
    public static function lineIntersection(p0:Pnt, p1:Pnt, p2:Pnt, p3:Pnt):Pnt {
        var a0:Number = p1.y - p0.y;
        var b0:Number = p0.x - p1.x;
        var a1:Number = p3.y - p2.y;
        var b1:Number = p2.x - p3.x;
        var det:Number = a0 * b1 - a1 * b0;
        if (det > -EPSILON && det < EPSILON) {
            return null;
        } else {
            var c0:Number = a0 * p0.x + b0 * p0.y;
            var c1:Number = a1 * p2.x + b1 * p2.y;
            var x:Number = (b1 * c0 - b0 * c1) / det;
            var y:Number = (a0 * c1 - a1 * c0) / det;
            return new Pnt(x, y);
        }
    }


    public static function createTriangles(p0:Pnt, p1:Pnt, p2:Pnt, verts:Array, width:Number, join:String, miterLimit:Number) {
        var t0:Pnt = Pnt.Sub(p1, p0);
        var t2:Pnt = Pnt.Sub(p2, p1);

        t0.perpendicular();
        t2.perpendicular();
        // triangle composed by the 3 points if clockwise or couterclockwise.
        // if counterclockwise, we must invert the line threshold points, otherwise the intersection point
        // could be erroneous and lead to odd results.
        if (signedArea(p0, p1, p2) > 0) {
            t0.invert();
            t2.invert();
        }
        t0.normalize();
        t2.normalize();
        t0.scalarMult(width);
        t2.scalarMult(width);


        const a_p0t0:Pnt = Pnt.Add(p0, t0);
        const a_p1t0:Pnt = Pnt.Add(p1, t0);
        const s_p0t0:Pnt = Pnt.Sub(p0, t0);
        const s_p1t2:Pnt = Pnt.Sub(p1, t2);
        const a_p2t2:Pnt = Pnt.Add(p2, t2);
        const a_p1t2:Pnt = Pnt.Add(p1, t2);
        const s_p2t2:Pnt = Pnt.Sub(p2, t2);

        var pintersect:Pnt = lineIntersection(
                a_p0t0,
                a_p1t0,
                a_p2t2,
                a_p1t2
        );

        var anchor:Pnt = null;
        var anchorLength:Number = Number.MAX_VALUE;
        if (pintersect) {
            anchor = Pnt.Sub(pintersect, p1);
            anchorLength = anchor.length();
        }
        var dd:int = (anchorLength / width) | 0;
        var p0p1:Pnt = Pnt.Sub(p0, p1);
        var p0p1Length:Number = p0p1.length();
        var p1p2:Pnt = Pnt.Sub(p1, p2);
        var p1p2Length:Number = p1p2.length();


        /**
         * the cross point exceeds any of the segments dimension.
         * do not use cross point as reference.
         */
        if (anchorLength > p0p1Length || anchorLength > p1p2Length) {
            verts.push(a_p0t0, s_p0t0, a_p1t0, s_p0t0, a_p1t0, Pnt.Sub(p1, t0));
            if (join === JointStyle.ROUND) {
                createRoundCap(p1, a_p1t0, a_p1t2, p2, verts);
            } else if (join === JointStyle.BEVEL || (join === JointStyle.MITER && dd >= miterLimit)) {
                verts.push(p1, a_p1t0, a_p1t2);
            } else if (join === JointStyle.MITER && dd < miterLimit && pintersect) {
                verts.push(a_p1t0, p1, pintersect, a_p1t2, p1, pintersect);
            }
            verts.push(a_p2t2, s_p1t2, a_p1t2, a_p2t2, s_p1t2, s_p2t2);
        } else {
            const s_p1an:Pnt = Pnt.Sub(p1, anchor);

            verts.push(a_p0t0, s_p0t0, s_p1an, a_p0t0, s_p1an, a_p1t0);
            if (join === JointStyle.ROUND) {
                var _p0:Pnt = a_p1t0;
                var _p1:Pnt = a_p1t2;
                var _p2:Pnt = s_p1an;
                var center:Pnt = p1;
                verts.push(_p0, center, _p2);
                createRoundCap(center, _p0, _p1, _p2, verts);
                verts.push(center, _p1, _p2);
            } else {
                if (join === JointStyle.BEVEL || join === JointStyle.MITER) {
                    verts.push(a_p1t0, a_p1t2, s_p1an);
                }
                if (join === JointStyle.MITER && dd < miterLimit) {
                    verts.push(pintersect, a_p1t0, a_p1t2);
                }
            }
            verts.push(a_p2t2, s_p1an, a_p1t2, a_p2t2, s_p1an, s_p2t2);
        }
    }


    /*public static function createTriangles2(p0:Pnt, p1:Pnt, p2:Pnt, verts:Array, indices:Array, width:Number, join:String, miterLimit:Number) {
        var t0:Pnt = Pnt.Sub(p1, p0);
        var t2:Pnt = Pnt.Sub(p2, p1);

        t0.perpendicular();
        t2.perpendicular();

        // triangle composed by the 3 points if clockwise or couterclockwise.
        // if counterclockwise, we must invert the line threshold points, otherwise the intersection point
        // could be erroneous and lead to odd results.
        if (signedArea(p0, p1, p2) > 0) {
            t0.invert();
            t2.invert();
        }
        t0.normalize();
        t2.normalize();
        t0.scalarMult(width);
        t2.scalarMult(width);
        var pintersect:Pnt = lineIntersection(
                Pnt.Add(t0, p0),
                Pnt.Add(t0, p1),
                Pnt.Add(t2, p2),
                Pnt.Add(t2, p1)
        );

        var anchor:Pnt = null;
        var anchorLength:Number = Number.MAX_VALUE;
        if (pintersect) {
            anchor = Pnt.Sub(pintersect, p1);
            anchorLength = anchor.length();
        }
        var dd:Number = (anchorLength / width) | 0;
        var p0p1:Pnt = Pnt.Sub(p0, p1);
        var p0p1Length:Number = p0p1.length();
        var p1p2:Pnt = Pnt.Sub(p1, p2);
        var p1p2Length:Number = p1p2.length();
        /!**
         * the cross point exceeds any of the segments dimension.
         * do not use cross point as reference.
         *!/
        var idx:int = indices.length - 1;

        if (anchorLength > p0p1Length || anchorLength > p1p2Length) {

            verts.push(Pnt.Add(p0, t0));
            indices.push(idx + 1);

            verts.push(Pnt.Sub(p0, t0));
            indices.push(idx + 2);

            verts.push(Pnt.Add(p1, t0));
            indices.push(idx + 3);

            verts.push(Pnt.Sub(p0, t0));//2
            indices.push(idx + 2);

            verts.push(Pnt.Add(p1, t0));//3
            indices.push(idx + 3);

            verts.push(Pnt.Sub(p1, t0));
            indices.push(idx + 4);

            var lastIdx:int;
            if (join === JOIN_ROUND) {
                createRoundCap(p1, Pnt.Add(p1, t0), Pnt.Add(p1, t2), p2, verts, indices);
            } else if (join === JOIN_BEVEL || (join === JOIN_MITER && dd >= miterLimit)) {

                verts.push(p1);
                indices.push(idx + 5);

                verts.push(Pnt.Add(p1, t0));//3
                indices.push(idx + 3);

                verts.push(Pnt.Add(p1, t2));
                indices.push(idx + 6);
                lastIdx = idx + 6;

            } else if (join === JOIN_MITER && dd < miterLimit && pintersect) {

                verts.push(Pnt.Add(p1, t0));//3
                indices.push(idx + 3);

                verts.push(p1);
                indices.push(idx + 5);

                verts.push(pintersect);
                indices.push(idx + 6);

                verts.push(Pnt.Add(p1, t2));
                indices.push(idx + 7);
                lastIdx = idx + 7;

                verts.push(p1);//5
                indices.push(idx + 5);

                verts.push(pintersect);//6
                indices.push(idx + 6);
            }

            // offset.
            idx = lastIdx;

            verts.push(Pnt.Add(p2, t2));
            indices.push(idx + 1);

            verts.push(Pnt.Sub(p1, t2));
            indices.push(idx + 2);

            verts.push(Pnt.Add(p1, t2));//6
            indices.push(lastIdx);

            verts.push(Pnt.Add(p2, t2));//7
            indices.push(idx + 1);

            verts.push(Pnt.Sub(p1, t2));//8
            indices.push(idx + 2);

            verts.push(Pnt.Sub(p2, t2));
            indices.push(idx + 3);

        } else {

            verts.push(Pnt.Add(p0, t0));
            indices.push(idx + 1);

            verts.push(Pnt.Sub(p0, t0));
            indices.push(idx + 2);

            verts.push(Pnt.Sub(p1, anchor));
            indices.push(idx + 3);

            verts.push(Pnt.Add(p0, t0));//1
            indices.push(idx + 1);

            verts.push(Pnt.Sub(p1, anchor));//3
            indices.push(idx + 3);

            verts.push(Pnt.Add(p1, t0));
            indices.push(idx + 4);

            if (join === JOIN_ROUND) {
                var _p0:Pnt = Pnt.Add(p1, t0);
                var _p1:Pnt = Pnt.Add(p1, t2);
                var _p2:Pnt = Pnt.Sub(p1, anchor);
                var center:Pnt = p1;

                verts.push(_p0);
                indices.push(idx + 5);

                verts.push(center);
                indices.push(idx + 6);

                verts.push(_p2);
                indices.push(idx + 7);

                createRoundCap(center, _p0, _p1, _p2, verts, indices);

                verts.push(center);//6
                indices.push(idx + 6);

                verts.push(_p1);
                indices.push(idx + 8);

                verts.push(_p2);//7
                indices.push(idx + 7);

            } else {
                if (join === JOIN_BEVEL || (join === JOIN_MITER && dd >= miterLimit)) {
                    verts.push(Pnt.Add(p1, t0));
                    indices.push(idx + 5);

                    verts.push(Pnt.Add(p1, t2));
                    indices.push(idx + 6);

                    verts.push(Pnt.Sub(p1, anchor));
                    indices.push(idx + 7);
                }

                if (join === JOIN_MITER && dd < miterLimit) {
                    var max:int = verts.length;
                    verts.push(pintersect);
                    verts.push(Pnt.Add(p1, t0));
                    verts.push(Pnt.Add(p1, t2));
                    indices.push(max, max + 1, max + 2);
                }
            }

            max = verts.length;
            verts.push(Pnt.Add(p2, t2));
            indices.push(max);

            verts.push(Pnt.Sub(p1, anchor));//3
            indices.push(idx + 3);

            verts.push(Pnt.Add(p1, t2));
            indices.push(max + 1);

            verts.push(Pnt.Add(p2, t2));
            indices.push(max + 2);

            verts.push(Pnt.Sub(p1, anchor));//3
            indices.push(idx + 3);

            verts.push(Pnt.Sub(p2, t2));
            indices.push(max + 3);

        }
    }*/


    public static function getPntsFromNumbers(points:Object):Array {
        var res:Array = [];
        var len:int = points.length;
        for (var i:int = 0; i < len; i += 2) {
            res.push(new Pnt(points[i], points[i + 1]));
        }
        return res;
    }
}
}
