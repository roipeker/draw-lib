// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-16.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.Draw;

import flash.display.CapsStyle;
import flash.display.JointStyle;

import starling.display.Sprite;
import starling.events.Event;

public class DemoLineStyles extends Sprite {

    public function DemoLineStyles() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {
        var draw:Draw = new Draw();
        addChild(draw);

        // when default to JoinStyle.MITTER, CapsStyle.SQUARE, it uses the optimized PixiJS lines routine, waaay less polygons.
        // ans also supports ::alignment to shift from 0 (line outside the shape), to 1 (line inside shape)... although there's no restrictions for the value.
        draw.lineStyle(20, 0x0, .5);
        draw.moveTo(490, 40);
        draw.lineTo(600, 200);
        draw.lineTo(640, 100);


        // How aligmnent works.....
        draw.lineStyle(10, 0xff0000, .25, 1);
        draw.beginFill(0x00ff00, 1);
        draw.drawCircle(50, 300, 40);
        draw.endFill();

        draw.lineStyle(10, 0xff0000, .25, .5);
        draw.beginFill(0x00ff00, 1);
        draw.drawCircle(150, 300, 40);
        draw.endFill();

        draw.lineStyle(10, 0xff0000, .25, 0);
        draw.beginFill(0x00ff00, 1);
        draw.drawCircle(250, 300, 40);
        draw.endFill();

        // with -1, the line offsets to the outside to the specified line width (thickness)
        draw.lineStyle(10, 0xff0000, .25, -1);
        draw.beginFill(0x00ff00, 1);
        draw.drawCircle(350, 300, 40);
        draw.endFill();

        /// ------

        // complex line style (joins and caps) uses a different "rendering" system...

        draw.lineStyle(12, 0xff0000, .75, 0, JointStyle.BEVEL, CapsStyle.ROUND);
        draw.beginFill(0x00ff00, .6);
        draw.drawRect(50, 50, 80, 80);
        draw.endFill();

        draw.lineStyle(20, 0xff0000, 1, 0.5, JointStyle.ROUND, CapsStyle.ROUND);
        draw.moveTo(120 + 60, 80);
        draw.lineTo(120 + 200, 200);
        draw.lineTo(120 + 300, 50);
        draw.lineTo(120 + 10, 200);

        draw.lineStyle(4, 0x00ff00, .7, 0.5, JointStyle.BEVEL, CapsStyle.NONE);
        draw.moveTo(120 + 60, 80);
        draw.lineTo(120 + 200, 200);
        draw.lineTo(120 + 300, 50);
        draw.lineTo(120 + 10, 200);

        // 2 color gradients in fills and lines (Thanks to @JohnBlackburne)
        draw.lineGradientStyle(5, 0xc21500, 0xffc500, Math.PI / 2, .4, .4, 0.5);
        draw.beginGradientFill(0xe4e4d9, 0x215f00, Math.PI, 1, 1);
        draw.drawRoundRectComplex(450, 280, 130, 90, 20, 12, 40, 20);
        draw.endFill();

    }
}
}
