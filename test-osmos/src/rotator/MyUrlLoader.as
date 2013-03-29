/**
 * Created with IntelliJ IDEA.
 * User: root
 * Date: 22.03.13
 * Time: 15:00
 * To change this template use File | Settings | File Templates.
 */
package rotator {
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

public class MyUrlLoader {
    public function MyUrlLoader() {
    }
    private var _loader:URLLoader;
    private var _request:URLRequest;

    public function loadData(url:String):void {
        _loader = new URLLoader();
        _request = new URLRequest(url);
        _request.method = URLRequestMethod.POST;
        _loader.addEventListener(Event.COMPLETE, onLoadData);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, onDataFailedToLoad);
        _loader.addEventListener(IOErrorEvent.NETWORK_ERROR, onDataFailedToLoad);
        _loader.addEventListener(IOErrorEvent.VERIFY_ERROR, onDataFailedToLoad);
        _loader.addEventListener(IOErrorEvent.DISK_ERROR, onDataFailedToLoad);
        _loader.load(_request);
    }
    private function onLoadData(e:Event):void {
        Config.configText= e.target.data;
        trace("onLoadData",e.target.data);
    }
    private function onDataFailedToLoad(e:IOErrorEvent):void {
        trace("onDataFailedToLoad:",e.text);
    }

}
}
