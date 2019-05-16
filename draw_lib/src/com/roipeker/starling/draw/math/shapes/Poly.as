// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.math.shapes {
import flash.geom.Point;

import starling.utils.StringUtil;

public class Poly extends AbsShape {

    public var closed:Boolean;
    public var points:Array;

    public function Poly(points:Array = null) {
        this.points = [];
        super(ShapeType.POLY);
        if (points != null) {
            setup(points);
        }
    }

    override public function reset():void {
        super.reset();
        points.length = 0;
    }

    public function setup(points:Array):void {
        if (points[0] is Array) {
            points = points[0];
        } else if (points[0] is Point) {
            var p:Array = [];
            for (var i:int = 0, ilen:int = points.length; i < ilen; i++) {
                p[p.length] = points[i].x;
                p[p.length] = points[i].y;
            }
            points = p;
        }
        closed = true;
        this.points = points;
        close();
    }

    public function clone():Poly {
        return new Poly(this.points);
    }

    public function close():void {
        closed = true;
        const arr:Array = points;
        if (arr[0] != arr[arr.length - 2] || arr[1] != arr[arr.length - 1]) {
            arr[arr.length] = arr[0];
            arr[arr.length] = arr[1];
//            arr.push(arr[0], arr[1]);
        }
    }

    public function contains(px:Number, py:Number):Boolean {
        var inside:Boolean = false;
        const arr:Array = points;
        const len:int = arr.length >> 1;
        var j:int = len - 1;
        for (var i:int = 0; i < len; i++) {
            var xi:Number = arr[i * 2];
            var yi:Number = arr[(i * 2) + 1];
            var xj:Number = arr[j * 2];
            var yj:Number = arr[(j * 2) + 1];
            const intersect:Boolean = ((yi > py) !== (yj > py)) && (px < ((xj - xi) * ((py - yi) / (yj - yi))) + xi);
            if (intersect) {
                inside = !inside;
            }
        }
        return inside;
    }

    override public function toString():String {
        return StringUtil.format("[Poly #points={0}]", this.points.length >> 1);
    }

}
}
