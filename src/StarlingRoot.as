// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-11.
//
// =================================================================================================

package {
import demos.*;

import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;

public class StarlingRoot extends Sprite {

    public function StarlingRoot() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        Starling.current.showStats = true;
    }

    private function onAddedToStage(event:Event):void {

        // just uncomment 1 line at a time to test.

        addChild(new DemoPixiSimple());
//        addChild(new DemoPixiAdvanced());
//        addChild(new DemoPixiDynamic());
//        addChild(new DemoAnimatedArc());
//        addChild(new DemoDashedLine());
//        addChild(new DemoCloneInstances());
//        addChild(new DemoHoles());
//        addChild(new DemoSVG());
//        addChild(new DemoPieChart());
//        addChild(new DemoGraphicsData());
//        addChild(new DemoLineStyles());
    }

}
}
