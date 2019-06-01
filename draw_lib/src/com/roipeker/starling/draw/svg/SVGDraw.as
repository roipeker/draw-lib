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
import starling.utils.deg2rad;

public class SVGDraw extends Draw {

    public var verbose:Boolean = false;

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
        _log(xml.toXMLString());
        if ('@holeFill' in xml) {
            holeColor = parseHex(xml.@holeFill.toString());
        }
        if ('@enable-background' in xml) {
            beginFill(0x0, 1);
        }
        svgChildren(xml.children(), false, null);
    }

    public var applyTransforms:Boolean = true;

    private function svgDefs(node:XML):void {
        // do something.
    }

    private function svgChildren(list:XMLList, inherit:Boolean = false, transform:Object = null):void {
        var len:int = list.length();
        for (var i:int = 0; i < len; i++) {

            var child:XML = list[i];
            var nodeName:String = child.name().toString().toLowerCase();
            _log("Child node name...", nodeName);

            if (nodeName == 'defs') {
                _log('analyze this def:', child);
                svgDefs(child);
                continue;
            }

            fill(child, inherit);

            _matrix = null;
            if (applyTransforms) {
                analyzeTransform(child);
            }
//            _log(nodeName);
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
                _log('transformat?!', _ct.rotate);
                if (arr = _ct.translate) {
                    _matrix.translate(arr[0], arr[1]);
                }
                if (arr = _ct.scale) {
                    _matrix.scale(arr[0], arr[1]);
                }
                if (arr = _ct.rotate) {
                    const angle:Number = deg2rad(arr[0]);
                    if (arr.length > 1) {
                        _matrix.translate(-arr[1], -arr[2]);
                        _matrix.rotate(angle);
                        _matrix.translate(arr[1], arr[2]);
                    } else {
                        _matrix.rotate(angle);
                    }
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
//        _log("Generate map! >> ", d );
        var x:Number = 0, y:Number = 0;
        var commands:Array = dPathParse(d);
        var currX:Number, currY:Number;

        var lastCP:Object = {x: 0, y: 0};

        for (var i:int = 0, len:uint = commands.length; i < len; i++) {
            var command:Object = commands[i];
//            _log("Command code:", command.code);
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
                    _log('move', x, y);
                    this.moveTo(x, y);
                    break;
                }
                case 'M': {
                    tr += ' {0}, {1}';
                    repl = [command.end.x, command.end.y];

                    x = command.end.x;
                    y = command.end.y;
                    _log('MOVE', x, y);
                    this.moveTo(x, y);
                    break;
                }
                case 'H': {
                    tr += ' x={0}';
                    repl = [command.value];

                    x = command.value;
                    _log('LINE', x, y);
                    this.lineTo(x, y);
                    break;
                }
                case 'h': {
                    tr += ' x=+{0}';
                    repl = [command.value];

                    x += command.value;
                    _log('line', x, y);
                    this.lineTo(x, y);
                    break;
                }
                case 'V': {
                    tr += ' y={0}';
                    repl = [command.value];

                    y = command.value;
                    _log('LINE', x, y);
                    this.lineTo(x, y);
                    break;
                }
                case 'v': {
                    tr += ' y=+{0}';
                    repl = [command.value];

                    y += command.value;
                    _log('line', x, y);
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
                        trace("End the hole!");
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
                    _log('[SVGUtils] Draw command not supported:', command.code);
//                    console.info('[SVGUtils] Draw command not supported:', command.code, command);
                    // @endif
                    break;
                }
            }

            if (tr) {
                repl.unshift(tr);
                tr = StringUtil.format.apply(null, repl);
                _log("SVG " + tr);
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
        var x:Number = parseFloat(node.@x) || 0;
        var y:Number = parseFloat(node.@y) || 0;
        var w:Number = parseFloat(node.@width) || 0;
        var h:Number = parseFloat(node.@height) || 0;
        if (w == 0 || h == 0) return;
        if (rx > 0) {
            drawRoundRect(x, y, w, h, rx);
        } else {
            this.drawRect(x, y, w, h);
        }
    }


    private function svgLine(node:XML):void {
        _log("drawing line:", node.toXMLString());
        if ('@x1' in node) {
//        var points:Array;
            /*points = [
                parseFloat(node.@x1), parseFloat(node.@y1),
                parseFloat(node.@x2), parseFloat(node.@y2)
            ];*/
//            const lineW:Number = '@stroke-width' in node ? parseFloat(node['@stroke-width']) : 1;
//            const opacity:Number = '@stroke-opacity' in node ? parseFloat(node['@stroke-opacity']) : 1;
//            const color:uint = '@stroke' in node ? parseHex(node.@stroke) : 0x0;
//            lineStyle(lineW, color, opacity);
            moveTo(parseFloat(node.@x1), parseFloat(node.@y1));
            lineTo(parseFloat(node.@x2), parseFloat(node.@y2));
        }
    }

    private function svgPolygon(node:XML):void {
        _log("SVG POLY:", node.toXMLString());
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

        _log("Fill style:", node.toXMLString(), JSON.stringify(props));
//        <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" stroke-CapsStyle="square">

        var opacity:Number = 1;
        if ('opacity' in props) {
            opacity = parseFloat(props.opacity)
        } else if ('fill-opacity' in props) {
            opacity = parseFloat(props['fill-opacity']);
            _log("Fill opacivity!!!!", opacity);
        }
        var fill:String = props.fill;

//        var lineW:Number = 'strokeWidth' in props ? parseFloat(props.strokeWidth) : defaultLineW;
        var lineColor:Number = 'stroke' in props ? parseHex(props.stroke) : _lineStyle.color;
        var lineW:Number = 'stroke-width' in props ? parseFloat(props['stroke-width']) : defaultLineW;
        var lineCap:String = 'stroke-linecap' in props ? props['stroke-linecap'] : CapsStyle.SQUARE;
        var lineJoin:String = 'stroke-linejoin' in props ? props['stroke-linejoin'] : JointStyle.MITER;
        var lineOpacity:Number = 'stroke-opacity' in props ? parseFloat(props['stroke-opacity']) : 1;
        var isLineVisible:Boolean = lineW > 0 && lineOpacity > 0;

//        trace("Hola color is", holeColor.toString(16));
        if (fill) {
            _log("Fill is:", fill, opacity);
            if (fill == 'none') {
                beginFill(0, 0);
            } else {
                var fillColor:uint = parseHex(fill);
                beginFill(fillColor, opacity);
                /*if (fillColor == holeColor) {

                }*/
            }
        } else if (!inherit) {
            beginFill(0x0, 0);
        }

        if (_fillStyle.visible) {
            if (holeColor == _fillStyle.color) {
                if (!_holeMode) {
                    beginHole();
                }
            }
        }

        // Not sure about this change... to "remove" a lineStyle.
//        trace("So line cap, join?", lineJoin, lineCap, lineW, lineColor, lineOpacity);
        if ( isLineVisible ) {
            lineStyle( lineW, lineColor, lineOpacity, .5, lineJoin, lineCap);
        }
        /*else if ( _lineStyle.visible && !isLineVisible) {
            lineStyle(lineW, lineColor, lineOpacity);
            trace('line INvisible!');
        }*/
        // line join, cap, fill-rule NOT supported!.
    }

    private function svgStyle(node:XML):Object {

        var style:String = '@style' in node ? String(node.@style) : null;
        var hasStyleData:Boolean = false;

        const result:Object = {};

        addProp('fill');
        addProp('opacity');
        addProp('fill-opacity');
        addProp('stroke');
        addProp('stroke-width');
        addProp('stroke-linecap');
        addProp('stroke-linejoin');
        addProp('stroke-opacity');

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
//                _log('keys', keys);
            }
        }

        /*if (result['stroke-width']) {
            hasStyleData = true;
            result.strokeWidth = result['stroke-width'];
            delete result['stroke-width'];
        }*/
        if (!hasStyleData) return null;
//        _log("JSON", JSON.stringify(result));
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
//            _log("Str color", strColor);
            if (strColor.length == 3) {
                strColor = strColor.replace(/([a-f0-9])/ig, '$1$1');
            }
            return parseInt(strColor, 16);
        } else {
            _log('color not supported!');
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
        return new XML(myXmlStr);
    }

    private function _log(...args):void {
        if (!verbose || !args.length) return;
        var msg:String = '[Draw] ' + args.join(" ");
        trace(msg);
    }
}
}
