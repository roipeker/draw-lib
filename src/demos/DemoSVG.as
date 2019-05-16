// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-15.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.svg.SVGDraw;

import flash.geom.Rectangle;

import starling.display.Sprite;
import starling.events.Event;
import starling.utils.RectangleUtil;

public class DemoSVG extends Sprite {

    public function DemoSVG() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {

        stage.color = 0x333333;

        var svg:SVGDraw = new SVGDraw();
        addChild(svg);

        // DrawLib has a limitation when it draws polygons, as it doesn't support winding.
        // So when you have "holes" inside shapes, you can fill them with a color, and define in the <svg holeColor='#color'/>
        // or set the property svg::holeColor=0xff0000.

//        svg.parse(svg_samples.icoYesXML); // the CHECK has a fill color that is defined as hole, check the SVG.
//        svg.parse(svg_samples.pencilXML);
//        svg.parse(svg_samples.materialIcoCheck);
//        svg.parse(svg_samples.gmailIcon);
//        svg.parse(svg_samples.icoErrorXml);
//        svg.parse(svg_samples.tiger);
//        svg.parse(svg_samples.android);
//        svg.parse(svg_samples.fish);
//        svg.parse(svg_samples.modzilla1);
//        svg.parse(svg_samples.apple);
//        svg.parse(svg_samples.face);
//        svg.parse(svg_samples.google);

//        svg.parse(svg_samples.naturalDisaster1);
//        svg.parse(svg_samples.naturalDisaster2);
        svg.parse(svg_samples.emergency1);

        // buggy
//        svg.parse(svg_samples.gmaps);
//        svg.parse(svg_samples.gphotos);

        // center pivot, adjust size, center...
        svg.validate();
        svg.alignPivot();

        const max:Rectangle = new Rectangle(0, 0, stage.stageWidth / 2, stage.stageHeight / 2);

        // match the biggest dimensions
        var out:Rectangle = RectangleUtil.fit(svg.bounds, max);
//        trace(out);

        svg.width = out.width;
        svg.height = out.height;
//        svg.scaleY = svg.scaleX;
        svg.x = stage.stageWidth / 2;
        svg.y = stage.stageHeight / 2;

        /*svg.width = stage.stageWidth / 2;
        svg.scaleY = svg.scaleX;
        svg.x = stage.stageWidth / 2;
        svg.y = stage.stageHeight / 2;*/

    }
}
}
