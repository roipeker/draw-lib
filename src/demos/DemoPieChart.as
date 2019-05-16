// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-16.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.Draw;
import com.roipeker.starling.draw.utils.GraphicCurves;

import starling.animation.Transitions;

import starling.core.Starling;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.text.TextFormat;

public class DemoPieChart extends Sprite {

    public function DemoPieChart() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {

        // improves
        GraphicCurves.adaptive = true;


        var cmd:Draw = new Draw();
        addChild(cmd);

        cmd.x = stage.stageWidth / 2;
        cmd.y = stage.stageHeight / 2;

        // colors...
        const colors:Array = [
            0x4D51A7, 0xF389D8, 0x4AC1B9, 0xAA74F3, 0xE3B490
        ];

        const colorData:Array = [];
        const numbers:Array = [
            'one', 'two', 'three', 'four', 'five'
        ];

        const format:TextFormat = new TextFormat(BitmapFont.MINI, -1, 0x0);
        colors.forEach(function (color:uint, i:int, arr:Array) {

            var p:Number = 1 / (colors.length);
            var text:TextField = new TextField(60, 10, numbers[i], format);
            text.batchable = true;
            text.alignPivot();
//            text.filter = new DropShadowFilter(1, 0.78, 0x0, .6, 1, .6);
            addChild(text);

            colorData.push({
                text: text,
                color: color,
                percent: p,
                fromPercent: 0,
                selectionPercent: 0,
                toPercent: 0
            });
        });

        var _selected:int = -1;
        stage.addEventListener(TouchEvent.TOUCH, handleStageTouch);

        function handleStageTouch(e:TouchEvent) {
            var t:Touch = e.getTouch(stage, TouchPhase.BEGAN);
            if (t) {
                selectNext();
            }
        }

        function selectNext():void {
            if (_selected > -1) {
                // tweeen the object.
                toggleSelection(_selected, false);
            }
            ++_selected;
            if (_selected > colorData.length - 1) {
                _selected = 0;
            }
            toggleSelection(_selected, true);
        }

        function toggleSelection(idx:int, flag:Boolean):void {
            Starling.juggler.tween(
                    colorData[idx], .5, {
                        selectionPercent: flag ? 1 : 0,
                        transition:Transitions.EASE_IN_OUT,
                        onUpdate: renderColors
                    }
            );
        }

        const tweenPercent:Object = {p: 0};
        const numColors:int = colorData.length;
        var startAngle:Number = 0;

        // grab one and tween.
        randomPercent();

        function randomPercent():void {
            var p:Number = 1;
            for (var i:int = 0; i < numColors; i++) {
                var reducer:Number = .1 + Math.random() * .4;
                var p2:Number = p * reducer;
                if (i == numColors - 1) {
                    p2 = p;
                } else {
                    p -= p2;
                }
                colorData[i].fromPercent = colorData[i].percent;
                colorData[i].toPercent = p2;
            }

            tweenPercent.p = 0;
            Starling.juggler.tween(tweenPercent, .5,
                    {
                        delay: .4,
                        p: 1,
                        onUpdate: transitionPercents,
                        onComplete: randomPercent,
                        transition: Transitions.EASE_OUT
                    });
        }

        function transitionPercents():void {
            for (var i:int = 0; i < numColors; i++) {
                const vo:Object = colorData[i];
                vo.percent = vo.fromPercent + (vo.toPercent - vo.fromPercent) * tweenPercent.p;

            }
//            cmd.rotation += .001;
            startAngle += .001;
            renderColors();
        }

        function renderColors() {
            const maxAngle:Number = Math.PI * 2;
            const radius:Number = 100;

            cmd.clear();

            for (var i:int = 0; i < colorData.length; i++) {
                const vo:Object = colorData[i];
                var angPercent:Number = vo.percent * maxAngle;
                var endAngle:Number = startAngle + angPercent;

                var selection:Number = vo.selectionPercent;
                var thickness:Number = 30 + selection * 30 ;

                cmd.lineStyle(thickness, vo.color, 1, selection/2);
                cmd.arc(0, 0, radius, startAngle, endAngle);

                var tf:TextField = vo.text;
                var textAngle:Number = startAngle + angPercent / 2;
                tf.x = cmd.x + Math.cos(textAngle) * (radius + 30 / 2 );
                tf.y = cmd.y + Math.sin(textAngle) * (radius + 30 / 2 );
                tf.rotation = textAngle + Math.PI / 2;
                tf.text = numbers[i] + ' ' + Math.round(vo.percent * 100) + '%';

                startAngle += angPercent;
            }
        }
    }
}
}
