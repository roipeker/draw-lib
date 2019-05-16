// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-15.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.Draw;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class DemoGraphicsData extends Sprite {

    private var isHovering:Boolean = false;
    private var ninja2:Draw;

    public function DemoGraphicsData() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {
        stage.color = 0xffffffff;

        // old school, mimic graphics data.

        var ninja1:Draw = makeDrawFromMovieClip(new ninja_girl_idle());
        ninja1.x = ninja1.width / 2;
        ninja1.y = ninja1.height / 2;


        // as we can see with these MovieClips from the SWC,
        // Draw's drawing commands are a little buggy.

        var koala:Draw = makeDrawFromMovieClip(new koala_mc());
        koala.scale = .5;
        koala.x = stage.stageWidth - koala.width / 2;
        koala.y = koala.height / 2;


        var mole:Draw = makeDrawFromMovieClip(new mole_mc());
        mole.x = stage.stageWidth - mole.width / 2;
        mole.y = stage.stageHeight - mole.height / 2;

        var pinocchio:Draw = makeDrawFromMovieClip(new pinocchio_mc());
        pinocchio.scale = .5;
        pinocchio.x = pinocchio.width / 2;
        pinocchio.y = stage.stageHeight - pinocchio.height / 2;

        // centered, animated, interactive ninja

        ninja2 = new Draw();
        addChild(ninja2);

        // copy ninja1 geometry, (no need for parsing).
        ninja2.copyFrom(ninja1, true);
        ninja2.alignPivot();
        ninja2.scale = 0.1;

        ninja2.x = stage.stageWidth / 2;
        ninja2.y = stage.stageHeight / 2;

        // scale ninja
        Starling.juggler.tween(ninja2, 4, {scale: 6, reverse: true, repeatCount: 0, repeatDelay: 1});

        ninja2.rotation = -.3;
        Starling.juggler.tween(ninja2, .7, {
            rotation: .3,
            reverse: true,
            repeatCount: 0,
            transition: Transitions.EASE_IN
        });

        ninja2.touchable = true;
        ninja2.addEventListener(TouchEvent.TOUCH, handleNinjaTouch);
    }

    private function handleNinjaTouch(e:TouchEvent):void {
        var t:Touch = e.getTouch(ninja2);
        if (t && t.phase == TouchPhase.HOVER) {
            // HOVER
            hover(true);
        } else if (t == null) {
            // OUT
            hover(false);
        }
    }

    private function hover(flag:Boolean):void {
        if (isHovering == flag) return;
        isHovering = flag;
        Starling.juggler.tween(ninja2, .15,
                {alpha: isHovering ? 0.5 : 1, transition: Transitions.EASE_OUT});
    }

    private function makeDrawFromMovieClip(mc:MovieClip):Draw {
        var draw:Draw = new Draw();
        addChild(draw);
        draw.drawGraphicsData(getGraphics(mc).readGraphicsData());
        draw.validate();
        draw.alignPivot();
//        draw.touchGroup = true ;
        draw.touchable = false;
        return draw;
    }

    private function getGraphics(mc:MovieClip):Graphics {
        return Shape(mc.getChildAt(0)).graphics;
    }
}
}
