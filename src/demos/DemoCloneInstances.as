// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-15.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.Draw;

import starling.display.Sprite;
import starling.events.Event;

public class DemoCloneInstances extends Sprite {

    public function DemoCloneInstances() {
        addEventListener(Event.ADDED_TO_STAGE, init );
    }

    private function init(event:Event):void {
        const graph1:Draw = new Draw();
        addChild(graph1);

        graph1.beginFill(0x00ff00, .2);
        graph1.drawCircle(20, 20, 20);
        graph1.drawRoundRect(40,40,90, 60, 12);
        graph1.endFill();

        // geometry is SHARED with graph1
        /*var graph2:Draw = graph1.clone();
        addChild(graph2);
        graph2.x = 0;
        graph2.y = 200;
        // this will affect graph1 geometry as well.
        graph2.lineStyle(10, 0xff0000, .5);
        graph2.drawRect(100,100,50,50);*/

        var graph2:Draw = new Draw();
        addChild(graph2);
        graph2.x = 0;
        graph2.y = 200;
        graph2.copyFrom(graph1);


    }
}
}
