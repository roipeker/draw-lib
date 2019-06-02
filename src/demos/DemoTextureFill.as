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
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

public class DemoTextureFill extends Sprite {

    [Embed(source="../assets/bricks_pow2.jpg")]
    public static const BricksSmallTextureAsset:Class;

    [Embed(source="../assets/line_pattern.png")]
    public static const LinePattTextureAsset:Class;

    public function DemoTextureFill() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void {

        stage.color = 0x333333;

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
