// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.math.shapes {
import starling.utils.StringUtil;

public class Ellipse extends AbsShape {

    // TODO: add pool.

    public var x:Number;
    public var y:Number;
    public var halfW:Number;
    public var halfH:Number;

    public function Ellipse(x:Number = 0, y:Number = 0, halfW:Number = 0, halfH:Number = 0) {
        this.x = x;
        this.y = y;
        this.halfW = halfW;
        this.halfH = halfH;
        super(ShapeType.ELIP);
    }

    public function clone():Ellipse {
        return new Ellipse(x, y, halfW, halfH);
    }

    public function contains(x:Number, y:Number):Boolean {
        if (halfW <= 0 || halfH <= 0) return false;
        var normx:Number = (x - this.x) / halfW;
        var normy:Number = (x - this.y) / halfH;
        return normx * normx + normy * normy <= 1;
    }

    public function getBounds():Rect {
        return new Rect(x - halfW, y - halfH, halfW, halfH);
    }

    override public function toString():String {
        return StringUtil.format("[Ellipse x={0}, y={1}, half_width={2}, half_height={3}]", x, y, halfW, halfH);
    }
}
}
