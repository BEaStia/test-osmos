/**
 * Created with IntelliJ IDEA.
 * User: Beastia
 * Date: 20.03.13
 * Time: 18:44
 * To change this template use File | Settings | File Templates.
 */
package rotator {
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.display.Stage;
import flash.text.TextField;

public class SButton extends Sprite {
    public var button:SimpleButton;
    private var numButtonWidth:Number = 100;
    private var numButtonHeight:Number = 50;

    public function SButton(type:int) {
        button = new SimpleButton;
        button.upState = drawButtonState(0xDAD8F3,type);
        button.overState = drawButtonState(0x4F42C6,type);
        button.downState = drawButtonState(0xDDF2FF,type);
        button.hitTestState = drawButtonState(0xDDF2FF,type);
        button.useHandCursor = true;
        this.addChild(button);
    }

    private function drawButtonState(rgb:uint,type:int):Sprite {
        var sprite:Sprite = new Sprite();
        if(type == 0)
        {
            sprite.graphics.lineStyle(4,0x33621E,0.4);
            sprite.graphics.beginFill(rgb);
            sprite.graphics.drawCircle(0,0,30);
            sprite.graphics.lineStyle(4,0x33621E,1.0);
            sprite.graphics.beginFill(0x207A3D);
            sprite.graphics.moveTo(7,3);
            sprite.graphics.lineTo(7,12);
            sprite.graphics.moveTo(3,7);
            sprite.graphics.lineTo(12,7);
        }
        if(type == 1)
        {
            sprite.graphics.lineStyle(4,0x33621E,0.4);
            sprite.graphics.beginFill(rgb);
            sprite.graphics.drawCircle(Config.windowWidth,Config.windowHeight,30);
            sprite.graphics.lineStyle(4,0x33621E,1.0);
            sprite.graphics.beginFill(0x207A3D);
            sprite.graphics.moveTo(Config.windowWidth-11,Config.windowHeight-13);
            sprite.graphics.lineTo(Config.windowWidth-11,Config.windowHeight-3);
            sprite.graphics.moveTo(Config.windowWidth-6,Config.windowHeight-13);
            sprite.graphics.lineTo(Config.windowWidth-6,Config.windowHeight-3);
        }
        if(type == 2)
        {
            sprite.graphics.lineStyle(4,0x33621E,0.4);
            sprite.graphics.beginFill(rgb);
            sprite.graphics.drawCircle(Config.windowWidth,0,30);
            sprite.graphics.lineStyle(1,0x33621E,1.0);
            sprite.graphics.beginFill(0x207A3D);

            sprite.graphics.moveTo(Config.windowWidth-16,3);
            sprite.graphics.lineTo(Config.windowWidth-6,13);

            sprite.graphics.moveTo(Config.windowWidth-6,3);
            sprite.graphics.lineTo(Config.windowWidth-16,13);
        }
        if(type == 3)
        {
            sprite.graphics.lineStyle(4,0x33621E,0.4);
            sprite.graphics.beginFill(rgb);
            sprite.graphics.drawCircle(0,Config.windowHeight,30);
            sprite.graphics.lineStyle(2,0x33621E,1.0);
            sprite.graphics.beginFill(0x207A3D);

            sprite.graphics.moveTo(3,Config.windowHeight-13);
            sprite.graphics.lineTo(3,Config.windowHeight-3);
            sprite.graphics.moveTo(3,Config.windowHeight-13);
            sprite.graphics.lineTo(8,Config.windowHeight-8);
            sprite.graphics.moveTo(8,Config.windowHeight-8);
            sprite.graphics.lineTo(13,Config.windowHeight-13);
            sprite.graphics.moveTo(13,Config.windowHeight-13);
            sprite.graphics.lineTo(13,Config.windowHeight-3);
        }
        return sprite;
    }

}
}
