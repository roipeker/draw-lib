// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-15.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.Draw;

import starling.display.Sprite;
import starling.events.Event;

/**
 *
 * Ported from
 * https://pixijs.io/examples/#/graphics/advanced.js
 *
 * WARNING: texture fills/lineStyles not supported.
 *
 */
public class DemoPixiAdvanced extends Sprite {

    public function DemoPixiAdvanced() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {

        stage.color = 0x333333;

//        const sprite = PIXI.Sprite.from('examples/assets/bg_rotate.jpg');

// // BEZIER CURVE ////
// information: https://en.wikipedia.org/wiki/Bézier_curve

        const realPath:Draw = new Draw();
        realPath.lineStyle(2, 0xFFFFFF, 1);
        realPath.moveTo(0, 0);
        realPath.lineTo(100, 200);
        realPath.lineTo(200, 200);
        realPath.lineTo(240, 100);

        realPath.x = 50;
        realPath.y = 50;

        addChild(realPath);


        const bezier:Draw = new Draw();
        bezier.lineStyle(5, 0xAA0000, 1);
        bezier.bezierCurveTo(100, 200, 200, 200, 240, 100);

        bezier.x = 50;
        bezier.y = 50;

        addChild(bezier);


// // BEZIER CURVE 2 ////
        const realPath2:Draw = new Draw();
        realPath2.lineStyle(2, 0xFFFFFF, 1);
        realPath2.moveTo(0, 0);
        realPath2.lineTo(0, -100);
        realPath2.lineTo(150, 150);
        realPath2.lineTo(240, 100);

        realPath2.x = 320;
        realPath2.y = 150;

        addChild(realPath2);



        const bezier2:Draw = new Draw();
        bezier2.lineStyle(10, 0xffffff);
//        bezier2.lineTextureStyle(10, sprite.texture);
        bezier2.bezierCurveTo(0, -100, 150, 150, 240, 100);

        bezier2.x = 320;
        bezier2.y = 150;

        addChild(bezier2);

// // ARC ////
        const arc:Draw = new Draw();
        arc.lineStyle(5, 0xAA00BB, 1);
        arc.arc(600, 100, 50, Math.PI, 2 * Math.PI);

        addChild(arc);

// // ARC 2 ////
        const arc2:Draw = new Draw();
        arc2.lineStyle(6, 0x3333DD, 1);
        arc2.arc(650, 270, 60, 2 * Math.PI, 3 * Math.PI / 2);

        addChild(arc2);

// // ARC 3 ////
        const arc3:Draw = new Draw();
        arc3.lineStyle(20, 0xff0000);
//        arc3.lineTextureStyle(20, sprite.texture);
        arc3.arc(650, 420, 60, 2 * Math.PI, 2.5 * Math.PI / 2);

        addChild(arc3);

// / Hole ////
        const rectAndHole:Draw = new Draw();
        rectAndHole.beginFill(0x00FF00);
        rectAndHole.drawRect(350, 350, 150, 150);
        rectAndHole.beginHole();
        rectAndHole.drawCircle(375, 375, 25);
        rectAndHole.drawCircle(425, 425, 25);
        rectAndHole.drawCircle(475, 475, 25);
        rectAndHole.endHole();
        rectAndHole.endFill();

        addChild(rectAndHole);

// // Line Texture Style ////
        const beatifulRect:Draw = new Draw();

//        beatifulRect.lineTextureStyle(20, sprite.texture);
        beatifulRect.lineStyle(20, 0x00ff00);
        beatifulRect.beginFill(0xFF0000);
        beatifulRect.drawRect(80, 350, 150, 150);
        beatifulRect.endFill();

        addChild(beatifulRect);
    }
}
}
