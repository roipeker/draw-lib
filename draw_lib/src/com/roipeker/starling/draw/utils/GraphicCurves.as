// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 04/01/2019.
//
//  ported from PixiJS
//  https://github.com/pixijs/pixi.js
//
// =================================================================================================

package com.roipeker.starling.draw.utils {

/**
 * Graphics curves resolution settings. If `adaptive` flag is set to `true`,
 * the resolution is calculated based on the curve's length to ensure better visual quality.
 * Adaptive draw works with `bezierCurveTo` and `quadraticCurveTo`.
 *
 * @static
 * @constant
 * @memberof PIXI
 * @name GRAPHICS_CURVES
 * @type {object}
 * @property {boolean} adaptive=false - flag indicating if the resolution should be adaptive
 * @property {number} maxLength=10 - maximal length of a single segment of the curve (if adaptive = false, ignored)
 * @property {number} minSegments=8 - minimal number of segments in the curve (if adaptive = false, ignored)
 * @property {number} maxSegments=2048 - maximal number of segments in the curve (if adaptive = false, ignored)
 */
public class GraphicCurves {
    public function GraphicCurves() {
    }

    public static var adaptive:Boolean = false;
    public static var maxLength:Number = 10;
    public static var minSegments:uint = 8;
    public static var maxSegments:uint = 2048;

    public static function segmentsCount(length:Number, defaultSegments:uint = 20):uint {
        if (adaptive) {
            return defaultSegments;
        }
        var result:uint = Math.ceil(length / maxLength);
        if (result < minSegments) {
            result = minSegments;
        } else if (result > maxSegments) {
            result = maxSegments;
        }
        return result;
    }

}
}
