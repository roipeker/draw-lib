// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
//  Core implementation ported from PixiJS
//  https://github.com/pixijs/pixi.js
//
// =================================================================================================

package com.roipeker.starling.draw {
import com.roipeker.starling.draw.builders.GraphicsDataBuild;
import com.roipeker.starling.draw.math.shapes.AbsShape;
import com.roipeker.starling.draw.math.shapes.Circle;
import com.roipeker.starling.draw.math.shapes.Ellipse;
import com.roipeker.starling.draw.math.shapes.MeshShape;
import com.roipeker.starling.draw.math.shapes.Poly;
import com.roipeker.starling.draw.math.shapes.Rect;
import com.roipeker.starling.draw.math.shapes.RoundRect;
import com.roipeker.starling.draw.math.shapes.StarPoly;
import com.roipeker.starling.draw.styles.FillStyle;
import com.roipeker.starling.draw.styles.LineStyle;
import com.roipeker.starling.draw.utils.ArcUtils;
import com.roipeker.starling.draw.utils.BezierUtils;
import com.roipeker.starling.draw.utils.GraphUtils;
import com.roipeker.starling.draw.utils.QuadraticUtils;

import flash.display.CapsStyle;
import flash.display.GraphicsPathCommand;
import flash.display.IGraphicsData;
import flash.display.JointStyle;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import starling.core.Starling;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.filters.FragmentFilter;
import starling.rendering.IndexData;
import starling.rendering.VertexData;
import starling.textures.RenderTexture;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.MathUtil;
import starling.utils.Padding;

public class Draw extends Sprite {

    public static const VERSION:String = '1.0.2';

    private var _mesh:AbsMesh;
    private var _geom:GraphGeom;
    protected var _fillStyle:FillStyle;
    protected var _lineStyle:LineStyle;
    private var vd:VertexData;
    private var id:IndexData;

    private var currentPath:Poly;
    protected var _holeMode:Boolean;

    protected var _matrix:Matrix;

    private var _invalidating:Boolean;

    // uses Juggler invalidation to delay all calls.
    public var useInvalidation:Boolean;

    private var _cacheAsBitmap:Boolean = false;
    private var _cacheFilter:FragmentFilter;

    public function set cacheAsBitmap(flag:Boolean):void {
        if (_cacheAsBitmap == flag) return;
        _cacheAsBitmap = flag;
        if (_cacheAsBitmap) {
            if (_invalidating) {
                validate();
            }
            if (!_cacheFilter) {
                _cacheFilter = new FragmentFilter();
                _cacheFilter.resolution = .4;
//                _cacheFilter.alwaysDrawToBackBuffer = true ;
//                _cacheFilter.antiAliasing = 4;
                _cacheFilter.textureSmoothing = TextureSmoothing.TRILINEAR;
            }
            _mesh.filter = _cacheFilter;
//            _cacheFilter.cache();
        } else {
            if (_cacheFilter) {
                _cacheFilter.clearCache();
            }
            _mesh.filter = null;
        }
    }

    public function get mesh():AbsMesh {
        return _mesh;
    }

    public function Draw(geometry:GraphGeom = null) {
        super();
        useInvalidation = true;
        _invalidating = false;
        _geom = geometry || new GraphGeom();
        init();
        if (geometry) {
            invalidate();
        }
    }

    private function init():void {
        _fillStyle = new FillStyle();
        _lineStyle = new LineStyle();
        _mesh = new AbsMesh();
        touchGroup = true;
        addChild(_mesh);

        vd = _mesh.getVertex();
        id = _mesh.getIndex();
        id.useQuadLayout = false;
    }

    private function invalidate():void {
        if (useInvalidation) {
            if (_invalidating) return;
            _invalidating = true;
            Starling.juggler.delayCall(validate, 0);
        } else {
            validate();
        }
    }

    public function validate():Draw {
        // TODO: readjust the polygon to keep it open.
        if (currentPath) {
            finishPoly();
        }
        if (currentPath) {
            drawShape(currentPath);
        }
        // skip in cloneed instance.
        _geom.calculate();
        renderMesh();

        if (_invalidating) {
            Starling.juggler.removeDelayedCalls(validate);
        }
        _invalidating = false;

        return this;
    }

    /**
     * Copy all the mesh information from another Draw instance.
     * @param drawObject
     * @param forceValidation
     */
    public function copyFrom(drawObject:Draw, forceValidation:Boolean = true):Draw {
        if (drawObject._invalidating) {
            if (forceValidation) {
                drawObject.validate();
                applyCopy();
            } else {
                drawObject.addEventListener('render', applyCopy);
            }
        } else {
            applyCopy();
        }

        function applyCopy(e:Event = null) {
            if (e) {
                drawObject.removeEventListener('render', applyCopy);
            }
            drawObject._mesh.getVertex().copyTo(_mesh.getVertex());
            drawObject._mesh.getIndex().copyTo(_mesh.getIndex());
        }

        return this;
    }

    private function renderMesh():void {
        const indices:Array = _geom.indices;
        const colors:Array = _geom.colors;
        const gradients:Array = _geom.gradients;
        const verts:Array = _geom.points;
        const uvs:Array = _geom.uvs;
        var i:int, j:int = 0, len:int, rawData:ByteArray;


        vd.clear();
        id.clear();
        id.useQuadLayout = false;

        rawData = vd.rawData;
        const numVer:int = verts.length >> 1;
        vd.numVertices = numVer;
        const positionOffset:int = vd.format.getOffset('position');
        const vertexSize:int = vd.vertexSize;

        len = verts.length;
        for (i = 0; i < len; i += 2) {
            rawData.position = j * vertexSize + positionOffset;
            rawData.writeFloat(verts[i]);
            rawData.writeFloat(verts[i + 1]);
//            vd.setPoint(j, 'position', verts[i], verts[i + 1]);
            if (_geom.texture) {
                vd.setPoint(j, 'texCoords', uvs[i], uvs[i + 1]);
            }
            j++;
        }

        len = colors.length;
        for (i = 0; i < len; i += 4) {
            vd.colorize('color', colors[i + 2], colors[i + 3], colors[i], colors[i + 1]);
        }

        len = gradients.length;
        if (len > 0) {
            for (i = 0; i < len; i += 7) {
                applyGradient(
                        gradients[i], gradients[i + 1],
                        gradients[i + 2], gradients[i + 3],
                        gradients[i + 4], gradients[i + 5], gradients[i + 6]);
            }
        }

        len = indices.length;
        for (i = 0; i < len; i += 3) {
            /*rawData.writeShort(indices[i]);
            rawData.writeShort(indices[i + 1]);
            rawData.writeShort(indices[i + 2]);
            numInd += 3;*/
            id.addTriangle(indices[i], indices[i + 1], indices[i + 2]);
        }
        _mesh.textureRepeat = _geom.textureRepeat;
        _mesh.texture = _geom.texture;

        trace(_mesh.textureRepeat);
        dispatchEventWith("render");
        _mesh.setRequiresRedraw();
    }

    public function lineTextureStyle(width:Number = 0, texture:Texture = null, textureRepeat:Boolean=false, color:uint = 0xFFFFFF, alpha:Number = 1,
                                      matrix:Matrix = null,
                                      aligment:Number = 0.5, joinType:String = JointStyle.MITER, lineCap:String = CapsStyle.SQUARE,
                                      miterLimit:Number = 10):Draw {
        if (currentPath) {
            startPoly();
        }
        const visible:Boolean = width > 0 && alpha > 0;
        if (!visible) {
            _lineStyle.reset();
        } else {
            if (matrix) {
                matrix = matrix.clone();
            }
            _lineStyle.texture = texture ;
            _lineStyle.textureRepeat = textureRepeat ;
            _lineStyle.gradient.visible = false;
            _lineStyle.width = width;
            _lineStyle.alignment = aligment;
            _lineStyle.color = color;
            _lineStyle.alpha = alpha;
            _lineStyle.matrix = matrix;
            _lineStyle.visible = true;
            _lineStyle.joint = joinType;
            _lineStyle.caps = lineCap;
            _lineStyle.miterLimit = miterLimit;
        }
        return this;
    }

    /**
     * begin drawing fill with a Texture.
     *
     * NOTE: As a Draw instance uses only one Mesh, the texture will be applied to the entire geometry.
     * Textures must be a power of 2 for accurate repeatMode, (Stage3D limitation apparently).
     * When u generate the texture, mipmapping is required!
     *
     * Currently no support for SubTextures (TextureAtlas)
     *
     * TODO: implement multiple internal Meshes to assign textures.
     * TODO: implement something similar to Image::tileGrid for repeatMode.
     *
     * @param texture
     * @param color
     * @param alpha
     * @param matrix
     * @param textureRepeat     For proper repeatTexture, provide a pow2 texture.
     * @return
     */
    public function beginTextureFill(texture:Texture = null, color:uint = 0xffffff, alpha:Number = 1, matrix:Matrix = null, textureRepeat:Boolean=false):Draw {
        if (currentPath) {
            startPoly();
        }
        var visible:Boolean = alpha > 0;
        if (!visible) {
            _fillStyle.reset();
        } else {
            if (matrix) {
                matrix = matrix.clone();
                matrix.invert();
            }
            _fillStyle.gradient.visible = false;
            _fillStyle.color = color;
            _fillStyle.alpha = alpha;
            _fillStyle.texture = texture;
            _fillStyle.textureRepeat = textureRepeat;
            _fillStyle.matrix = matrix;
            _fillStyle.visible = visible;
        }
        return this;
    }

    private function initCurve(x:Number = 0, y:Number = 0):void {
        if (currentPath) {
            if (currentPath.points.length == 0) {
                currentPath.points = [x, y];
            }
        } else {
            moveTo(x, y);
        }
    }

    public function clear():Draw {
        _geom.clear();
        if (currentPath) currentPath = null;
        _matrix = null;
        _holeMode = false;
        invalidate();
        return this;
    }

    public function lineStyle(width:Number = 0, color:uint = 0xFFFFFF, alpha:Number = 1,
                              alignment:Number = 0.5, joinType:String = JointStyle.MITER, lineCap:String = CapsStyle.SQUARE,
                              miterLimit:Number = 10):Draw {
        return lineTextureStyle(width, null,false, color, alpha, null, alignment, joinType, lineCap, miterLimit);
    }

    public function beginFill(color:uint = 0xFFFFFF, alpha:Number = 1):Draw {
        return beginTextureFill(null, color, alpha, null);
    }

    // TODO: fix alpha rendering.
    public function beginGradientFill(colorA:uint = 0xffffff, colorB:uint = 0x0, angle:Number = 0, alphaA:Number = 1, alphaB:Number = 1):Draw {
        if (currentPath) {
            startPoly();
        }
        if (alphaA == 0 && alphaB == 0) {
            _fillStyle.gradient.reset();
        } else {
            _fillStyle.gradient.color1 = colorA;
            _fillStyle.gradient.color2 = colorB;
            _fillStyle.gradient.alpha1 = alphaA;
            _fillStyle.gradient.alpha2 = alphaB;
            _fillStyle.gradient.angle = angle;
            _fillStyle.visible = _fillStyle.gradient.visible = visible;
        }
        return this;
    }

    public function lineGradientStyle(width:Number = 0, colorA:uint = 0xffffff, colorB:uint = 0xffffff, angle:Number = 0, alphaA:Number = 1, alphaB:Number = 1, aligment:Number = .5, joinType:String = JointStyle.MITER, lineCap:String = CapsStyle.SQUARE, miterLimit:Number = 10):Draw {
        if (currentPath) {
            startPoly();
        }
        const visible:Boolean = width > 0 && (alphaA > 0 || alphaB > 0);
        if (!visible) {
            _lineStyle.gradient.reset();
        } else {
            _lineStyle.width = width;
            _lineStyle.alignment = aligment;
            _lineStyle.gradient.color1 = colorA;
            _lineStyle.gradient.color2 = colorB;
            _lineStyle.gradient.alpha1 = alphaA;
            _lineStyle.gradient.alpha2 = alphaB;
            _lineStyle.gradient.angle = angle;
            _lineStyle.visible = _lineStyle.gradient.visible = visible;
            _lineStyle.joint = joinType;
            _lineStyle.caps = lineCap;
            _lineStyle.miterLimit = miterLimit;
        }
        return this;
    }

    public function endFill():Draw {
        finishPoly();
        _fillStyle.reset();
//        invalidate();
        return this;
    }

    public function drawRect(x:Number, y:Number, width:Number, height:Number):Draw {
        return drawShape(new Rect(x, y, width, height));
    }

    public function drawRoundRect(x:Number, y:Number, width:Number, height:Number, radius:Number):Draw {
        return drawShape(new RoundRect(x, y, width, height, radius, radius, radius, radius));
    }

    public function drawRoundRectComplex(x:Number, y:Number, width:Number, height:Number, topLeftRadius:Number, topRightRadius:Number = -1, bottomLeftRadius:Number = -1, bottomRightRadius:Number = -1):Draw {
        return drawShape(new RoundRect(x, y, width, height, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius))
    }

    public function drawCircle(x:Number, y:Number, radius:Number):Draw {
        return drawShape(new Circle(x, y, radius));
    }

    public function drawEllipse(x:Number, y:Number, width:Number, height:Number):Draw {
        return drawShape(new Ellipse(x, y, width, height));
    }

    public function drawStar(x:Number, y:Number, points:int, radius:Number, innerRadius:Number = 0, rotation:Number = 0):Draw {
        return drawPolygon(new StarPoly(x, y, points, radius, innerRadius, rotation));
    }

    public function drawPolygon(path:Object, closed:Boolean = false):Draw {
        if (path is Poly) {
            drawShape(path as Poly);
            return this;
        }
        var points:Array;
        if (path is Array) {
            points = path as Array;
        } else if (path is Poly || ('points' in path && 'closed' in path)) {
            /*closed = Poly(path).closed;
            points = Poly(path).points;*/
            closed = path.closed;
            points = path.points;
        }

        if (!(points is Array)) {
            points = [];
            for (var i:int = 0, ilen:int = arguments.length; i < ilen; i++) {
                points[i] = arguments[i];
            }
        }
        const shape:Poly = new Poly(points);
        if (closed) {
            shape.close();
        }
        drawShape(shape);
        return this;
    }


    /**
     * Taken from https://codepen.io/unrealnl/pen/aYaxBW
     * Makes call to moveTo/lineTo, beginFill() will not work with this method.
     * @param polygon
     * @param dash
     * @param gap
     * @param offsetPercentage
     * @param x                 offset the entire polygon x position
     * @param y                 offset the entire polygon y position
     * @param rotation          offset the entire polygon rotation
     * @return
     */
    public function dashedPolygon(polygon:Array, dash:Number, gap:Number, offsetPercentage:Number = 0, x:Number = 0, y:Number = 0, rotation:Number = 0):Draw {
        var i:int;
        var p1:Object;// point (x,y)
        var p2:Object;// point (x,y)
        var dashLeft:Number = 0;
        var gapLeft:Number = 0;
        if (offsetPercentage > 0) {
            var progressOffset:Number = (dash + gap) * offsetPercentage;
            if (progressOffset < dash) dashLeft = dash - progressOffset;
            else gapLeft = gap - (progressOffset - dash);
        }
        var dx:Number;
        var dy:Number;
        var rotatedPolygons:Array = [];
        var len:int;

        // detect polygon type.
        len = polygon.length;
        if (polygon[0] is Number) {
            const arr:Array = [];
            for (i = 0; i < len; i += 2) {
                arr[arr.length] = {x: polygon[i], y: polygon[i + 1]};
            }
            polygon = arr;
        }
        len = polygon.length;
        for (i = 0; i < len; i++) {
            var p:Object = {x: polygon[i].x, y: polygon[i].y};
            var cosAngle:Number = Math.cos(rotation);
            var sinAngle:Number = Math.sin(rotation);
            dx = p.x;
            dy = p.y;
            p.x = dx * cosAngle - dy * sinAngle;
            p.y = dx * sinAngle + dy * cosAngle;
//            rotatedPolygons.push(p);
            rotatedPolygons[rotatedPolygons.length] = p;
        }
        len = rotatedPolygons.length;
        for (i = 0; i < len; i++) {
            p1 = rotatedPolygons[i];
            if (i == len - 1) p2 = rotatedPolygons[0];
            else p2 = rotatedPolygons[i + 1];
            dx = p2.x - p1.x;
            dy = p2.y - p1.y;
            var distance:Number = Math.sqrt(dx * dx + dy * dy);
            var normal:Object = {x: dx / distance, y: dy / distance};
            var progressOnLine:Number = 0;
            this.moveTo(
                    x + p1.x + gapLeft * normal.x,
                    y + p1.y + gapLeft * normal.y
            );
            while (progressOnLine <= distance) {
                progressOnLine += gapLeft;
                if (dashLeft > 0) progressOnLine += dashLeft;
                else progressOnLine += dash;
                if (progressOnLine > distance) {
                    dashLeft = progressOnLine - distance;
                    progressOnLine = distance;
                } else {
                    dashLeft = 0;
                }
                this.lineTo(
                        x + p1.x + progressOnLine * normal.x,
                        y + p1.y + progressOnLine * normal.y
                );
                progressOnLine += gap;
                if (progressOnLine > distance && dashLeft == 0) {
                    gapLeft = progressOnLine - distance;
                } else {
                    gapLeft = 0;
                    this.moveTo(
                            x + p1.x + progressOnLine * normal.x,
                            y + p1.y + progressOnLine * normal.y
                    );
                }
            }
        }
        return this;
    }

    // *********
    // LINE CODE.
    // *********

    public function moveTo(x:Number, y:Number):Draw {
        // TODO: optimize, if we previously called moveTo()...
        startPoly();
        currentPath.points[0] = x;
        currentPath.points[1] = y;
        return this;
    }

    public function lineTo(x:Number, y:Number):Draw {
        if (!currentPath) moveTo(0, 0);
        const points:Array = currentPath.points;
        const fromX:Number = points[points.length - 2];
        const fromY:Number = points[points.length - 1];
        if (fromX != x || fromY != y) {
            points[points.length] = x;
            points[points.length] = y;
            invalidate();
        }
        return this;
    }


    // CURVES DRAWING

    public function quadraticCurveTo(cpX:Number, cpY:Number, toX:Number, toY:Number):Draw {
        return curveTo(cpX, cpY, toX, toY);
    }

    public function curveTo(cpX:Number, cpY:Number, toX:Number, toY:Number):Draw {
        initCurve();
        const points:Array = currentPath.points;
        if (points.length == 0) moveTo(0, 0);
        QuadraticUtils.curveTo(cpX, cpY, toX, toY, points);
        return this;
    }

    public function bezierCurveTo(cpX:Number, cpY:Number, cpx2:Number, cpy2:Number, toX:Number, toY:Number):Draw {
        return cubicCurveTo(cpX, cpY, cpx2, cpy2, toX, toY);
    }

    public function cubicCurveTo(cpX:Number, cpY:Number, cpx2:Number, cpy2:Number, toX:Number, toY:Number):Draw {
        initCurve();
        BezierUtils.curveTo(cpX, cpY, cpx2, cpy2, toX, toY, currentPath.points);
        return this;
    }

    public function arcTo(x1:Number, y1:Number, x2:Number, y2:Number, radius:Number):Draw {
        initCurve(x1, y1);
        const points:Array = currentPath.points;
        const result:Object = ArcUtils.curveTo(x1, y1, x2, y2, radius, points);
        if (result) {
            arc(result.cx, result.cy, result.radius, result.startAngle, result.endAngle, result.anticlockwise);
        } else {
            invalidate();
        }
        return this;
    }

    public function arc(centerX:Number, centerY:Number, radius:Number, startAngle:Number, endAngle:Number, anticlockwise:Boolean = false):Draw {
        if (startAngle == endAngle) return this;
        if (!anticlockwise && endAngle <= startAngle) {
            endAngle += GraphUtils.PI2;
        } else if (anticlockwise && startAngle <= endAngle) {
            startAngle += GraphUtils.PI2;
        }
        var sweep:Number = endAngle - startAngle;
        if (sweep == 0) return this;
        var startX:Number = centerX + (Math.cos(startAngle) * radius);
        var startY:Number = centerY + (Math.sin(startAngle) * radius);

        // If the currentPath exists, take its points. Otherwise call `moveTo` to start a path.
        var points:Array = currentPath ? currentPath.points : null;

        if (points) {
            const len:int = points.length;
            // We check how far our start is from the last existing point
            const xDiff:Number = Math.abs(points[len - 2] - startX);
            const yDiff:Number = Math.abs(points[len - 1] - startY);
            if (xDiff < 0.001 && yDiff < 0.001) {
                // If the point is very close, we don't add it, since this would lead to artifacts
                // during tessellation due to floating point imprecision.
            } else {
                points.push(startX, startY);
            }
        } else {
            moveTo(startX, startY);
            points = currentPath.points;
        }
        ArcUtils.arc(startX, startY, centerX, centerY, radius, startAngle, endAngle, anticlockwise, points);
        invalidate();
        return this;
    }

    public function closePath():Draw {
        var path:* = currentPath;
        if (path is Poly) {
            Poly(path).close();
        }
        return this;
    }

    public function beginHole():Draw {
        finishPoly();
        _holeMode = true;
        return this;
    }

    public function endHole():Draw {
        finishPoly();
        _holeMode = false;
        return this;
    }

    public function drawGraphicsData(graphicsData:Vector.<IGraphicsData>):Draw {
        var map:Dictionary = GraphicsDataBuild._graphCommandsMap;
        if (!map) GraphicsDataBuild.initGraphMapClasses();
        map = GraphicsDataBuild._graphCommandsMap;
        for (var i:int = 0, ilen:int = graphicsData.length; i < ilen; i++) {
            var gd:IGraphicsData = graphicsData[i];
            var clase:Class = Object(gd).constructor;
            if (clase && map[clase]) {
//                trace(clase);
                map[clase](this, gd);
            } else {
                trace("[Draw] drawGraphicsData() unsupported command:", clase, JSON.stringify(gd));
            }
        }
        return this;
    }

    public function drawPath(commands:Vector.<int>, data:Vector.<Number>):Draw {
        // map commands and actions.
        var j:int = 0;// data.
        if (data.length % 2 != 0) {
            trace("[Draw] drawPath:: invalid data supplied.");
            return this;
        }
        for (var i:int = 0, ilen:int = commands.length; i < ilen; i++) {
            var cmd:int = commands[i];
            if (cmd == GraphicsPathCommand.NO_OP) continue;
            else if (cmd == GraphicsPathCommand.MOVE_TO || cmd == GraphicsPathCommand.WIDE_MOVE_TO) {
                moveTo(data[j++], data[j++]);
            } else if (cmd == GraphicsPathCommand.LINE_TO || cmd == GraphicsPathCommand.WIDE_LINE_TO) {
                lineTo(data[j++], data[j++]);
            } else if (cmd == GraphicsPathCommand.CURVE_TO) {
                curveTo(data[j++], data[j++], data[j++], data[j++]);
            } else if (cmd == GraphicsPathCommand.CUBIC_CURVE_TO) {
                cubicCurveTo(data[j++], data[j++], data[j++], data[j++], data[j++], data[j++]);
            }
        }
        return this;
    }

    /**
     * Tries to replicate the drawTriangles from the AS3 Graphics API.
     * @param vertices
     * @param indices
     * @return
     */
    public function drawTriangles(vertices:Vector.<Number>, indices:Vector.<int> = null):Draw {
        if (!vertices) {
            throw new Error('drawTriangles requires vertices');
        } else if (vertices.length % 2 != 0) {
            throw new Error('drawTriangles requires an odd number of vertices');
        }
        if (indices && indices.length % 3 != 0) {
            throw new Error('drawTriangles requires number of indices to be multiple of 3.');
        }
        if (!indices && (vertices.length >> 1) % 3 != 0) {
            throw new Error('drawTriangles requires num vertices divisible 3 when no indices are provided.');
        }
        if (!indices) {
            indices = new Vector.<int>();
            for (var i:int = 0, ilen:int = vertices.length >> 1; i < ilen; i++) indices[i] = i;
        }
        return drawShape(new MeshShape(vertices, indices, null));
    }

    public function drawTriangle(p0x:Number, p0y:Number, p1x:Number, p1y:Number, p2x:Number, p2y:Number):Draw {
        return drawPolygon({points: [p0x, p0y, p1x, p1y, p2x, p2y], closed: true});
    }

    private function startPoly():void {
        if (currentPath) {
            const points:Array = currentPath.points;
            const len:int = points.length;
            if (len > 2) {
                drawShape(currentPath);
                currentPath = new Poly([points[len - 2], points[len - 1]]);
                currentPath.closed = false;
            }
        } else {
            currentPath = new Poly();
            currentPath.closed = false;
            invalidate();
        }
    }

    private function finishPoly():void {
        if (currentPath) {
            if (currentPath.points.length > 2) {
//                trace("Finish poly paths?", currentPath.points.length);
                drawShape(currentPath);
                currentPath = null;
            } else {
                // TODO: return to pool?
                currentPath.reset();
                invalidate();
            }
        }
    }

    protected function drawShape(shape:AbsShape):Draw {
        if (!_holeMode) {
            _geom.drawShape(shape, _fillStyle.clone(), _lineStyle.clone() as LineStyle, _matrix);
        } else {
            _geom.drawHole(shape, _matrix);
        }
        invalidate();
        return this;
    }

    override public function dispose():void {
        removeFromParent();
        _geom.dispose();
        _mesh.dispose();
        super.dispose();
    }

    /**
     * Gradient Util code.
     */
    private static const aDistance:Vector.<Number> = new Vector.<Number>();
    private static const pt:Point = new Point();

    [Inline]
    // TODO: add fix for alpha in complex polygons.
    private final function applyGradient(from:int, to:int, col0:uint, col1:uint, bearing:Number, alpha1:Number = 1, alpha2:Number = 1):void {
        var fCos:Number, fSin:Number, fDist:Number, fMin:Number, fMax:Number;
        var fR0:Number, fR1:Number, fG0:Number, fG1:Number, fB0:Number, fB1:Number;
        var iNum:int, iVertex:int;
        var fScale:Number, fR:Number, fG:Number, fB:Number;
        iNum = to;
        aDistance.length = iNum;
        fCos = Math.cos(bearing);
        fSin = Math.sin(bearing);

        fMin = 1000000000;
        fMax = -fMin;

        for (iVertex = from; iVertex < iNum; iVertex++) {
            vd.getPoint(iVertex, 'position', pt);
            fDist = pt.x * fCos + pt.y * fSin;
            fMin = MathUtil.min(fDist, fMin);
            fMax = MathUtil.max(fDist, fMax);
            aDistance[iVertex] = fDist;
        }

        fR0 = (col0 >> 16) / 256.0;
        fG0 = ((col0 >> 8) & 0xff) / 256.0;
        fB0 = (col0 & 0xff) / 256.0;

        fR1 = (col1 >> 16) / 256.0;
        fG1 = ((col1 >> 8) & 0xff) / 256.0;
        fB1 = (col1 & 0xff) / 256.0;

        var ta:Number = 1;
        var fInvScale:Number;

        const changeAlpha:Boolean = alpha1 != 1 || alpha2 != 1;

        for (iVertex = from; iVertex < iNum; iVertex++) {
            fDist = aDistance[iVertex];
            fScale = (fDist - fMin) / (fMax - fMin);
            fInvScale = 1 - fScale;
            // interpolation.
            fR = fScale * fR0 + fInvScale * fR1;
            fG = fScale * fG0 + fInvScale * fG1;
            fB = fScale * fB0 + fInvScale * fB1;
            col0 = (int(fR * 256.0) << 16) + (int(fG * 256.0) << 8) + int(fB * 256.0);
            if (changeAlpha) {
                ta = fScale * alpha2 + fInvScale * alpha1;
            }
            if (vd.numVertices < iVertex + 1) {
                vd.numVertices = iVertex + 1;
            }
            vd.colorize('color', col0, ta, iVertex, 1);
        }
    }

    /**
     * Clones the Draw instance, but keeps the same Geometry reference, shared between cloned objects.
     * drawing geometry is stored in the GraphGeom, so changes will affect all Draw instances.
     *
     *
     * @return a copy of this Draw instance.
     */
    // TODO : workaround the validation() that clones the actual shape.
    public function clone():Draw {
        this.finishPoly();
        return new Draw(_geom);
    }

    private static const _matrix:Matrix = new Matrix();
    private static const _rect:Rectangle = new Rectangle();

    private static var tmpContainer:Sprite = new Sprite();
    private static var _padding:Padding = new Padding();
    private static var _imageMap:Dictionary;

    public static function getImage(instance:Draw, copyTransform:Boolean, compressFormat:Boolean = false):Image {

        if (!_imageMap) _imageMap = new Dictionary();
        // try to draw it
        var doc:DisplayObjectContainer = instance.parent;

        tmpContainer.addChild(instance);
        Starling.current.stage.addChild(tmpContainer);

        // offset if padding...
        var padd:Padding = _padding;
        if (instance.filter) {
            padd = instance.filter.padding;
        }

        // store previous matrix.
        _matrix.identity();
        var m:Matrix = instance.transformationMatrix.clone();
        instance.transformationMatrix = _matrix;

//        instance.rotation = 0;
//        instance.x = instance.y = 0;

        var bb:Rectangle = instance.getBounds(instance.parent, _rect);
//        instance.pivotX = instance.pivotY = 0;

        tmpContainer.x = padd.left;
        tmpContainer.y = padd.top;

        const format:String = compressFormat ? 'bgraPacked4444' : 'bgra';
        var rt:RenderTexture = new RenderTexture(Math.ceil(bb.width + padd.horizontal), Math.ceil(bb.height + padd.vertical), true, -1, format);
//        rt.clear(0xff0000, .25);
        rt.draw(tmpContainer, null, 1, 8);

        tmpContainer.removeChildren();
        tmpContainer.removeFromParent();

        if (doc) {
            doc.addChild(instance);
        }

        instance.transformationMatrix = m;

        var img:Image = new Image(rt);

        _imageMap[img] = {w: bb.width, h: bb.height, padd: padd};

        if (copyTransform) {
            img.transformationMatrix = m;
        }
        return img;
    }

    public static function getImgData(img:Image):Object {
        if (!_imageMap) return null;
        return _imageMap[img];
    }

    public static function getTexture(instance:Draw, compressFormat:Boolean = true):RenderTexture {
        const m:Matrix = Draw._matrix;
        const bounds:Rectangle = Draw._rect;
        m.identity();
        instance.getBounds(instance, bounds);
        m.translate(-bounds.x, -bounds.y);
        const format:String = compressFormat ? 'bgraPacked4444' : 'bgra';
        var texture:RenderTexture = new RenderTexture(Math.ceil(bounds.width), Math.ceil(bounds.height), true, -1, format);
        texture.draw(instance, m, 1, 2);
        return texture;
    }
}
}
