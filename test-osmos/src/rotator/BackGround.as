/**
 * Created with IntelliJ IDEA.
 * User: igorp
 * Date: 15.03.13
 * Time: 14:41
 * To change this template use File | Settings | File Templates.
 */
package rotator {
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.sampler.getSize;
import flash.ui.Mouse;

public class BackGround extends Sprite{

    private var state:int = 0;//состояние фона
    private var size:int = 5;//размерность силы отталкивания
    private var MouseX:int = 0;//положение щелчка по X
    private var MouseY:int = 0;//положение щелчка по Y
    /**
     * Цвет фона
     */
    private var bkColor1:int = 0x182E85;
    private var x0:int = 0;
    private var y0:int = 0;
    /**
     * макс. X
     */
    private var xMax:int = 1920;
    /**
     * макс. Y
     */
    private var yMax:int = 1080;

    public function BackGround() {
        xMax = Config.windowWidth;
        yMax = Config.windowHeight;
        graphics.beginFill(bkColor1);
        graphics.drawRect(x0,y0,xMax,yMax);
    }
    public function getSize():int
    {
        return size;
    }
    public function onMouseDown(event:MouseEvent):void {
        state = 1;
        MouseX = event.localX;
        MouseY = event.localY;
    }
    public function onMouseUp(event:MouseEvent):void {

        state = 0;
    }
    public function onMouseMove(event:MouseEvent):void
    {
        MouseX=event.localX;
        MouseY = event.localY;
    }
    public function Update(event:Event):void
    {
        this.graphics.clear();
        this.graphics.beginFill(bkColor1);
        this.graphics.drawRect(x0,y0,xMax,yMax);
    }
}
}
