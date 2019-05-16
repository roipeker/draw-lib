// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 10/01/2019.
//
// =================================================================================================

package com.roipeker.starling.draw.utils.lines {
public class Pnt {

    public var x:Number;
    public var y:Number;

    public function key():String {
        return x + 'x' + y;
    }

    public function Pnt(x:Number = 0, y:Number = 0) {
        this.x = x;
        this.y = y;
    }

    public function scalarMult(f:Number):Pnt {
        this.x *= f;
        this.y *= f;
        return this;
    }

    public function perpendicular():Pnt {
        var x:Number = this.x;
        this.x = -this.y;
        this.y = x;
        return this;
    }

    public function toString():String {
        return 'Pnt: x=' + x + ' y=' + y;
    }

    public function invert():Pnt {
        this.x = -this.x;
        this.y = -this.y;
        return this;
    }

    [Inline]
    public final function length():Number {
        return Math.sqrt(this.x * this.x + this.y * this.y);
    }

    public function normalize():Pnt {
        var mod:Number = this.length();
        this.x /= mod;
        this.y /= mod;
        return this;
    }

    [Inline]
    public final function angle():Number {
        return this.y / this.x;
    }

    [Inline]
    public static function Angle(p0:Pnt, p1:Pnt):Number {
        return Math.atan2(p1.x - p0.x, p1.y - p0.y);
    }

    public static function Add(p0:Pnt, p1:Pnt):Pnt {
        return new Pnt(p0.x + p1.x, p0.y + p1.y);
    }

    public static function Sub(p1:Pnt, p0:Pnt):Pnt {
        return new Pnt(p1.x - p0.x, p1.y - p0.y);
    }

    public static function Middle(p0:Pnt, p1:Pnt):Pnt {
        return Add(p0, p1).scalarMult(.5);
    }

}
}
