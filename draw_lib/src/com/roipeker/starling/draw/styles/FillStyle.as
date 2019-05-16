// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.styles {
import flash.geom.Matrix;

import starling.utils.StringUtil;

public class FillStyle {

    // TODO: add pool

    public var color:uint;
    public var alpha:Number;
    public var visible:Boolean;
    public var gradient:GradientFillStyle;

    // used?
    public var matrix:Matrix;

    // todo: add texture fill.

    public function FillStyle() {
        gradient = new GradientFillStyle();
        reset();
    }

    public function reset():void {
        // defaults.
        gradient.reset();
        color = 0xFFFFFF;
        alpha = 1;
        visible = false;
    }

    public function clone():FillStyle {
        const fill:FillStyle = new FillStyle();
        fill.color = color;
        fill.alpha = alpha;
        fill.visible = visible;
        fill.gradient.copyFrom(gradient);
        return fill;
    }

    public function toString():String {
        return StringUtil.format("[FillStyle color=0x{0}, alpha={1}, visible={2}, gradient={3}]",
                color.toString(16).toUpperCase(), alpha, visible, gradient);
    }

}
}
