// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-15.
//
// =================================================================================================

package com.roipeker.starling.draw.builders {
import com.roipeker.starling.draw.Draw;

import flash.display.*;
import flash.utils.Dictionary;

public class GraphicsDataBuild {
    public function GraphicsDataBuild() {
    }

    // SPECIAL TO BUILD.
    public static var _graphCommandsMap:Dictionary;

    public static function initGraphMapClasses():void {
        if(_graphCommandsMap) return ;
        _graphCommandsMap = new Dictionary(false);
        _graphCommandsMap[GraphicsStroke] = _grapStroke;
        _graphCommandsMap[GraphicsPath] = _graphPath;
        _graphCommandsMap[GraphicsSolidFill] = _graphSolidFill;
        _graphCommandsMap[GraphicsEndFill] = _graphEndFill;
        _graphCommandsMap[GraphicsGradientFill] = _graphGradientFill;
    }

    private static function _grapStroke(obj:Draw, g:GraphicsStroke) {
        var o:Object = {
            width: g.thickness || 0,
            miterlimit: g.miterLimit,
            caps: CapsStyle.SQUARE,//g.caps,
            joints: JointStyle.MITER//g.joints
        };
        if (g.fill) {
            if (g.fill is GraphicsSolidFill) addSolid(g.fill as GraphicsSolidFill);
        }

        function addSolid(fill:GraphicsSolidFill):void {
            o.color = fill.color, o.alpha = fill.alpha;
        }

        obj.lineStyle(o.width, o.color, o.alpha, .5, o.joints, o.caps, o.miterlimit);
    }

    private static function _graphPath(obj:Draw, g:GraphicsPath) {
        obj.drawPath(g.commands, g.data);
    }

    private static function _graphSolidFill(obj:Draw, g:GraphicsSolidFill) {
        obj.beginFill(g.color, g.alpha);
    }

    private static function _graphGradientFill(obj:Draw, g:GraphicsGradientFill) {
        var angle:Number = 0;
        if (g.matrix) {
            const a:Number = g.matrix.a;
            const b:Number = g.matrix.b;
            const c:Number = g.matrix.c;
            const d:Number = g.matrix.d;
            var r:Number;
            if (a != 0 || b != 0) {
                r = Math.sqrt(a * a + b * b);
                angle = b > 0 ? Math.acos(a / r) : -Math.acos(a / r);
            } else if (c != 0 || d != 0) {
                r = Math.sqrt(c * c + d * d);
                angle = Math.PI / 2 - (d > 0 ? Math.acos(-c / r) : -Math.acos(c / r));
            }
        }
        obj.beginGradientFill(g.colors[1], g.colors[0], angle, g.alphas[0], g.alphas[1]);
    }

    private static function _graphEndFill(obj:Draw, g:GraphicsEndFill) {
        obj.endFill();
    }

    public function drawGraphicsData(graphicsData:Vector.<IGraphicsData>):void {
        if (!_graphCommandsMap) initGraphMapClasses();
        for (var i:int = 0, ilen:int = graphicsData.length; i < ilen; i++) {
            var gd:IGraphicsData = graphicsData[i];
            var clase:Class = Object(gd).constructor;
            if (clase && _graphCommandsMap[clase]) {
                _graphCommandsMap[clase](this, gd);
            } else {
                trace("DrawGraphicsData unsupported command:", clase, JSON.stringify(gd));
            }
        }
    }
}
}
