// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.math.shapes {
import com.roipeker.starling.draw.utils.GraphUtils;

import starling.utils.StringUtil;

public class StarPoly extends Poly {

    // TODO: add pool.

    public function StarPoly(x:Number, y:Number, points:int, radius:Number, innerRadius:Number = 0, rotation:Number = 0) {
        innerRadius = innerRadius || radius / 2;
        var startAngle:Number = (-1 * Math.PI / 2) + rotation;
        var len:int = points * 2;
        var delta:Number = GraphUtils.PI2 / len;
        var polygon:Array = [];
        for (var i:int = 0; i < len; i++) {
            const r:Number = i % 2 ? innerRadius : radius;
            const a:Number = (i * delta) + startAngle;
            polygon.push(
                    x + (r * Math.cos(a)),
                    y + (r * Math.sin(a))
            );
        }
        super(polygon);
    }

    override public function toString():String {
        return StringUtil.format("[StarPoly #points={0}]", points.length);
    }
}
}
