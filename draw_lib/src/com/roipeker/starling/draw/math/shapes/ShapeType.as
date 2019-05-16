// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.math.shapes {
import starling.utils.StringUtil;

public class ShapeType {

    public static const CIRC:ShapeType = new ShapeType("CIRC");
    public static const ELIP:ShapeType = new ShapeType("ELIP");
    public static const RECT:ShapeType = new ShapeType("RECT");
    public static const RRECT:ShapeType = new ShapeType("RRECT");
    public static const POLY:ShapeType = new ShapeType("POLY");
    public static const TRI:ShapeType = new ShapeType("TRI");

    public static function equals(shapeA:ShapeType, shapeB:ShapeType):Boolean {
        return shapeA == shapeB;
    }

    private var _type:String;

    public function ShapeType(type:String = null) {
        _type = type;
    }

    public function toString():String {
        return StringUtil.format("[ShapeType type={0}]", _type);
    }

    public function isCircle():Boolean {
        return this == ShapeType.CIRC;
    }

    public function isEllipse():Boolean {
        return this == ShapeType.ELIP;
    }

    public function isPolygon():Boolean {
        return this == ShapeType.POLY;
    }

    public function isRectangle():Boolean {
        return this == ShapeType.RECT;
    }

    public function isRoundRectangle():Boolean {
        return this == ShapeType.RRECT;
    }

    public function isTri():Boolean {
        return this == ShapeType.TRI;
    }

    public function get type():String {
        return _type;
    }
}
}
