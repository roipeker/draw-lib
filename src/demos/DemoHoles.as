// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-15.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.Draw;

import starling.display.Sprite;
import starling.events.Event;

public class DemoHoles extends Sprite {

    public function DemoHoles() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {
        stage.color = 0x0;

        var g:Draw = new Draw();
        addChild(g);
        g.x = 200;
        g.y = 200;


        g.beginFill(0xff0000, .6);
        g.drawCircle(50, 50, 70);
        g.endFill();

        g.beginFill(0x00ff00, .7);
        g.drawCircle(20, 20, 90);
        g.endFill();

        g.beginHole();
        g.drawCircle(40, 40, 12);
        g.drawCircle(-10, -10, 20);
        g.drawRect(-30, -40, 10, 10);
        g.endHole();
    }
}
}
