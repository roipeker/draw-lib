// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 03/01/2019.
//
// =================================================================================================

package com.roipeker.starling.draw.math.shapes {
import starling.utils.StringUtil;

// TODO: doesn't work well with lineStyle.

public class MeshShape extends AbsShape {

    /*private static const _pool:Vector.<MeshShape> = new Vector.<MeshShape>();
    public static function put(obj:MeshShape):void {
        if (obj) {
            obj.indices = null;
            obj.vertices = null;
            obj.uvs = null;
            _pool[_pool.length] = obj;
        }
    }

    public static function get(vertices:Vector.<Number>, indices:Vector.<int> = null, uvs:Array = null):MeshShape {
        if (_pool.length == 0) return new MeshShape(vertices, indices, uvs);
        var obj:MeshShape = _pool.pop();
        obj.vertices = vertices;
        obj.indices = indices;
        obj.uvs = uvs;
        return obj;
    }*/

    /*public static function get(vertices:Array, indices:Array, uvs:Array):MeshShape {
        return new MeshShape(vertices, indices, uvs);
    }*/

    public static function get empty():MeshShape {
        return new MeshShape();
    }

    public var vertices:Vector.<Number>;
    public var indices:Vector.<int>;
    public var uvs:Array;

    /**
     * @param vertices
     * @param indices
     * @param uvs
     */
    public function MeshShape(vertices:Vector.<Number> = null, indices:Vector.<int> = null, uvs:Array = null) {
        this.vertices = vertices;
        this.indices = indices;
        this.uvs = uvs;
        super(ShapeType.TRI);
    }

    public function clone():MeshShape {
        return new MeshShape(vertices, indices, uvs);
    }

    public function copyFrom(rect:MeshShape):MeshShape {
        vertices = rect.vertices;
        indices = rect.indices;
        uvs = rect.uvs;
        return this;
    }

    override public function toString():String {
        return StringUtil.format(
                '[ MeshShape vertices={0}, indices={1}, uvs={2} ]', vertices, indices, uvs);
    }
}
}
