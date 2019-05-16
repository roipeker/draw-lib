// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 03/01/2019.
//
//  ported from PixiJS
//  https://github.com/pixijs/pixi.js
//
// =================================================================================================

package com.roipeker.starling.draw.utils {
import com.roipeker.starling.draw.GraphData;
import com.roipeker.starling.draw.GraphGeom;
import com.roipeker.starling.draw.styles.LineStyle;
import com.roipeker.starling.draw.utils.lines.LineStrokePixi;
import com.roipeker.starling.draw.utils.lines.ComplexLineStroke;

import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.geom.Point;

public class GraphUtils {

    public static const PI2:Number = Math.PI * 2;

    public function GraphUtils() {
    }

    // buffer points.
    private static const POINT1:Point = new Point();
    private static const POINT2:Point = new Point();

    public static function resolveLine(graphData:GraphData, graphGeom:GraphGeom):void {
        if (graphData.points.length === 0) {
            return;
        }
        // if using complex line... build with another approach (way more triangles though).
        if ( graphData.lineStyle.joint != JointStyle.MITER || graphData.lineStyle.caps != CapsStyle.SQUARE ) {

            // most versatile approach.
            buildLineComplex(graphData, graphGeom);

            // only accepts partially line joins.
//            LineStrokePixi.buildLine(graphData, graphGeom);
        } else {
            buildLine(graphData, graphGeom);
        }
    }

    public static function buildLineComplex(graphicsData:GraphData, graphicsGeometry:GraphGeom):void {
        // TODO: optimize...
        var points:Array = graphicsData.points;
        var style:LineStyle = graphicsData.lineStyle;
        var verts:Array = graphicsGeometry.points;

        trace(points.length,verts.length);
        ComplexLineStroke.minSegmentPixels = 2;

        var ppts:Array = ComplexLineStroke.getPntsFromNumbers(points);
        var res:Array = ComplexLineStroke.getStrokeGeometry(ppts, {
            width: style.width,
            cap: style.caps,
            join: style.joint,
            miterLimit: style.miterLimit
        });

        var indexCount:int = res.length;
        var indexStart:int = verts.length / 2;
//        const indices:Array = graphicsGeometry.indices;

        // push all the geom.
        for (var i:int = 0, j:int = verts.length, ilen:int = res.length; i < ilen; i++) {
            verts[j++] = res[i].x;
            verts[j++] = res[i].y;
        }

        var v:Array = graphicsGeometry.indices;
        var si:int = v.length;
        for (i = 0; i < indexCount; i++) {
            v[si++] = indexStart + i;
        }
    }

    public static function buildLine(graphicsData:GraphData, geom:GraphGeom):void {
        // TODO OPTIMISE!
        var points:Array = graphicsData.points;//|| graphicsData.shape.points.slice();
        if (points.length === 0) {
            return;
        }

        var style:LineStyle = graphicsData.lineStyle;
        // get first and last point.. figure out the middle!
        var firstPoint:Point = POINT1;//new Point(points[0], points[1]);
        var lastPoint:Point = POINT2;//new Point(points[points.length - 2], points[points.length - 1]);
        firstPoint.x = points[0];
        firstPoint.y = points[1];
        lastPoint.x = points[points.length - 2];
        lastPoint.y = points[points.length - 1];

        // if the first point is the last point - gonna have issues :)
        if (firstPoint.x === lastPoint.x && firstPoint.y === lastPoint.y) {
            // need to clone as we are going to slightly modify the shape..
            points = points.slice();
            points.pop();
            points.pop();
//            lastPoint = new Point(points[points.length - 2], points[points.length - 1]);
            lastPoint.x = points[points.length - 2];
            lastPoint.y = points[points.length - 1];

            var midPointX:Number = lastPoint.x + ((firstPoint.x - lastPoint.x) * 0.5);
            var midPointY:Number = lastPoint.y + ((firstPoint.y - lastPoint.y) * 0.5);

            points.unshift(midPointX, midPointY);
            points.push(midPointX, midPointY);
        }

//        var verts:Array = graphicsGeometry.points;
        var indexCount:int = points.length;
        var length:int = indexCount / 2;
        var indexStart:int = geom.points.length / 2;
        // DRAW the Line
        var width:Number = style.width / 2;

        // sort color
        var p1x:Number = points[0];
        var p1y:Number = points[1];
        var p2x:Number = points[2];
        var p2y:Number = points[3];
        var p3x:Number = 0;
        var p3y:Number = 0;

        var perpx:Number = -(p1y - p2y);
        var perpy:Number = p1x - p2x;
        var perp2x:Number = 0;
        var perp2y:Number = 0;
        var perp3x:Number = 0;
        var perp3y:Number = 0;

        var dist:Number = Math.sqrt((perpx * perpx) + (perpy * perpy));

        perpx /= dist;
        perpy /= dist;
        perpx *= width;
        perpy *= width;

        const ratio:Number = style.alignment;
        var r1:Number = (1 - ratio) * 2;
        var r2:Number = ratio * 2;

        // start
        geom.points.push(
                p1x - (perpx * r1),
                p1y - (perpy * r1));

        geom.points.push(
                p1x + (perpx * r2),
                p1y + (perpy * r2));

        var i:int;
        for (i = 1; i < length - 1; ++i) {
            p1x = points[(i - 1) * 2];
            p1y = points[((i - 1) * 2) + 1];

            p2x = points[i * 2];
            p2y = points[(i * 2) + 1];

            p3x = points[(i + 1) * 2];
            p3y = points[((i + 1) * 2) + 1];

            perpx = -(p1y - p2y);
            perpy = p1x - p2x;

            dist = Math.sqrt((perpx * perpx) + (perpy * perpy));
            perpx /= dist;
            perpy /= dist;
            perpx *= width;
            perpy *= width;

            perp2x = -(p2y - p3y);
            perp2y = p2x - p3x;

            dist = Math.sqrt((perp2x * perp2x) + (perp2y * perp2y));
            perp2x /= dist;
            perp2y /= dist;
            perp2x *= width;
            perp2y *= width;

            var a1:Number = (-perpy + p1y) - (-perpy + p2y);
            var b1:Number = (-perpx + p2x) - (-perpx + p1x);
            var c1:Number = ((-perpx + p1x) * (-perpy + p2y)) - ((-perpx + p2x) * (-perpy + p1y));
            var a2:Number = (-perp2y + p3y) - (-perp2y + p2y);
            var b2:Number = (-perp2x + p2x) - (-perp2x + p3x);
            var c2:Number = ((-perp2x + p3x) * (-perp2y + p2y)) - ((-perp2x + p2x) * (-perp2y + p3y));

            var denom:Number = (a1 * b2) - (a2 * b1);
            if (Math.abs(denom) < 0.1) {
                denom += 10.1;
                geom.points.push(
                        p2x - (perpx * r1),
                        p2y - (perpy * r1));

                geom.points.push(
                        p2x + (perpx * r2),
                        p2y + (perpy * r2));

                continue;
            }

            var px:Number = ((b1 * c2) - (b2 * c1)) / denom;
            var py:Number = ((a2 * c1) - (a1 * c2)) / denom;
            var pdist:Number = ((px - p2x) * (px - p2x)) + ((py - p2y) * (py - p2y));

            if (pdist > (196 * width * width)) {
                perp3x = perpx - perp2x;
                perp3y = perpy - perp2y;

                dist = Math.sqrt((perp3x * perp3x) + (perp3y * perp3y));
                perp3x /= dist;
                perp3y /= dist;
                perp3x *= width;
                perp3y *= width;

                geom.points.push(p2x - (perp3x * r1), p2y - (perp3y * r1));

                geom.points.push(p2x + (perp3x * r2), p2y + (perp3y * r2));

                geom.points.push(p2x - (perp3x * r2 * r1), p2y - (perp3y * r1));

                indexCount++;
            } else {
                geom.points.push(p2x + ((px - p2x) * r1), p2y + ((py - p2y) * r1));
                geom.points.push(p2x - ((px - p2x) * r2), p2y - ((py - p2y) * r2));
            }
        }

        p1x = points[(length - 2) * 2];
        p1y = points[((length - 2) * 2) + 1];

        p2x = points[(length - 1) * 2];
        p2y = points[((length - 1) * 2) + 1];

        perpx = -(p1y - p2y);
        perpy = p1x - p2x;

        dist = Math.sqrt((perpx * perpx) + (perpy * perpy));
        perpx /= dist;
        perpy /= dist;
        perpx *= width;
        perpy *= width;

        geom.points.push(p2x - (perpx * r1), p2y - (perpy * r1));
        geom.points.push(p2x + (perpx * r2), p2y + (perpy * r2));

//        var indices:Array = graphicsGeometry.indices;
//        indices.push(indexStart);
        indexCount -= 2;
        for (i = 0; i < indexCount; ++i) {
//            indices.push(indexStart, indexStart + 1, indexStart + 2);
            geom.indices.push(indexStart, indexStart + 1, indexStart + 2);
            indexStart++;
        }
    }
}
}
