// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.math.shapes {
import starling.utils.StringUtil;

public class RoundRect extends AbsShape {

    public static function get empty():RoundRect {
        return new RoundRect();
    }

    public var x:Number;
    public var y:Number;
    public var w:Number;
    public var h:Number;
    public var tlr:Number;
    public var trr:Number;
    public var blr:Number;
    public var brr:Number;

    public function RoundRect(x:Number = 0, y:Number = 0, w:Number = 0, h:Number = 0, tlr:Number = 10, trr:Number = 10, blr:Number = 10, brr:Number = 10) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.tlr = tlr;
        this.trr = trr;
        this.blr = blr;
        this.brr = brr;
        adjustRadius();
        super(ShapeType.RRECT);
    }

    private final function adjustRadius():void {
        if (trr < 0) trr = tlr;
        if (blr < 0) blr = tlr;
        if (brr < 0) brr = tlr;
    }

    public function clone():RoundRect {
        return new RoundRect(x, y, w, h, tlr, trr, blr, brr);
    }

    // not used.
    // TODO: add all rect corners checks.
    public function contains(px:Number, py:Number):Boolean {
        if (w <= 0 || h <= 0) return false;
        if (px >= x && px < x + w) {
            if (py >= y && py < y + h) {
                if ((py >= y + tlr && py <= y + h - tlr) ||
                        (px >= x + tlr && px <= x + w - tlr)) {
                    return true;
                }
                var dx:Number = px - (x + tlr);
                var dy:Number = py - (y + tlr);
                const radius2:Number = tlr * tlr;
                if ((dx * dx + dy * dy) <= radius2) return true;
                dx = px - (x + w - radius2);
                if ((dx * dx + dy * dy) <= radius2) return true;
                dy = py - (y + h - radius2);
                if ((dx * dx + dy * dy) <= radius2) return true;
                dx = px - (x + tlr);
                if ((dx * dx + dy * dy) <= radius2) return true;
            }
        }
        return false;
    }

    override public function toString():String {
        return StringUtil.format("[RoundRect x={0}, y={1}, halfW={2}, halfH={3}, radius={4}]", x, y, w, h, tlr);
    }

}
}
