// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 04/01/2019.
//
//  ported from PixiJS
//  https://github.com/pixijs/pixi.js
//
// =================================================================================================

package com.roipeker.starling.draw.utils {
public class BezierUtils {
    public function BezierUtils() {
    }


    /**
     * Utilities for bezier curves
     * @class
     * @private
     */
    /**
     * Calculate length of bezier curve.
     * Analytical solution is impossible, since it involves an integral that does not integrate in general.
     * Therefore numerical solution is used.
     *
     * @private
     * @param {number} fromX - Starting point x
     * @param {number} fromY - Starting point y
     * @param {number} cpX - Control point x
     * @param {number} cpY - Control point y
     * @param {number} cpX2 - Second Control point x
     * @param {number} cpY2 - Second Control point y
     * @param {number} toX - Destination point x
     * @param {number} toY - Destination point y
     * @return {number} Length of bezier curve
     */
    public static function curveLength(fromX:Number, fromY:Number, cpX:Number, cpY:Number, cpX2:Number, cpY2:Number, toX:Number, toY:Number):Number {
        const n:uint = 10;
        var result:Number = 0.0;
        var t:Number = 0.0;
        var t2:Number = 0.0;
        var t3:Number = 0.0;
        var nt:Number = 0.0;
        var nt2:Number = 0.0;
        var nt3:Number = 0.0;
        var x:Number = 0.0;
        var y:Number = 0.0;
        var dx:Number = 0.0;
        var dy:Number = 0.0;
        var prevX:Number = fromX;
        var prevY:Number = fromY;

        for (var i:int = 1; i <= n; ++i) {
            t = i / n;
            t2 = t * t;
            t3 = t2 * t;
            nt = (1.0 - t);
            nt2 = nt * nt;
            nt3 = nt2 * nt;

            x = (nt3 * fromX) + (3.0 * nt2 * t * cpX) + (3.0 * nt * t2 * cpX2) + (t3 * toX);
            y = (nt3 * fromY) + (3.0 * nt2 * t * cpY) + (3 * nt * t2 * cpY2) + (t3 * toY);
            dx = prevX - x;
            dy = prevY - y;
            prevX = x;
            prevY = y;
            result += Math.sqrt((dx * dx) + (dy * dy));
        }
        return result;
    }

    /**
     * Calculate the points for a bezier curve and then draws it.
     *
     * @param {number} cpX - Control point x
     * @param {number} cpY - Control point y
     * @param {number} cpX2 - Second Control point x
     * @param {number} cpY2 - Second Control point y
     * @param {number} toX - Destination point x
     * @param {number} toY - Destination point y
     * @param {number[]} points - Path array to push points into
     */
    public static function curveTo(cpX:Number, cpY:Number, cpX2:Number, cpY2:Number, toX:Number, toY:Number, points:Array):void {
        var fromX:Number = points[points.length - 2];
        var fromY:Number = points[points.length - 1];
        points.length -= 2;
        var n:uint = GraphicCurves.segmentsCount(
                BezierUtils.curveLength(fromX, fromY, cpX, cpY, cpX2, cpY2, toX, toY)
        );
//        trace("curve Segment count:", n, GraphicCurves.adaptive, GraphicCurves.maxLength );
        var dt:Number = 0;
        var dt2:Number = 0;
        var dt3:Number = 0;
        var t2:Number = 0;
        var t3:Number = 0;

        points.push(fromX, fromY);

        for (var i:uint = 1, j:Number = 0; i <= n; ++i) {
            j = i / n;

            dt = (1 - j);
            dt2 = dt * dt;
            dt3 = dt2 * dt;

            t2 = j * j;
            t3 = t2 * j;
            points.push(
                    (dt3 * fromX) + (3 * dt2 * j * cpX) + (3 * dt * t2 * cpX2) + (t3 * toX),
                    (dt3 * fromY) + (3 * dt2 * j * cpY) + (3 * dt * t2 * cpY2) + (t3 * toY)
            );
        }
    }

}
}
