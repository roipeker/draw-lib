// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.math.shapes {
import starling.utils.StringUtil;

public class Circle extends AbsShape {

    // TODO: add pool.

    public var x:Number;
    public var y:Number;
    public var radius:Number;

    public function Circle(x:Number = 0, y:Number = 0, radius:Number = 0) {
        this.x = x;
        this.y = y;
        this.radius = radius;
        super(ShapeType.CIRC);
    }

    public function clone():Circle {
        return new Circle(x, y, radius);
    }

    public function contains(x:Number, y:Number):Boolean {
        if (radius <= 0) return false;
        const r2:Number = radius * radius;
        const dx:Number = x - this.x;
        const dy:Number = y - this.y;
        return dx * dx + dy * dy <= r2;
    }

    public function getBounds():Rect {
        return new Rect(x - radius, y - radius, radius * 2, radius * 2);
    }

    override public function toString():String {
        return StringUtil.format("[Circle x={0}, y={1}, radius={2}]", x, y, radius);
    }
}
}
