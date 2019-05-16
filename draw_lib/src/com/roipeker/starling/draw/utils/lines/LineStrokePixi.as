// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-16.
//
// =================================================================================================

package com.roipeker.starling.draw.utils.lines {
import com.roipeker.starling.draw.GraphData;
import com.roipeker.starling.draw.GraphGeom;
import com.roipeker.starling.draw.styles.LineStyle;

import flash.display.JointStyle;

import flash.geom.Point;

/**
 *
 * Unfinished implementation (round joins are not accurate) and missing cap styles.
 *
 * Ported from:
 * https://github.com/pixijs/pixi.js/pull/5325
 *
 * Might be available in Pixi v5.1
 *
 */
public class LineStrokePixi {
    public function LineStrokePixi() {
    }

    private static const TOLERANCE:Number = 0.0001;
    private static const PI_LBOUND:Number = Math.PI - TOLERANCE;
    private static const PI_UBOUND:Number = Math.PI + TOLERANCE;
    public static const PI_2:Number = 2 * Math.PI;

    public static function buildLine(graphicsData:GraphData, graphicsGeometry:GraphGeom )
    {
        // TODO OPTIMISE!
        var points:Array = graphicsData.points ;//|| graphicsData.shape.points.slice();
        if (points.length === 0)
        {
            return;
        }
        // if the line width is an odd number add 0.5 to align to a whole pixel
        // commenting this out fixes #711 and #1620
        // if (graphicsData.lineWidth%2)
        // {
        //     for (i = 0; i < points.length; i++)
        //     {
        //         points[i] += 0.5;
        //     }
        // }

        const style:LineStyle = graphicsData.lineStyle;

        // get first and last point.. figure out the middle!
        var firstPoint:Point = new Point(points[0], points[1]);
        var lastPoint:Point = new Point(points[points.length - 2], points[points.length - 1]);

        // if the first point is the last point - gonna have issues :)
        if (firstPoint.x === lastPoint.x && firstPoint.y === lastPoint.y)
        {
            // need to clone as we are going to slightly modify the shape..
            points = points.slice();
            points.pop();
            points.pop();

            lastPoint = new Point(points[points.length - 2], points[points.length - 1]);

            const midPointX:Number = lastPoint.x + ((firstPoint.x - lastPoint.x) * 0.5);
            const midPointY:Number = lastPoint.y + ((firstPoint.y - lastPoint.y) * 0.5);

            points.unshift(midPointX, midPointY);
            points.push(midPointX, midPointY);
        }

        const verts:Array = graphicsGeometry.points;
        const length:int = points.length / 2;
        var indexCount:int = points.length;
        var indexStart:int = verts.length / 2;
        trace(verts);

        // DRAW the Line
        const width:Number = style.width / 2;

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

        var midx:Number = 0;
        var midy:Number = 0;

        var dist12:Number = 0;
        var dist23:Number = 0;
        var distMid:Number = 0;
        var minDist:Number = 0;

        var dist:Number = Math.sqrt((perpx * perpx) + (perpy * perpy));

        perpx /= dist;
        perpy /= dist;
        perpx *= width;
        perpy *= width;

        const ratio:Number = style.alignment;// 0.5;
        const r1:Number = (1 - ratio) * 2;
        const r2:Number = ratio * 2;

        // start
        verts.push(
                p1x - (perpx * r1),
                p1y - (perpy * r1));

        verts.push(
                p1x + (perpx * r2),
                p1y + (perpy * r2));

        for (var i:int = 1; i < length - 1; ++i)
        {
            p1x = points[(i - 1) * 2];
            p1y = points[((i - 1) * 2) + 1];

            p2x = points[i * 2];
            p2y = points[(i * 2) + 1];

            p3x = points[(i + 1) * 2];
            p3y = points[((i + 1) * 2) + 1];

            perpx = -(p1y - p2y);
            perpy = p1x - p2x;

            perp2x = -(p2y - p3y);
            perp2y = p2x - p3x;

            dist = len(perpx, perpy);
            perpx /= dist;
            perpy /= dist;
            perpx *= width;
            perpy *= width;

            dist = len(perp2x, perp2y);
            perp2x /= dist;
            perp2y /= dist;
            perp2x *= width;
            perp2y *= width;

            const a1:Number = p1y - p2y;
            const b1:Number = p2x - p1x;
            const a2:Number = p3y - p2y;
            const b2:Number = p2x - p3x;

            const denom:Number = (a1 * b2) - (a2 * b1);
            const join:String = style.joint;

            var px:Number;
            var py:Number;
            var pdist:Number;

            // parallel or almost parallel ~0 or ~180 deg
            if (Math.abs(denom) < TOLERANCE)
            {
                // bevel, miter or round ~0deg
                if (join !== JointStyle.ROUND || Math.abs(angleDiff(perpx, perpy, perp2x, perp2y)) < TOLERANCE)
                {
                    verts.push(
                            p2x - (perpx * r1),
                            p2y - (perpy * r1)
                    );

                    verts.push(
                            p2x + (perpx * r2),
                            p2y + (perpy * r2)
                    );

                    continue;
                }
                else // round ~180deg
                {
                    px = p2x;
                    py = p2y;
                    pdist = 0;
                }
            }
            else
            {
                const c1:Number = ((-perpx + p1x) * (-perpy + p2y)) - ((-perpx + p2x) * (-perpy + p1y));
                const c2:Number = ((-perp2x + p3x) * (-perp2y + p2y)) - ((-perp2x + p2x) * (-perp2y + p3y));

                px = ((b1 * c2) - (b2 * c1)) / denom;
                py = ((a2 * c1) - (a1 * c2)) / denom;
                pdist = ((px - p2x) * (px - p2x)) + ((py - p2y) * (py - p2y));
            }

            // funky comparison to have backwards compat which will fall back by default to miter
            // TODO: introduce miterLimit
            if (join !== JointStyle.BEVEL && join !== JointStyle.ROUND && pdist <= (196 * width * width))
            {
                verts.push(p2x + ((px - p2x) * r1), p2y + ((py - p2y) * r1));

                verts.push(p2x - ((px - p2x) * r2), p2y - ((py - p2y) * r2));
            }
            else
            {
                const flip:Boolean = shouldFlip(p1x, p1y, p2x, p2y, p3x, p3y);

                dist12 = len(p2x - p1x, p2y - p1y);
                dist23 = len(p3x - p2x, p3y - p2y);
                minDist = Math.min(dist12, dist23);

                if (flip)
                {
                    perpx = -perpx;
                    perpy = -perpy;
                    perp2x = -perp2x;
                    perp2y = -perp2y;

                    midx = (px - p2x) * r1;
                    midy = (py - p2y) * r1;
                    distMid = len(midx, midy);

                    if (minDist < distMid)
                    {
                        midx /= distMid;
                        midy /= distMid;
                        midx *= minDist;
                        midy *= minDist;
                    }

                    midx = p2x - midx;
                    midy = p2y - midy;
                }
                else
                {
                    midx = (px - p2x) * r2;
                    midy = (py - p2y) * r2;
                    distMid = len(midx, midy);

                    if (minDist < distMid)
                    {
                        midx /= distMid;
                        midy /= distMid;
                        midx *= minDist;
                        midy *= minDist;
                    }

                    midx += p2x;
                    midy += p2y;
                }

//                if (join === LINE_JOIN.ROUND)
                if (join === JointStyle.ROUND)
                {
                    const rad = flip ? r1 : r2;

                    // eslint-disable-next-line max-params
                    indexCount += buildRoundCap(midx, midy,
                            p2x + (perpx * rad), p2y + (perpy * rad),
                            p2x + (perp2x * rad), p2y + (perp2y * rad),
                            p3x, p3y,
                            verts,
                            flip);
                }
                else if (join === JointStyle.BEVEL || pdist > (196 * width * width)) // TODO: introduce miterLimit
                {
                    if (flip)
                    {
                        verts.push(p2x + (perpx * r2), p2y + (perpy * r2));
                        verts.push(midx, midy);

                        verts.push(p2x + (perp2x * r2), p2y + (perp2y * r2));
                        verts.push(midx, midy);
                    }
                    else
                    {
                        verts.push(midx, midy);
                        verts.push(p2x + (perpx * r1), p2y + (perpy * r1));

                        verts.push(midx, midy);
                        verts.push(p2x + (perp2x * r1), p2y + (perp2y * r1));
                    }

                    indexCount += 2;
                }
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

        verts.push(p2x - (perpx * r1), p2y - (perpy * r1));

        verts.push(p2x + (perpx * r2), p2y + (perpy * r2));

        const indices:Array = graphicsGeometry.indices;

        // indices.push(indexStart);

        for (i = 0; i < indexCount - 2; ++i)
        {
            indices.push(indexStart, indexStart + 1, indexStart + 2);

            indexStart++;
        }
    }

    private static function len(x:Number, y:Number):Number
    {
        return Math.sqrt((x * x) + (y * y));
    }

    /**
     * Check turn direction. If counterclockwise, we must invert prep vectors, otherwise they point 'inwards' the angle,
     * resulting in funky looking lines.
     *
     * @ignore
     * @private
     * @param {number} p0x - x of 1st point
     * @param {number} p0y - y of 1st point
     * @param {number} p1x - x of 2nd point
     * @param {number} p1y - y of 2nd point
     * @param {number} p2x - x of 3rd point
     * @param {number} p2y - y of 3rd point
     *
     * @returns {boolean} true if perpendicular vectors should be flipped, otherwise false
     */
    private static function shouldFlip(p0x:Number, p0y:Number, p1x:Number, p1y:Number, p2x:Number, p2y:Number):Boolean
    {
        return ((p1x - p0x) * (p2y - p0y)) - ((p2x - p0x) * (p1y - p0y)) < 0;
    }

    private static function angleDiff(p0x:Number, p0y:Number, p1x:Number, p1y:Number):Number
    {
        const angle1:Number = Math.atan2(p0x, p0y);
        const angle2:Number = Math.atan2(p1x, p1y);

        if (angle2 > angle1)
        {
            if ((angle2 - angle1) >= PI_LBOUND)
            {
                return angle2 - PI_2 - angle1;
            }
        }
        else if ((angle1 - angle2) >= PI_LBOUND)
        {
            return angle2 - (angle1 - PI_2);
        }

        return angle2 - angle1;
    }

    private static function buildRoundCap(cx:Number, cy:Number, p1x:Number, p1y:Number, p2x:Number, p2y:Number, nxtPx:Number, nxtPy:Number, verts:Array, flipped:Boolean):int
    {
        const cx2p0x:Number = p1x - cx;
        const cy2p0y:Number = p1y - cy;

        var angle0:Number = Math.atan2(cx2p0x, cy2p0y);
        var angle1:Number = Math.atan2(p2x - cx, p2y - cy);

        var startAngle:Number = angle0;

        if (angle1 > angle0)
        {
            if ((angle1 - angle0) >= PI_LBOUND)
            {
                angle1 = angle1 - PI_2;
            }
        }
        else if ((angle0 - angle1) >= PI_LBOUND)
        {
            angle0 = angle0 - PI_2;
        }

        var angleDiff:Number = angle1 - angle0;
        const absAngleDiff:Number = Math.abs(angleDiff);

        if (absAngleDiff >= PI_LBOUND && absAngleDiff <= PI_UBOUND)
        {
            const r1x:Number = cx - nxtPx;
            const r1y:Number = cy - nxtPy;

            if (r1x === 0)
            {
                if (r1y > 0)
                {
                    angleDiff = -angleDiff;
                }
            }
            else if (r1x >= -TOLERANCE)
            {
                angleDiff = -angleDiff;
            }
        }

        const radius:Number = len(cx2p0x, cy2p0y);
        const segCount:int = ((15 * absAngleDiff * Math.sqrt(radius) / Math.PI) >> 0) + 1;
        const angleInc:Number = angleDiff / segCount;

        startAngle += angleInc;
        var i:int ;
        var angle:Number;
        if (flipped)
        {
            verts.push(p1x, p1y);
            verts.push(cx, cy);

            for (i = 1, angle = startAngle; i < segCount; i++, angle += angleInc)
            {
                verts.push(cx + ((Math.sin(angle) * radius)),
                        cy + ((Math.cos(angle) * radius)));
                verts.push(cx, cy);
            }

            verts.push(p2x, p2y);
            verts.push(cx, cy);
        }
        else
        {
            verts.push(cx, cy);
            verts.push(p1x, p1y);

            for ( i = 1, angle = startAngle; i < segCount; i++, angle += angleInc)
            {
                verts.push(cx, cy);
                verts.push(cx + ((Math.sin(angle) * radius)),
                        cy + ((Math.cos(angle) * radius)));
            }

            verts.push(cx, cy);
            verts.push(cx + ((Math.sin(angle1) * radius)),
                    cy + ((Math.cos(angle1) * radius)));
        }

        return segCount * 2;
    }

}
}
