/**
 * Created with IntelliJ IDEA.
 * User: igorp
 * Date: 15.03.13
 * Time: 18:46
 * To change this template use File | Settings | File Templates.
 */
package rotator {
import flash.events.Event;
import flash.trace.Trace;

import org.osmf.elements.compositeClasses.SerialElementSegment;


public class ConcurrentObject extends BaseObject{
    private var TargetX:Number=-1;
    private var TargetY:Number=-1;

    public function ConcurrentObject(X:Number, Y:Number) {
        super(X, Y);
        TargetX=-1;
        TargetY = -1;
        MaxSpeed=Math.random()*2+0.1;

    }
    public override function Draw():void
    {
        this.test.backGround.graphics.beginFill(Config.getEnemyColor(this.test.getUserSize(),this.getSize()));
        this.test.backGround.graphics.drawCircle(this.x, this.y, this.getSize()/10);

    }
    private function checkCell(X:Number, Y:Number, R:Number):Boolean
    {
        var dx:Number = this.x - X;
        var dy:Number = this.y - Y;
        var length:Number =Math.sqrt(dx*dx+dy*dy)+R;
        if(length<this.getSize())
            return true;

        return false;
    }
    public override function Move():void
    {
        if(this.x!=this.TargetX||this.y!=this.TargetY||(this.TargetX==-1&&this.TargetY==-1))
        {
            if(this.TargetX==-1&&this.TargetY==-1)
            {
                this.TargetX = Math.random() * (Config.windowWidth-this.getSize())+this.getSize();
                this.TargetY = Math.random() * (Config.windowHeight-this.getSize())+this.getSize();
            }
            else
            {
                var dx:Number, dy:Number;
                dx = this.TargetX-this.x;
                dy = this.TargetY-this.y;
                if(dx*dx+dy*dy>MaxSpeed)
                {
                    var n:Number = dy/dx;
                    var dxt:Number = Math.sqrt(MaxSpeed/(n*n+1));
                    if(dx>0) {
                    }
                    else
                        dxt = -dxt;
                    var dyt:Number=dxt*n;
                    if(dy>0){
                        dyt = Math.abs(dyt);
                    }
                    else
                        dyt = -Math.abs(dyt);
                    dx = dxt;
                    dy = dyt;
                    this.x+=dx;
                    this.y+=dy;
                    this.prevDx=dx;
                    this.prevDy=dy;
                    if(this.test!=null)
                    {
                        var Trace:MyTrace=new MyTrace(this.x-dx*this.getSize()/20, this.y-dy*this.getSize()/20,this.getSize()/10);
                        Trace.test=this.test;
                        this.test.traces.push(Trace);
                    }
                }
                else
                {
                    this.x = this.TargetX;
                    this.y = this.TargetY;
                    if(this!=null)
                        this.TargetX = Math.random() * Config.windowWidth;
                    if(this!=null)
                        this.TargetY = Math.random() * Config.windowHeight;
                }
            }
        }

        //super.Move(event);
    }

}
}
