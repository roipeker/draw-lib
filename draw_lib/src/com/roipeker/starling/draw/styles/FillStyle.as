// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package com.roipeker.starling.draw.styles {
import flash.geom.Matrix;

import starling.textures.Texture;

import starling.utils.StringUtil;

public class FillStyle {

    // TODO: add pool

    public var color:uint;
    public var alpha:Number;
    public var visible:Boolean;
    public var gradient:GradientFillStyle;
    public var matrix:Matrix;

    public var texture:Texture;
    // only valid for pow of 2 textures.
    public var textureRepeat:Boolean;

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
        textureRepeat=false;
        matrix = null ;
        texture = null; // might be a default WHITE texture
    }

    public function clone():FillStyle {
        const fill:FillStyle = new FillStyle();
        fill.color = color;
        fill.alpha = alpha;
        fill.texture = texture ;
        fill.matrix = matrix ;
        fill.textureRepeat=textureRepeat;
        fill.visible = visible;
        fill.gradient.copyFrom(gradient);
        return fill;
    }

    public function toString():String {
        return StringUtil.format("[FillStyle color=0x{0}, alpha={1}, visible={2}, gradient={3}, texture={4}, textureRepeat={5}]",
                color.toString(16).toUpperCase(), alpha, visible, gradient, texture,textureRepeat);
    }

}
}
