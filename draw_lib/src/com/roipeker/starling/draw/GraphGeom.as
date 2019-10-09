// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
//  ported from PixiJS
//  https://github.com/pixijs/pixi.js
//
// =================================================================================================

package com.roipeker.starling.draw {
import com.roipeker.starling.draw.builders.AbsShapeBuilder;
import com.roipeker.starling.draw.math.shapes.AbsShape;
import com.roipeker.starling.draw.math.shapes.ShapeType;
import com.roipeker.starling.draw.styles.FillStyle;
import com.roipeker.starling.draw.styles.LineStyle;
import com.roipeker.starling.draw.utils.GraphUtils;

import flash.geom.Matrix;

import starling.textures.Texture;

public class GraphGeom {

    private var _shapesData:Array;
    private var _dirty:int = 0;
    private var _cacheDirty:int = -1;

    public var points:Array;
    public var indices:Array;
    public var colors:Array;
    public var gradients:Array;

    // todo: remove this "globals" props when supporting batching or/and multiple Meshes rendering.
    public var texture:Texture;
    public var textureRepeat:Boolean;

    public var uvs:Array;

    public function GraphGeom() {
        points = [];
        indices = [];
        colors = [];
        gradients = [];
        uvs = [];
        _shapesData = [];
    }

    public function drawHole(shape:AbsShape, matrix:Matrix):GraphData {
        if (!_shapesData.length) return null;
        const shapeData:GraphData = new GraphData(shape, null, null, matrix);
        const lastShapeData:GraphData = _shapesData[int(_shapesData.length - 1)];
        lastShapeData.holes.push(shapeData);
        _dirty++;
        return shapeData;
    }

    public function drawShape(shape:AbsShape, fillStyle:FillStyle, lineStyle:LineStyle, matrix:Matrix):GraphGeom {
        const shapeData:GraphData = new GraphData(shape, fillStyle, lineStyle, matrix);
        _shapesData[_shapesData.length] = shapeData;
        _dirty++;
        return this;
    }

    public function calculate():void {
        if (_dirty == _cacheDirty) return;

        _cacheDirty = _dirty;
        const shapes:Array = _shapesData;
        var currentColor:uint = 0xFFFFFF;
        var currentAlpha:Number = 1;

        texture = null;
        textureRepeat = false;

        this.uvs.length = 0;
        this.points.length = 0;
        this.indices.length = 0;
        this.colors.length = 0;
        this.gradients.length = 0;

        for (var i:int = 0, ilen:int = shapes.length; i < ilen; i++) {
            const shapeData:GraphData = _shapesData[i];
            const command:AbsShapeBuilder = AbsShapeBuilder.get(shapeData.type);
            command.build(shapeData);
            if (shapeData.matrix) {
                transformPoints(shapeData.points, shapeData.matrix);
            }

            var fillStyle:FillStyle = shapeData.fillStyle;
            var lineStyle:FillStyle = shapeData.lineStyle;

            // trick to toggle fill/line.
            for (var j:int = 0; j < 2; j++) {
                var style:FillStyle = j == 0 ? fillStyle : lineStyle;
                if (!style.visible) continue;
                if (style.color != currentColor || style.alpha != currentAlpha) {
                    currentColor = style.color;
                    currentAlpha = style.alpha;
                }
                const start:int = points.length >> 1;
                if (j == 0) {
                    if (shapeData.holes.length) {
                        processHoles(shapeData.holes);
                        AbsShapeBuilder.get(ShapeType.POLY).triangulate(shapeData, this);
                    } else {
                        command.triangulate(shapeData, this);
                    }
                } else {
                    GraphUtils.resolveLine(shapeData, this);
                }
                const size:int = (points.length >> 1) - start;

                if (style.gradient && style.gradient.visible) {
                    gradients.push(
                            start,
                            start + size,
                            style.gradient.color1, style.gradient.color2,
                            style.gradient.angle,
                            style.gradient.alpha1, style.gradient.alpha2
                    );
                } else {
                    colors.push(
                            start,
                            size,
                            currentColor,
                            currentAlpha
                    );
                }
                texture = style.texture;
                textureRepeat = style.textureRepeat;
                if (style.texture) {
                    addUvs(points, uvs, style.texture, start, size, style.matrix);
                }
            }
        }
    }

    private function addUvs(verts:Array, uvs:Array, texture:Texture, start:int, size:int, matrix:Matrix):void {
        var index:int = 0;
        while (index < size) {
            var x:Number = verts[(start + index) * 2];
            var y:Number = verts[((start + index) * 2) + 1];
            if (matrix) {
                const nx:Number = (matrix.a * x) + (matrix.c * y) + matrix.tx;
                y = (matrix.b * x) + (matrix.d * y) + matrix.ty;
                x = nx;
            }
            index++;
            uvs.push(x / texture.width, y / texture.height);
        }

        // TODO: adjust UVS for textureAtlases.
        // check if it works.
        trace(texture.frame);
        if ( texture.frame && ( texture.frame.width < texture.width || texture.frame.height < texture.height )) {
            adjustUvs(uvs, texture, uvs.length, size);
        }
    }

    private function adjustUvs(uvs:Array, texture:Texture, start:int, size:int) {
        const eps:Number = 1e-6;
        const finish:int = start + (size * 2);
        const frame:flash.geom.Rectangle = texture.frame;
        const scaleX:Number = frame.width / texture.width;
        const scaleY:Number = frame.height / texture.height;
        var offsetX:Number = frame.x / frame.width;
        var offsetY:Number = frame.y / frame.height;
        var minX:int = Math.floor(uvs[start] + eps);
        var minY:int = Math.floor(uvs[start + 1] + eps);
        for (var i:int = start + 2; i < finish; i += 2) {
            minX = Math.min(minX, Math.floor(uvs[i] + eps));
            minY = Math.min(minY, Math.floor(uvs[i + 1] + eps));
        }
        offsetX -= minX;
        offsetY -= minY;
        for (i = start; i < finish; i += 2) {
            uvs[i] = (uvs[i] + offsetX) * scaleX;
            uvs[i + 1] = (uvs[i + 1] + offsetY) * scaleY;
        }
    }

    private function transformPoints(points:Array, matrix:Matrix):void {
        /*var x:Number, y:Number, idx:int;
        for (var i:int = 0, len:uint = points.length >> 1; i < len; i++) {
            idx = i * 2;
            x = points[idx];
            y = points[idx + 1];
            points[idx] = (matrix.a * x) + (matrix.c * y) + matrix.tx;
            points[idx + 1] = (matrix.b * x) + (matrix.d * y) + matrix.ty;
            /!*points[idx] += matrix.tx;
            points[idx + 1] += matrix.ty;*!/
        }*/

        const len:int = points.length / 2;
        for (var i:int = 0; i < len; i++) {
            const x:Number = points[(i * 2)];
            const y:Number = points[(i * 2) + 1];

            points[(i * 2)] = (matrix.a * x) + (matrix.c * y) + matrix.tx;
            points[(i * 2) + 1] = (matrix.b * x) + (matrix.d * y) + matrix.ty;
        }
    }

    private function processHoles(holes:Array):void {
        for (var i:int = 0, ilen:int = holes.length; i < ilen; i++) {
            var command:AbsShapeBuilder = AbsShapeBuilder.get(holes[i].type);
            command.build(holes[i]);
            if (holes[i].matrix) {
                transformPoints(holes[i].points, holes[i].matrix);
            }
        }
    }

    public function clear():GraphGeom {
        if (_shapesData.length > 0) {
            // TODO: return shapesData objects to pool.
            _dirty++;
            _shapesData.length = 0;
            uvs.length = 0;
            texture = null;
            points.length = 0;
            indices.length = 0;
            colors.length = 0;
            gradients.length = 0;
        }
        return this;
    }

    public function clone():GraphGeom {
        var output:GraphGeom = new GraphGeom();
        output._shapesData = _shapesData.concat();
        output.points = points.concat();
        output.indices = indices.concat();
        output.colors = colors.concat();
        output.gradients = gradients.concat();
        return output;
    }

    public function dispose():void {
        clear();
        _shapesData = null;
        points = null;
        uvs = null;
        indices = null;
        colors = null;
        gradients = null;
    }
}
}
