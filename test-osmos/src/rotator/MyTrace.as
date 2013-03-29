/**
 * Created with IntelliJ IDEA.
 * User: root
 * Date: 22.03.13
 * Time: 10:24
 * To change this template use File | Settings | File Templates.
 */
package rotator {
/**
 * Это класс следа, который остается за объектом
 */
public class MyTrace extends BaseObject {
    public var TimeToLive:Number = 5;
    public function MyTrace(X:Number, Y:Number,R:Number) {
        super(X, Y);
        TimeToLive=R;
    }
    public override function Draw():void
    {
        test.backGround.graphics.lineStyle(2,0xFFFFFF,0.2);
        test.backGround.graphics.beginFill(0xDDDDDD,0.4);
        test.backGround.graphics.drawCircle(this.x, this.y, this.TimeToLive/2);
    }

}
}
