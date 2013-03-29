/**
 * Created with IntelliJ IDEA.
 * User: root
 * Date: 23.03.13
 * Time: 14:25
 * To change this template use File | Settings | File Templates.
 */
package rotator {
import flash.display.Stage;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import mx.core.IFlexAsset;
import mx.utils.Base64Encoder;

import org.osmf.elements.compositeClasses.SerialElementSegment;

import vk.APIConnection;

public class User {
    public var test:Test;
    public function User(_test:Test) {
        this.test = _test;
    }

    public function AddRecord(result:Number,stage:Stage):void
    {
        var flashVars: Object = stage.loaderInfo.parameters as Object;
        if (!flashVars.api_id) {
            var e:Array = new Array();
            var f:Object = new Object();
            f.first_name='test';
            f.last_name='user';
            f.uid = '1';
            e.push(f);
            onComplete(e);

        }
        else
        {
            var VK: APIConnection = new APIConnection(flashVars);

            //VK.api('users.get',flashVars['viewer_id']);
            VK.api('users.get',{uids: flashVars['viewer_id']},onComplete,onError);
        }

    }
    public function onComplete(e:Object):void
    {
        //SendData("complete"+e[0]['first_name']+" "+e[0]['last_name']);
        var req:URLRequest = new URLRequest("http://test-project.16mb.com/index.php/records/addRecord");
        req.method = URLRequestMethod.POST;
        var UrlVars:URLVariables=new URLVariables();
        UrlVars.result=test.tf.text;
        var encoder:Base64Encoder = new Base64Encoder();
        encoder.encodeUTFBytes(e[0]['first_name']+":"+e[0]['last_name']);
        UrlVars.encoded=encoder.toString();

        var encoder:Base64Encoder = new Base64Encoder();
        encoder.encodeUTFBytes('http://vk.com/id'+e[0]['uid']);
        UrlVars.anchor=encoder.toString();

        req.data = UrlVars;

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE,Show);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
        loader.load(req);
    }
    public function onError(e:ErrorEvent):void
    {
        //SendData("error"+ e.toString());
        trace(e);
    }

    public function SendData(str:String):void
    {

        var req:URLRequest = new URLRequest("http://test-project.16mb.com/index.php/records/write");
        req.method = URLRequestMethod.POST;
        var UrlVars:URLVariables=new URLVariables();
        UrlVars.result=str;
        req.data = UrlVars;
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
        loader.load(req);
    }
    public function Show(event:Event):void
    {
        trace(event.target);
        SendData(event.target.toString());
    }


}
}
