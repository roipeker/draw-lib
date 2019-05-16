// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 05/01/2019.
//
// =================================================================================================

package com.roipeker.starling.draw.svg {
import com.roipeker.starling.draw.Draw;
import com.roipeker.starling.draw.utils.svg.DPathParser;
import com.roipeker.starling.draw.utils.svg.SVGColor;

import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.geom.Matrix;

import starling.utils.StringUtil;

public class SVGDraw extends Draw {

    public function SVGDraw() {
        super();
        initMap();
    }

    private var _buildMap:Object = {};
    private static var _dpathParser:DPathParser = new DPathParser();
    public var holeColor:int = -1;
    private var _ct:Object;

    private function initMap():void {
        _buildMap['line'] = svgLine;
        _buildMap['path'] = svgPath;
        _buildMap['circle'] = svgCircle;
        _buildMap['ellipse'] = svgCircle;
        _buildMap['rect'] = svgRect;
        _buildMap['polygon'] = svgPolygon;//true
        _buildMap['polyline'] = svgPolyline;//false
    }

    public function parse(xml:XML):void {
        xml = clearXML(xml);
        if ('@holeFill' in xml) {
            holeColor = parseHex(xml.@holeFill.toString());
        }

        if ('@enable-background' in xml) {
            beginFill(0x0, 1);
        }
        svgChildren(xml.children(), false, null);
    }

    public var applyTransforms:Boolean = true;

    private function svgChildren(list:XMLList, inherit:Boolean = false, transform:Object = null):void {
        var len:int = list.length();
        for (var i:int = 0; i < len; i++) {
            var child:XML = list[i];
            fill(child, inherit);
            // analyze transform nodes.
            var nodeName:String = child.name().toString().toLowerCase();
//            trace("Child is", nodeName);
            if (applyTransforms) {
                analyzeTransform(child);
            }
            trace(nodeName);
            if (_buildMap[nodeName]) {
                _buildMap[nodeName](child);
            }
            if (child.hasComplexContent()) {
                svgChildren(child.children(), true);
            }
        }
    }

    private function analyzeTransform(child:XML):void {
        if ("@transform" in child) {
            transformChild(child.@transform);
            if (_ct) {
                _matrix = new Matrix();
                var arr:Array;
                if (arr = _ct.translate) {
                    _matrix.translate(arr[0], arr[1]);
                }

                if (arr = _ct.scale) {
                    _matrix.scale(arr[0], arr[1]);
                }
            }
        }
    }

    private function transformChild(transform:String):void {
        _ct = svgTransformParse(transform);
    }


    public static function svgTransformParse(a:String):Object {
        var b:Object = {};
        var c:Array = a.match(/(\w+)\(([^,)]+),?([^)]+)?\)/gi);
        for (var i:int = 0, len:int = c.length; i < len; i++) {
            var d:Array = c[i].match(/[\w\.\-]+/g);
            // todo: cast to numbers inside d[]
            b[d.shift()] = d;
        }
        return b;
    }


    //===================================================================================================================================================
    //
    //      ------  renderers
    //
    //===================================================================================================================================================

    private function svgPath(node:XML):void {
        var d:String = node.@d.toString();
//        trace("Generate map! >> ", d );
        var x:Number = 0, y:Number = 0;
        var commands:Array = dPathParse(d);
        var currX:Number, currY:Number;

        var lastCP:Object = {x:0,y:0};

        for (var i:int = 0, len:uint = commands.length; i < len; i++) {
            var command:Object = commands[i];
//            trace("Command code:", command.code);
            // parse command function?!
            // debuggin.
            var tr:String = command.code;
            var repl:Array = [];
            switch (command.code) {
                case 'm': {
                    tr += ' +{0}, +{1}';
                    repl = [command.end.x, command.end.y];

                    x += command.end.x;
                    y += command.end.y;
                    trace('move', x, y);
                    this.moveTo(x, y);
                    break;
                }
                case 'M': {
                    tr += ' {0}, {1}';
                    repl = [command.end.x, command.end.y];

                    x = command.end.x;
                    y = command.end.y;
                    trace('MOVE', x, y);
                    this.moveTo(x, y);
                    break;
                }
                case 'H': {
                    tr += ' x={0}';
                    repl = [command.value];

                    x = command.value;
                    trace('LINE', x, y);
                    this.lineTo(x, y);
                    break;
                }
                case 'h': {
                    tr += ' x=+{0}';
                    repl = [command.value];

                    x += command.value;
                    trace('line', x, y);
                    this.lineTo(x, y);
                    break;
                }
                case 'V': {
                    tr += ' y={0}';
                    repl = [command.value];

                    y = command.value;
                    trace('LINE', x, y);
                    this.lineTo(x, y);
                    break;
                }
                case 'v': {
                    tr += ' y=+{0}';
                    repl = [command.value];

                    y += command.value;
                    trace('line', x, y);
                    this.lineTo(x, y);
                    break;
                }
                case 'O': {
                    tr += ' HOLE START';
                    beginHole();
                    break;
                }
                case 'Z': {
                    tr += ' close';
                    this.closePath();
                    if (_holeMode) {
                        endHole();
                    }
                    if (_ct) {
                        applyTransform();
                    }
                    break;
                }
                case 'L': {
                    tr += ' lineTo {0}, {1}';
                    repl = [command.end.x, command.end.y];

                    x = command.end.x;
                    y = command.end.y;
                    this.lineTo(
                            x, y
                    );
                    break;
                }
                case 'l': {
                    tr += ' lineTo +{0}, +{1}';
                    repl = [command.end.x, command.end.y];

                    x += command.end.x;
                    y += command.end.y;
                    this.lineTo(
                            x, y
                    );
                    break;
                }

//                case 'S':
                case 'C': {

                    tr += ' cubicCurve {0}, {1} / {2}, {3} / {4}, {5}';
                    repl = [command.cp1.x, command.cp1.y,
                        command.cp2.x, command.cp2.y,
                        command.end.x, command.end.y];
                    lastCP.x = command.cp2.x;
                    lastCP.y = command.cp2.y;

                    currX = x;
                    currY = y;
                    this.cubicCurveTo(
                            command.cp1.x, command.cp1.y,
                            command.cp2.x, command.cp2.y,
                            command.end.x, command.end.y
                    );
                    x = command.end.x;
                    y = command.end.y;

                    break;
                }


                // TODO: fix 's' as described in https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths
                /*case 's': {
                    tr += ' s_cubicCurve ++ {0}, {1} / {2}, {3} / {4}, {5}';
//                    end":{"x":256,"y":-256},"relative":true,"cp":{"x":114.621094,"y":-256}}

                    repl = [
                        -lastCP.x, -lastCP.y,
                        command.cp.x, command.cp.y,
                        command.end.x, command.end.y];
                    currX = x;
                    currY = y;
                    x += command.end.x;
                    y += command.end.y;
                    this.cubicCurveTo(
                            -lastCP.x, -lastCP.y,
                            command.cp.x, command.cp.y,
                            x, y
                    );
                    break ;
                }*/
                case 'c': {
                    tr += ' cubicCurve ++ {0}, {1} / {2}, {3} / {4}, {5}';
                    repl = [command.cp1.x, command.cp1.y,
                        command.cp2.x, command.cp2.y,
                        command.end.x, command.end.y];

                    currX = x;
                    currY = y;
                    x += command.end.x;
                    y += command.end.y;
                    this.cubicCurveTo(
                            currX + command.cp1.x,
                            currY + command.cp1.y,
                            currX + command.cp2.x,
                            currY + command.cp2.y,
                            x, y
                    );

                    lastCP.x = currX + command.cp2.x;
                    lastCP.y = currY + command.cp2.y;

                    break;
                }
                case 's':
                case 'q': {
                    tr += ' quadCurve++ {0}, {1} / {2}, {3}';
                    repl = [command.cp.x, command.cp.y,
                        command.end.x, command.end.y];

                    currX = x;
                    currY = y;
                    x += command.end.x;
                    y += command.end.y;
                    this.curveTo(
                            currX + command.cp.x,
                            currY + command.cp.y,
                            x, y
                    );
                    break;
                }
                case 'S':
                case 'Q': {
                    tr += ' quadCurve {0}, {1} / {2}, {3}';
                    repl = [command.cp.x, command.cp.y,
                        command.end.x, command.end.y];
                    currX = x;
                    currY = y;
                    x = command.end.x;
                    y = command.end.y;
                    this.curveTo(
                            currX + command.cp.x,
                            currY + command.cp.y,
                            x, y
                    );
                    break;
                }
                default: {
                    // @if DEBUG
                    trace('[SVGUtils] Draw command not supported:', command.code);
//                    console.info('[SVGUtils] Draw command not supported:', command.code, command);
                    // @endif
                    break;
                }
            }

            if (tr) {
                repl.unshift(tr);
                tr = StringUtil.format.apply(null, repl);
                trace("SVG " + tr);
            }
        }
    }

    private function applyTransform():void {

    }

    private function dPathParse(d:String):Array {
        return _dpathParser.parse(d);
    }

    private function svgCircle(node:XML):void {
        var hprop:String = 'r';
        var wprop:String = 'r';
        const isElipse:Boolean = node.name().toString() == 'elipse';
        if (isElipse) {
            hprop += 'x';
            wprop += 'y';
        }
        var w:Number = parseFloat(node.@[wprop]);
        var h:Number = parseFloat(node.@[hprop]);
        var x:Number = '@cx' in node ? parseFloat(node.@cx) : 0;
        var y:Number = '@cy' in node ? parseFloat(node.@cy) : 0;
        if (!isElipse) {
            drawCircle(x, y, w);
        } else {
            drawEllipse(x, y, w, h);
        }
    }

    private function svgRect(node:XML):void {
        var rx:Number = '@rx' in node ? parseFloat(node.@rx) : 0;
        var x:Number = parseFloat(node.@x);
        var y:Number = parseFloat(node.@y);
        var w:Number = parseFloat(node.@width);
        var h:Number = parseFloat(node.@height);
        if (rx > 0) {
            drawRoundRect(x, y, w, h, rx);
        } else {
            this.drawRect(x, y, w, h);
        }
    }


    private function svgLine(node:XML):void {
        trace(node.toXMLString());
    }

    private function svgPolygon(node:XML):void {
        trace("SVG POLY:", node.toXMLString());
        svgPoly(node, true);
    }

    private function svgPolyline(node:XML):void {
        svgPoly(node, false);
    }

    private function svgPoly(node:XML, closed:Boolean = false):void {
        const points:Array = String(node.@points).split(/[ ,]/g).map(function (obj:String, i:int, arr:Array):Number {
            return parseFloat(obj);
        });
        drawPolygon(points, closed);
    }

    private function fill(node:XML, inherit:Boolean = false):void {
        var props:Object = svgStyle(node);

        if (!props) return;


        // todo: make fill inherit.
        var defaultLineW:Number = 'stroke' in props ? 1 : 0;
        if (props.stroke == 'none') {
            defaultLineW = 0;
        }

        trace("Fill style:", node.toXMLString(), JSON.stringify(props));
//        <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" stroke-CapsStyle="square">

        var opacity:Number = 'opacity' in props ? parseFloat(props.opacity) : 1;
        var fill:String = props.fill;
        var lineW:Number = 'strokeWidth' in props ? parseFloat(props.strokeWidth) : defaultLineW;
        var lineColor:Number = 'stroke' in props ? parseHex(props.stroke) : _lineStyle.color;
        var caps:String = 'stroke-linecap' in props ? props['stroke-linecap'] : CapsStyle.SQUARE;

        if (fill) {
            trace("Fill is:", fill);
            if (fill == 'none') {
                beginFill(0, 0);
            } else {
                var fillColor:uint = parseHex(fill);
                beginFill(fillColor, opacity);
                if (fillColor == holeColor) {

                }
            }
        } else if (!inherit) {
            beginFill(0);
        }

        if (_fillStyle.visible) {
            if (holeColor == _fillStyle.color) {
                if (!_holeMode) {
                    beginHole();
                }
            }
        }
        lineStyle(lineW, lineColor, 1, .5, JointStyle.MITER, caps);
        // line join, cap, fill-rule NOT supported!.
    }

    private function svgStyle(node:XML):Object {

        var style:String = '@style' in node ? String(node.@style) : null;
        var hasStyleData:Boolean = false;

        const result:Object = {};

        addProp('fill');
        addProp('opacity');
        addProp('stroke');
        addProp('stroke-width');

        function addProp(prop:String):void {
            var key:String = '@' + prop;
            if (key in node) {
                hasStyleData = true;
                result[prop] = String(node[key]);
            }
        }

        if (style !== null) {
            var arr:Array = style.split(';');
            for each(var p:String in arr) {
                hasStyleData = true;
                var keys:Array = p.split(':');
                result[trim(keys[0])] = trim(keys[1]);
//                trace('keys', keys);
            }
        }

        if (result['stroke-width']) {
            hasStyleData = true;
            // replace.
            result.strokeWidth = result['stroke-width'];
            delete result['stroke-width'];
        }
        if (!hasStyleData) return null;
//        trace("JSON", JSON.stringify(result));
        return result;
    }


    private static function trim(str:String):String {
        if (!str) return "";
        return str.replace(/^\s+|\s+$/gm, '');
    }


    private function parseHex(strColor:String):uint {
        return SVGColor.resolveHex(strColor);
        /*if (strColor.charAt(0) == '#') {
            strColor = strColor.substr(1);
//            trace("Str color", strColor);
            if (strColor.length == 3) {
                strColor = strColor.replace(/([a-f0-9])/ig, '$1$1');
            }
            return parseInt(strColor, 16);
        } else {
            trace('color not supported!');
            return 0x00ff00;
        }*/
    }

    public static function clearXML(xml:XML):XML {
        var myXmlStr:String = xml.toString();
        if (myXmlStr.indexOf('xmlns') == -1) return xml;
        var xmlnsPattern:RegExp = new RegExp("xmlns[^\"]*\"[^\"]*\"", "gi");
        myXmlStr = myXmlStr.replace(xmlnsPattern, "");

        // Remove namespaced attrsf that will throw exceptions.
        const removeAttrs:Array = [
            'xlink:', 'mtc:', 'inkscape:', 'aaa:'
        ];

        for (var i:int = 0, ilen:int = removeAttrs.length; i < ilen; i++) {
            if (myXmlStr.indexOf(removeAttrs[i]) >= 1)
                myXmlStr = myXmlStr.split(removeAttrs[i]).join("");
        }

        trace(myXmlStr);
        return new XML(myXmlStr);
    }
}
}
