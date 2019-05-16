// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
//  ported from PixiJS
//  https://github.com/pixijs/pixi.js
//
// =================================================================================================

package com.roipeker.starling.draw {
import com.roipeker.starling.draw.math.shapes.AbsShape;
import com.roipeker.starling.draw.math.shapes.ShapeType;
import com.roipeker.starling.draw.styles.FillStyle;
import com.roipeker.starling.draw.styles.LineStyle;

import flash.geom.Matrix;

import starling.utils.StringUtil;

public class GraphData {

    // TODO: add pool

    public var shape:AbsShape;
    public var fillStyle:FillStyle;
    public var lineStyle:LineStyle;
    public var matrix:Matrix;
    public var type:ShapeType;
    public var points:Array;
    public var holes:Array;

    public function GraphData(shape:AbsShape, fillStyle:FillStyle = null, lineStyle:LineStyle = null, matrix:Matrix = null) {
        this.shape = shape;
        this.fillStyle = fillStyle;
        this.lineStyle = lineStyle;
        this.matrix = matrix;
        type = shape.type;
        points = [];
        holes = [];
    }

    public function reset():void {
        // TODO: when add pool to holes, check if contains graphData.
        /*for (var i:int = 0, ilen:int = holes.length; i < ilen; i++) {
            holes[i].reset();
        }*/
        // return pool
        fillStyle.reset();
        lineStyle.reset();
        shape.reset();
        points.length = 0;
        holes.length = 0;
    }

    public function clone():GraphData {
        return new GraphData(shape, fillStyle, lineStyle, matrix);
    }

    public function dispose():void {
        reset();
        shape = null;
        holes = null;
        points = null;
        lineStyle = null;
        fillStyle = null;
        matrix = null;
    }

    public function toString():String {
        return StringUtil.format("[GraphData type={0}\nfill_style={1}\nline_style={2}\nshape={3}]",
                type, fillStyle, lineStyle, shape);
    }
}
}
