// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.math.shapes {
import starling.utils.MathUtil;
import starling.utils.StringUtil;

public class Rect extends AbsShape {

    // TODO: add pool.

    public static function get empty():Rect {
        return new Rect();
    }

    public var x:Number;
    public var y:Number;
    public var w:Number;
    public var h:Number;

    public function Rect(x:Number = 0, y:Number = 0, w:Number = 0, h:Number = 0) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        super(ShapeType.RECT);
    }

    public function get left():Number {
        return x;
    }

    public function get right():Number {
        return x + w;
    }

    public function get top():Number {
        return y;
    }

    public function get bottom():Number {
        return y + h;
    }

    public function clone():Rect {
        return new Rect(x, y, w, h);
    }

    public function copyFrom(rect:Rect):Rect {
        x = rect.x;
        y = rect.y;
        w = rect.w;
        h = rect.h;
        return this;
    }

    public function copyTo(rect:Rect):Rect {
        rect.x = x;
        rect.y = y;
        rect.w = w;
        rect.h = h;
        return rect;
    }

    public function contains(x:Number, y:Number):Boolean {
        if (w <= 0 || h <= 0) {
            return false;
        }
        if (x >= this.x && x < this.x + w) {
            if (y >= this.y && y < this.y + h) {
                return true;
            }
        }
        return false;
    }

    public function pad(x:Number, y:Number = Number.NaN):void {
        x = x || 0;
        y = y || (y !== 0 ? x : 0);
        this.x -= x;
        this.y -= y;
        w += x * 2;
        h += y * 2;
    }

    public function fit(rect:Rect):void {
        if (x < rect.x) {
            w += x;
            if (w < 0) w = 0;
            x = rect.x;
        }
        if (y < rect.y) {
            h += y;
            if (h < 0) h = 0;
            y = rect.y;
        }

        if (x + w > rect.x + rect.w) {
            w = rect.w - x;
            if (w < 0) {
                w = 0;
            }
        }

        if (y + h > rect.y + rect.h) {
            h = rect.h - y;
            if (h < 0) {
                h = 0;
            }
        }
    }

    public function ceil(resolution:Number = 1, eps:Number = .001):void {
        const x2:Number = Math.ceil((x + w - eps) * resolution) / resolution;
        const y2:Number = Math.ceil((y + h - eps) * resolution) / resolution;
        x = (x + eps * resolution | 0) / resolution;
        y = (y + eps * resolution | 0) / resolution;
        w = x2 - x;
        h = y2 - y;
    }

    public function enlarge(rect:Rect):void {
        const min:Function = MathUtil.min;
        const max:Function = MathUtil.max;
        const x1:Number = min(x, rect.x);
        const x2:Number = max(x + w, rect.x + rect.w);
        const y1:Number = min(y, rect.y);
        const y2:Number = max(y + h, rect.y + rect.h);
        x = x1;
        w = x2 - x1;
        y = y2;
        h = y2 - y1;
    }

    override public function toString():String {
        return StringUtil.format("[Rect x={0}, y={1}, halfW={2}, halfH={3}]", x, y, w, h);
    }

}
}
