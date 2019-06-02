// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.styles {
import flash.display.CapsStyle;
import flash.display.JointStyle;

import starling.utils.StringUtil;

public class LineStyle extends FillStyle {

    // TODO: add pool

    public var width:Number;
    public var alignment:Number;

    // -- extra props.
    public var joint:String; // JoinStyle
    public var caps:String; // CapsStyle
    public var miterLimit:Number;

    public function LineStyle() {
        reset();
    }

    override public function clone():FillStyle {
        const fill:LineStyle = new LineStyle();
        fill.texture = texture;
        fill.textureRepeat = textureRepeat;
        fill.matrix = matrix;
        fill.width = width ;
        fill.alignment = alignment;
        fill.joint= joint;
        fill.caps= caps;
        fill.miterLimit= miterLimit;
        fill.color = color ;
        fill.alpha= alpha;
        fill.visible= visible;
        fill.gradient.copyFrom(gradient);
        return fill ;
    }

    override public function reset():void {
        super.reset();
        color = 0x000000;
        width = 0;
        alignment = 0.5;
        miterLimit = 10;
        joint = JointStyle.MITER;
        caps = CapsStyle.SQUARE;
    }

    override public function toString():String {
        return StringUtil.format("[LineStyle width={0}, alignment={1}, color=0x{2}, alpha={3}, visible={4}, joint={5}, caps={6}, gradient={7}, texture={8}]",
                width, alignment, color.toString(16).toUpperCase(), alpha, visible, joint, caps, gradient, texture);
    }
}
}
