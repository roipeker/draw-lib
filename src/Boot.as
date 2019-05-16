package {

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;

import starling.core.Starling;

[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="60")]
public class Boot extends Sprite {

    private var starling:Starling;

    public function Boot() {
        loaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
    }

    private function onLoaderComplete(event:Event):void {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        stage.quality = StageQuality.HIGH;

        starling = new Starling(StarlingRoot, stage);
        starling.antiAliasing = 2;
        starling.supportBrowserZoom = false;
        starling.supportHighResolutions = true;
//        starling.skipUnchangedFrames = true;
        starling.simulateMultitouch = false;
        starling.start();

        stage.addEventListener(Event.RESIZE, onStageResize);
    }

    private function onStageResize(evt:Event):void {
        if (starling) {
            starling.stage.stageWidth = stage.stageWidth;
            starling.stage.stageHeight = stage.stageHeight;
            const viewport:Rectangle = starling.viewPort;
            viewport.width = stage.stageWidth;
            viewport.height = stage.stageHeight;
            starling.viewPort = viewport;
        }
    }
}
}
