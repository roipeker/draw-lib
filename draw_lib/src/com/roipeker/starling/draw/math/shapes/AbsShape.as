// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.math.shapes {
import starling.utils.StringUtil;

public class AbsShape {

    public var holes:Array;
    protected var _type:ShapeType;

    public function AbsShape(type:ShapeType) {
        _type = type;
        holes = [];
    }

    public function get type():ShapeType {
        return _type;
    }

    // todo: add return pool...

    public function reset():void {
        holes.length = 0;
    }

    public function toString():String {
        return StringUtil.format("[AbsShape type={0}]", _type);
    }
}
}
