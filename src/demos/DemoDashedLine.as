// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-15.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.Draw;

import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;

public class DemoDashedLine extends Sprite {

    public function DemoDashedLine() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {
        const d:Draw = new Draw();
        d.x = 100;
        d.y = 100;
        addChild(d);

        const tweenObj:Object = {linePercent: 0};

        const polygon:Array = [
            10, 10,
            50, 15,
            60, 60,
            20, 40
        ];

        Starling.juggler.tween(tweenObj, 1, {linePercent: 1, repeatCount: 0, onUpdate: drawit});

        function drawit():void {
            d.clear();
            d.lineStyle(2, 0xff0000 );
            d.beginFill(0x00ff00, .5);
            d.dashedPolygon(polygon, 5, 3, tweenObj.linePercent);
            d.drawCircle(100,100,40);
        }

    }
}
}
