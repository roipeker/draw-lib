// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 2019-05-15.
//
// =================================================================================================

package demos {
import com.roipeker.starling.draw.Draw;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Matrix;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.RenderTexture;
import starling.textures.Texture;
import starling.utils.MathUtil;

public class DemoTextureFill extends Sprite {

    [Embed(source="../assets/bricks_pow2.jpg")]
    public static const BricksSmallTextureAsset:Class;

    [Embed(source="../assets/roi.png")]
    public static const RoiTextureAsset:Class;

    [Embed(source="../assets/line_pattern.png")]
    public static const LinePattTextureAsset:Class;

    public function DemoTextureFill() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {

        stage.color = 0x333333;


//        test1();
        test2();
    }

    private function test2():void {
        var bd:BitmapData = new RoiTextureAsset().bitmapData;
        // NOTE: mipmapping is required for texture repeat!
        var tx:Texture = Texture.fromBitmapData(bd, false);

        const graphics:Draw = new Draw();
        graphics.x = 50;
        graphics.y = 20;
        addChild(graphics);

        // -- Flash drawing API --
        var shape:Shape = new Shape();
        Starling.current.nativeOverlay.addChild(shape);
        shape.x = 400;
        shape.y = 50//graphics.y + tx.height + 10;

        var matrix:Matrix = new Matrix();
        var displacement:Number = 0;

//        addEventListener(Event.ENTER_FRAME, update);

//        var img:Image = new Image();
//        img.tileGrid
//        update(null);

        // hack texture size?
        var tw:int = MathUtil.getNextPowerOfTwo(tx.width);
//        var tw2:int = MathUtil.getNextPowerOfTwo(tx.width/2);
        var th:int = MathUtil.getNextPowerOfTwo(tx.height);
        var img:Image = new Image(tx);
        img.readjustSize(tw,th);
        trace(tx.width,tx.height, img.width, tw, th);
        // need to use mipmaps in RenderTexture, so make a new RenderTexture with those params in true.
        var rt:RenderTexture = new RenderTexture(tw,th, true, 2);
        rt.draw(img);
        tx = rt ;
//        addChild(img);

        update(null);

        function update(e:Event):void {

            displacement += .5;// 2.5;

            matrix.identity();
            matrix.scale(.2, .2);
//            matrix.translate(displacement, 0);
//            matrix.rotate(Math.PI / 3);

            graphics.clear()
                    .beginTextureFill(tx, 0xffffff, .8, matrix, true)
                    .drawRect(0, 0, tx.width/2, tx.height/2 )
                    .endFill();

            // flash drawing.
            shape.graphics.clear();
            shape.graphics.beginBitmapFill(bd, matrix, true);
            shape.graphics.drawRect(0, 0, bd.width / 2, bd.height / 2);
            shape.graphics.endFill();
        }
    }

    private function test1():void {
        var bd:BitmapData = new BricksSmallTextureAsset().bitmapData;

        // NOTE: mipmapping is required for texture repeat!
        var tx:Texture = Texture.fromBitmapData(bd, true);

        var line_tx:Texture = Texture.fromEmbeddedAsset(LinePattTextureAsset, true);

        const graphics:Draw = new Draw();
        graphics.x = 50;
        graphics.y = 20;
        addChild(graphics);

        const graphicsBorder:Draw = new Draw();
        graphicsBorder.x = 50;
        graphicsBorder.y = 20;
        addChild(graphicsBorder);

        // -- Flash drawing API --
        var shape:Shape = new Shape();
        Starling.current.nativeOverlay.addChild(shape);
        shape.x = 50;
        shape.y = graphics.y + tx.height + 10;

        var matrix:Matrix = new Matrix();
        var displacement:Number = 0;

        addEventListener(Event.ENTER_FRAME, update);

        function update(e:Event):void {

            displacement += .5;// 2.5;

            matrix.identity();
            matrix.translate(displacement, 0);


            graphicsBorder.clear()
                    .lineTextureStyle(12, line_tx, true, 0x0000ff, 1, matrix)
                    .drawCircle(120, 120, 120)
                    .endFill();


            matrix.rotate(Math.PI / 3);

            graphics.clear()
                    .beginTextureFill(tx, 0xffffff, .8, matrix, true)
                    .drawRoundRect(0, 0, tx.width, tx.height, 10)
                    .endFill();

            // flash drawing.
            shape.graphics.clear();
            shape.graphics.beginBitmapFill(bd, matrix, true);
            shape.graphics.drawRoundRect(0, 0, tx.width, tx.height + 20, 10);
            shape.graphics.endFill();
        }
    }
}
}
