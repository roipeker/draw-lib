// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-15.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.Draw;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

/**
 * Ported from
 * https://pixijs.io/examples/#/graphics/dynamic.js
 */
public class DemoPixiDynamic extends Sprite {

    public function DemoPixiDynamic() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {

        stage.color = 0x333333;
        stage.color = 0x0;

        const graphics:Draw = new Draw();
        addChild(graphics);

        // set a fill and line style
        graphics.beginFill(0xFF3300);
        graphics.lineStyle(10, 0xffd900, 1);

        // draw a shape
        graphics.moveTo(50, 50);
        graphics.lineTo(250, 50);
        graphics.lineTo(100, 100);
        graphics.lineTo(250, 220);
        graphics.lineTo(50, 220);
        graphics.lineTo(50, 50);
        graphics.endFill();

        // set a fill and line style again
        graphics.lineStyle(10, 0xFF0000, 0.8);
        graphics.beginFill(0xFF700B, 1);

        // draw a second shape
        graphics.moveTo(210, 300);
        graphics.lineTo(450, 320);
        graphics.lineTo(570, 350);
        graphics.quadraticCurveTo(600, 0, 480, 100);
        graphics.lineTo(330, 120);
        graphics.lineTo(410, 200);
        graphics.lineTo(210, 300);
        graphics.endFill();

        // draw a rectangle
        graphics.lineStyle(2, 0x0000FF, 1);
        graphics.drawRect(50, 250, 100, 100);

        // draw a circle
        graphics.lineStyle(0);
        graphics.beginFill(0xFFFF0B, 0.5);
        graphics.drawCircle(470, 200, 100);
        graphics.endFill();

        graphics.lineStyle(20, 0x33FF00);
        graphics.moveTo(30, 30);
        graphics.lineTo(600, 300);


        // let's create a moving shape
        var thing:Draw = new Draw();
        addChild(thing);
        thing.x = 620 / 2;
        thing.y = 380 / 2;

        // avoid frame drops on mouse move.
        thing.touchable = false;
        graphics.touchable = false;

        var count:Number = 0;

        stage.addEventListener(TouchEvent.TOUCH, handleTouch);

        // run the render loop
        addEventListener(Event.ENTER_FRAME, animate);

        // Just click on the stage to draw random lines
        function handleTouch(e:TouchEvent) {
            var t:Touch = e.getTouch(stage, TouchPhase.BEGAN);
            if (t) onClick();
        }

        function onClick() {
            graphics.lineStyle(Math.random() * 30, Math.random() * 0xFFFFFF, 1);
            graphics.moveTo(Math.random() * 620, Math.random() * 380);
            graphics.bezierCurveTo(Math.random() * 620, Math.random() * 380,
                    Math.random() * 620, Math.random() * 380,
                    Math.random() * 620, Math.random() * 380);
        }

        function animate() {
            count += 0.1;
            thing.clear();
            thing.lineStyle(10, 0xff0000, 1);
            thing.beginFill(0xffFF00, 0.5);

            thing.moveTo(-120 + Math.sin(count) * 20, -100 + Math.cos(count) * 20);
            thing.lineTo(120 + Math.cos(count) * 20, -100 + Math.sin(count) * 20);
            thing.lineTo(120 + Math.sin(count) * 20, 100 + Math.cos(count) * 20);
            thing.lineTo(-120 + Math.cos(count) * 20, 100 + Math.sin(count) * 20);
//            thing.lineTo(-120 + Math.sin(count) * 20, -100 + Math.cos(count) * 20);
            thing.closePath();

            thing.rotation = count * 0.1;
        }
    }
}
}
