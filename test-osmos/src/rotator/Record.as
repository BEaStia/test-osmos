/**
 * Created with IntelliJ IDEA.
 * User: Beastia
 * Date: 28.03.13
 * Time: 13:21
 * To change this template use File | Settings | File Templates.
 */
package rotator {

public class Record
{
    public var recordDate:Number;
    public var recordId:Number;
    public var recordSpeed:Number;
    public var userName:String;

    /**
     * Запись в таблице
     * @param obj
     */
    public function Record(obj:Object)
    {
        this.recordDate=obj.recordDate;
        this.recordId=obj.recordId;
        this.recordSpeed=obj.recordSpeed;
        this.userName=obj.userName;
    }
    public function toString():String
    {
        var S:String = "";
        var date:Date=new Date();
        date.setTime(recordDate*1000);
        var i:Number = date.time;
        S+=date.toDateString();
        S+=" "+recordSpeed.toString()+" "+userName;
        return S;
    }
}
}
