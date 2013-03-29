/**
 * Created with IntelliJ IDEA.
 * User: igorp
 * Date: 15.03.13
 * Time: 16:31
 * To change this template use File | Settings | File Templates.
 */
package rotator {
public class UserObject extends BaseObject{
    public function UserObject(X:Number, Y:Number){
        super(X, Y);
        this.setSize(50);
        this.type=1;
    }
    public override function Draw():void
    {
        this.test.backGround.graphics.beginFill(Config.getUserColor());
        this.test.backGround.graphics.drawCircle(this.x, this.y, this.getSize()/10);
        super.Draw();
    }

}
}
