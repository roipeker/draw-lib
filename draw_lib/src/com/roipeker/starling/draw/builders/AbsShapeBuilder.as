// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.builders {
import com.roipeker.starling.draw.GraphData;
import com.roipeker.starling.draw.GraphGeom;
import com.roipeker.starling.draw.math.shapes.ShapeType;

import flash.utils.Dictionary;

public class AbsShapeBuilder {


    private static var _map:Dictionary;

    private static function init():void {
        if (_map) return;
        _map = new Dictionary(false);
        _map[ShapeType.RECT] = new RectBuilder();
        _map[ShapeType.RRECT] = new RoundRectBuilder();
        _map[ShapeType.ELIP] = _map[ShapeType.CIRC] = new CircleBuilder();
        _map[ShapeType.POLY] = new PolyBuilder();
        _map[ShapeType.TRI] = new MeshBuilder();
    }

    public static function get(type:ShapeType):AbsShapeBuilder {
        if (!_map) init();
        return _map[type];
    }

    /**
     * Abstract class.
     */
    public function AbsShapeBuilder() {
    }

    public function build(shapeData:GraphData):void {
    }

    public function triangulate(shapeData:GraphData, geometry:GraphGeom):void {
    }
}
}
