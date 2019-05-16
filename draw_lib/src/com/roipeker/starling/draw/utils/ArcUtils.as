// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 04/01/2019.
//
//  ported from PixiJS
//  https://github.com/pixijs/pixi.js
//
// =================================================================================================

package com.roipeker.starling.draw.utils {
public class ArcUtils {

    public function ArcUtils() {
    }

    /**
     * The arcTo() method creates an arc/curve between two tangents on the canvas.
     *
     * "borrowed" from https://code.google.com/p/fxcanvas/ - thanks google!
     *
     * @param {number} x1 - The x-coordinate of the beginning of the arc
     * @param {number} y1 - The y-coordinate of the beginning of the arc
     * @param {number} x2 - The x-coordinate of the end of the arc
     * @param {number} y2 - The y-coordinate of the end of the arc
     * @param {number} radius - The radius of the arc
     * @return {object} If the arc length is valid, return center of circle, radius and other info otherwise `null`.
     */
    public static function curveTo(x1:Number, y1:Number, x2:Number, y2:Number, radius:Number, points:Array):Object {
        const fromX:Number = points[points.length - 2];
        const fromY:Number = points[points.length - 1];

        const a1:Number = fromY - y1;
        const b1:Number = fromX - x1;
        const a2:Number = y2 - y1;
        const b2:Number = x2 - x1;
        const mm:Number = Math.abs((a1 * b2) - (b1 * a2));

        if (mm < 1.0e-8 || radius === 0) {
            if (points[points.length - 2] !== x1 || points[points.length - 1] !== y1) {
                points.push(x1, y1);
            }
            return null;
        }

        const dd:Number = (a1 * a1) + (b1 * b1);
        const cc:Number = (a2 * a2) + (b2 * b2);
        const tt:Number = (a1 * a2) + (b1 * b2);
        const k1:Number = radius * Math.sqrt(dd) / mm;
        const k2:Number = radius * Math.sqrt(cc) / mm;
        const j1:Number = k1 * tt / dd;
        const j2:Number = k2 * tt / cc;
        const cx:Number = (k1 * b2) + (k2 * b1);
        const cy:Number = (k1 * a2) + (k2 * a1);
        const px:Number = b1 * (k2 + j1);
        const py:Number = a1 * (k2 + j1);
        const qx:Number = b2 * (k1 + j2);
        const qy:Number = a2 * (k1 + j2);
        const startAngle:Number = Math.atan2(py - cy, px - cx);
        const endAngle:Number = Math.atan2(qy - cy, qx - cx);

        return {
            cx: (cx + x1),
            cy: (cy + y1),
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            anticlockwise: (b1 * a2 > b2 * a1)
        };
    }

    /**
     * The arc method creates an arc/curve (used to create circles, or parts of circles).
     *
     * @param {number} startX - Start x location of arc
     * @param {number} startY - Start y location of arc
     * @param {number} cx - The x-coordinate of the center of the circle
     * @param {number} cy - The y-coordinate of the center of the circle
     * @param {number} radius - The radius of the circle
     * @param {number} startAngle - The starting angle, in radians (0 is at the 3 o'clock position
     *  of the arc's circle)
     * @param {number} endAngle - The ending angle, in radians
     * @param {boolean} anticlockwise - Specifies whether the drawing should be
     *  counter-clockwise or clockwise. False is default, and indicates clockwise, while true
     *  indicates counter-clockwise.
     * @param {number} n - Number of segments
     * @param {number[]} points - Collection of points to add to
     */
    public static function arc(startX:Number, startY:Number, cx:Number, cy:Number, radius:Number,
                               startAngle:Number, endAngle:Number, anticlockwise:Boolean, points:Array):void {
        const sweep:Number = endAngle - startAngle;
        const n:uint = GraphicCurves.segmentsCount(
                Math.abs(sweep) * radius,
                Math.ceil(Math.abs(sweep) / (GraphUtils.PI2)) * 30
        );
        const theta:Number = (sweep) / (n * 2);
        const theta2:Number = theta * 2;
        const cTheta:Number = Math.cos(theta);
        const sTheta:Number = Math.sin(theta);
        const segMinus:Number = n - 1;
        const remainder:Number = (segMinus % 1) / segMinus;
        for (var i:int = 0; i <= segMinus; ++i) {
            var real:Number = i + (remainder * i);
            var angle:Number = ((theta) + startAngle + (theta2 * real));
            var c:Number = Math.cos(angle);
            var s:Number = -Math.sin(angle);
            points.push(
                    (((cTheta * c) + (sTheta * s)) * radius) + cx,
                    (((cTheta * -s) + (sTheta * c)) * radius) + cy
            );
        }
    }
}
}
