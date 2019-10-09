package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

import starling.core.Starling;

[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="60")]
public class Boot extends Sprite {

    private var starling:Starling;

    public function Boot() {

        init2();

//        loaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
    }

    private function init2():void {
        var path:String = '/Users/rodrigo/dev/flutter/mine/flutter_scrapper/assets/images/wild.png';
        var f:File = new File(path);
        var fs:FileStream = new FileStream();
        var ba:ByteArray = new ByteArray();
        fs.open(f,FileMode.READ);
        fs.readBytes(ba);
        fs.close();

        var loader:Loader= new Loader();
        loader.contentLoaderInfo.addEventListener("complete", function(e){


            var bd:BitmapData = Bitmap(loader.content).bitmapData;
            trace( bd.width>>1, bd.height>>1 );
//            var px:uint = bd.getPixel(bd.width>>1, bd.height>>1);
            var px:uint = bd.getPixel32(473, 856);

            trace('iag loaded', px, '-', px.toString(16));

        });
        loader.loadBytes(ba);
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
