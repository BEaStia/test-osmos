/**
 * Created with IntelliJ IDEA.
 * User: root
 * Date: 19.03.13
 * Time: 11:43
 * To change this template use File | Settings | File Templates.
 */
package rotator {
import flash.display.Graphics;
import flash.display.Sprite;

public class MenuButton extends Sprite{
    public function MenuButton(State:String,graphics:Graphics) {
        if(State =="Up")
        {
            graphics.lineStyle(2,0x33621E,0.6);
            graphics.beginFill(0x888888);
            graphics.drawCircle(0,0,20);
        }
        if(State =="Down")
        {
            graphics.lineStyle(2,0x9F91B5,0.6);
            graphics.beginFill(0x888888);
            graphics.drawCircle(0,0,20);
        }
        if(State =="Over")
        {
            graphics.beginFill(0xFFFFFF);
            graphics.drawCircle(0,0,20);
        }
        if(State =="HitState")
        {
            graphics.beginFill(0xFFFFFF);
            graphics.drawCircle(0,0,20);
        }
    }
}
}
