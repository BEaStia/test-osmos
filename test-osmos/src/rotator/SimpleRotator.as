/**
 * Created with IntelliJ IDEA.
 * User: igorp
 * Date: 15.03.13
 * Time: 13:12
 * To change this template use File | Settings | File Templates.
 */
package rotator {

import flash.display.Sprite;
import flash.display.Shape;
import flash.utils.*;

public class SimpleRotator extends Sprite{

    public function SimpleRotator(x:int, y:int, time:Number) {
        this.x = x;
        this.y = y;

        this.graphics.beginFill(0x00FF00);
        this.graphics.drawRect( -13, -13, 26, 26);
        this.graphics.endFill();

        this.graphics.beginFill(0x00FF00);
        this.graphics.drawCircle(0, 0, 15);
        this.graphics.endFill();

        this.setTime(time);
    }
    public function setTime(time:Number):void {
        var intervalId:uint = setInterval(step, time);
    }

    public function step():void {
        this.rotation += 3;
    }
}
}
