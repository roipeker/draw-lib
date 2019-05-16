// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-15.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.Draw;

import starling.animation.Tween;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class DemoAnimatedArc extends Sprite {

    public function DemoAnimatedArc() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {
        stage.color = 0xffffff ;

        const g:Draw = new Draw();
        addChild(g);

        // tween these properties
        const arcData:Object = {
            x: 150,
            y: 150,
            radius: 150 / 3,
            angle: 10,
            color: 0xff0000
        };

        g.addEventListener(TouchEvent.TOUCH, handleTouch);

        function handleTouch(e:TouchEvent):void {
            // when clicked.
            var t:Touch = e.getTouch(g, TouchPhase.BEGAN);
            if (t) {
                arcData.color = Math.random() * 0xffffff;
                if (tween.progress == 0 || tween.progress == 1) {
                    drawArc();
                }
            }
        }

        const RAD:Number = Math.PI / 180;
        var tween:Tween;
        tween = new Tween(arcData, 1, 'linear');
        tween.reverse = true;
        tween.repeatCount = 0;
        tween.repeatDelay = .5;
        tween.onUpdate = drawArc;
        tween.animate('angle', 361);
        Starling.juggler.add(tween);

        function drawArc():void {
            g.clear()
                    .lineStyle(20, arcData.color, 1)
                    //                    .lineGradientStyle(30, 0xff0000, 0xff00ff, .3 )
                    .arc(arcData.x, arcData.y, arcData.radius, 0, arcData.angle * RAD);
        }

        pacman();
    }

    private function pacman():void {
        var pacman:Draw = new Draw();
        addChild(pacman);

        pacman.x = 400;
        pacman.y = 200;

        var o:Object = {p: 0.1, b: 1};


        Starling.juggler.tween(o, .25, {p: 1, reverse: true, repeatCount: 0, onUpdate: drawPackman});

        drawPackman();

        blink();

        function blink() {
            Starling.juggler.tween(o, .12, {
                delay: .1 + Math.random(),
                b: 0,
                reverse: true,
                onComplete:blink,
                repeatCount: 2
            });
        }

        function drawPackman():void {

            const maxAngle:Number = Math.PI * 2 / 4;

            var angle:Number = o.p * maxAngle;
            var endAng:Number = Math.PI * 2 - angle / 2;

            pacman.clear()
                    .lineStyle(4, 0x0, .5, 1)
                    .beginFill(0xfdea6c, 1)
                    .moveTo(0, 0)
                    .arc(0, 0, 80, angle / 2, endAng)
                    .lineTo(0, 0)
                    .endFill()

                    .lineStyle(0)

                    .beginFill(0xf2d159, 1)
                    .moveTo(0, 0)
                    .arc(0, 0, 80, angle/2,Math.PI )
                    .lineTo(0, 0)
                    .endFill()

                    .beginFill(0x4d4d4d, .95)
                    .drawEllipse(10 - Math.cos(endAng) * 10, -30 + Math.sin(endAng) * 20, 12, 12 * o.b)
                    .endFill()

//                    .beginFill(0x462b57, .95)
                    .lineStyle(4, 0x0, 1)
                    .moveTo(Math.cos(endAng)*80,Math.sin(angle/2)*80)
                    .lineTo(200,200);
        }


    }
}
}
