// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.styles {
import starling.utils.StringUtil;

public class GradientFillStyle {

    // basic gradient with 2 colors.
    public var color1:uint;
    public var color2:uint;
    public var alpha1:Number;
    public var alpha2:Number;
    public var angle:Number;
    public var visible:Boolean;

    public function GradientFillStyle() {
        color1 = 0xFFFFFF;
        color2 = 0x000000;
        alpha1 = 1;
        alpha2 = 1;
        angle = 0;
        visible = false;
    }

    public function reset():void {
        color1 = 0xFFFFFF;
        color2 = 0x000000;
        alpha1 = 1;
        alpha2 = 1;
        angle = 0;
        visible = false;
    }

    public function clone():GradientFillStyle {
        var fill:GradientFillStyle = new GradientFillStyle();
        fill.color1 = color1;
        fill.color2 = color2;
        fill.alpha1 = alpha1;
        fill.alpha2 = alpha2;
        fill.angle = angle;
        fill.visible = visible;
        return fill;
    }

    public function copyFrom(gradient:GradientFillStyle):void {
        color1 = gradient.color1;
        color2 = gradient.color2;
        alpha1 = gradient.alpha1;
        alpha2 = gradient.alpha2;
        angle = gradient.angle;
        visible = gradient.visible;
    }

    public function toString():String {
        return StringUtil.format("[GradientFillStyle colors=0x{0}-0x{1}, alphas={2}-{3}, angle={4}, visible={5}]",
                color1.toString(16).toUpperCase(), color2.toString(16).toUpperCase(), alpha1, alpha2, angle, visible);
    }

}
}
