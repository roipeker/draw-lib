// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 04/01/2019.
//
//  ported from PixiJS
//  https://github.com/pixijs/pixi.js
//
// =================================================================================================

package com.roipeker.starling.draw.utils {
public class QuadraticUtils {
    public function QuadraticUtils() {
    }

    /**
     * Calculate length of quadratic curve
     * @see {@link http://www.malczak.linuxpl.com/blog/quadratic-bezier-curve-length/}
     * for the detailed explanation of math behind this.
     *
     * @private
     * @param {number} fromX - x-coordinate of curve start point
     * @param {number} fromY - y-coordinate of curve start point
     * @param {number} cpX - x-coordinate of curve control point
     * @param {number} cpY - y-coordinate of curve control point
     * @param {number} toX - x-coordinate of curve end point
     * @param {number} toY - y-coordinate of curve end point
     * @return {number} Length of quadratic curve
     */
    public static function quadraticBezierLength(p0x:Number, p0y:Number, p1x:Number, p1y:Number, p2x:Number, p2y:Number):Number {
        var ax:Number = p0x - 2 * p1x + p2x;
        var ay:Number = p0y - 2 * p1y + p2y;
        var bx:Number = 2 * p1x - 2 * p0x;
        var by:Number = 2 * p1y - 2 * p0y;
        var A:Number = 4 * (ax * ax + ay * ay);
        var B:Number = 4 * (ax * bx + ay * by);
        var C:Number = bx * bx + by * by;
        var Sabc:Number = 2 * Math.sqrt(A + B + C);
        var A_2:Number = Math.sqrt(A);
        var A_32:Number = 2 * A * A_2;
        var C_2:Number = 2 * Math.sqrt(C);
        var BA:Number = B / A_2;
        return (A_32 * Sabc + A_2 * B * (Sabc - C_2) + (4 * C * A - B * B) * Math.log((2 * A_2 + BA + Sabc) / (BA + C_2))) / (4 * A_32);
    }

    /**
     * Calculate the points for a quadratic bezier curve and then draws it.
     * Based on: https://stackoverflow.com/questions/785097/how-do-i-implement-a-bezier-curve-in-c
     *
     * @param {number} cpX - Control point x
     * @param {number} cpY - Control point y
     * @param {number} toX - Destination point x
     * @param {number} toY - Destination point y
     * @param {number[]} points - Points to add segments to.
     */
    public static function curveTo(cpX:Number, cpY:Number, toX:Number, toY:Number, points:Array):void {
        var fromX:Number = points[points.length - 2];
        var fromY:Number = points[points.length - 1];
        const n:uint = GraphicCurves.segmentsCount(
                QuadraticUtils.quadraticBezierLength(fromX, fromY, cpX, cpY, toX, toY)
        );
        var xa:Number = 0;
        var ya:Number = 0;
        var j:Number;
        for (var i:int = 1; i <= n; ++i) {
            j = i / n;
            xa = fromX + ((cpX - fromX) * j);
            ya = fromY + ((cpY - fromY) * j);
            points.push(xa + (((cpX + ((toX - cpX) * j)) - xa) * j),
                    ya + (((cpY + ((toY - cpY) * j)) - ya) * j));
        }
    }
}
}

