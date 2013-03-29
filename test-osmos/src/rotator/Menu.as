/**
 * Created with IntelliJ IDEA.
 * User: root
 * Date: 19.03.13
 * Time: 10:25
 * To change this template use File | Settings | File Templates.
 */
package rotator {
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.net.SecureSocket;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.sampler.getSavedThis;
import flash.text.TextField;
import flash.text.TextSnapshot;

import mx.core.FlexSprite;
import mx.core.FlexTextField;

public class Menu extends Sprite {
    private var objects:Array;
    private var test:Test;
    public var FS:SButton;
    public var RS:SButton;
    public var PS:SButton;
    public var MS:SButton;
    public static var recordArray:Array;
    public static var currentPosition:Number;
    public static var Loaded:Boolean=false;
    public var records:Array;
    public var ListVisible:Boolean=true;

    public function Menu(_test:Test) {
        test = _test;
        var button:SButton=new SButton(0);
        button.addEventListener(MouseEvent.CLICK, Restart);
        RS = button;
        this.addChild(button);
        button=new SButton(1);
        button.addEventListener(MouseEvent.CLICK, Pause);
        PS = button;
        this.addChild(button);
        button=new SButton(2);
        button.addEventListener(MouseEvent.CLICK, SwitchFullScreen);
        FS = button;
        this.addChild(button);
        button=new SButton(3);
        button.addEventListener(MouseEvent.CLICK, ShowMenu);
        MS = button;
        this.addChild(button);
        objects = new Array();
        var countObjects:Number = Math.random()*200+150;
        for(var i:int = 0;i<countObjects;i++)
        {
            var Obj:ConcurrentObject=new ConcurrentObject(Math.random()*Config.windowWidth,Math.random()*Config.windowHeight);
            objects.push(Obj);
        }
        super();
    }

    /**
     * Нажатие на "меню"
     * @param event
     */
    public function ShowMenu(event:MouseEvent):void
    {
        ClearTable();
        if(this.ListVisible)
        {
            //LoadList();
            test.callMenu();
        }
        else
        {
            LoadList();

        }
    }

    /**
     * Нажатие на "полный экран"
     * @param event
     */
    public function SwitchFullScreen(event:MouseEvent):void
    {
        test.doFullScreen();
        HideRecords();
    }

    /**
     * нажатие на "рестарт"
     * @param event
     */
    public function Restart(event:MouseEvent):void
    {
        test.Load();
        HideRecords();
    }

    /**
     * нажатие на "пауза"
     * @param event
     */
    public function Pause(event:MouseEvent):void
    {
        test.Pause();
        HideRecords();
    }

    /**
     * Отрисовка меню
     * @param graphics
     */
    public function Draw(graphics:Graphics):void
    {
        graphics.clear();
        graphics.beginFill(0x040F4F);
        graphics.drawRect(Config.stage.x,Config.stage.y, Config.stage.stageWidth,Config.stage.stageHeight);
        for each(var object:ConcurrentObject in objects)
        {
            object.Move();
            graphics.beginFill(0x272C45,1);
            graphics.lineStyle(2,0xFFFFFF,0.2,false,"normal",null,null,3);
            graphics.drawCircle(object.x, object.y, object.getSize()/10);
        }

    }

    /**
     * Скрыть таблицу рекордов
     */
    public function HideRecords():void
    {
        var count:Number=numChildren;
        for(var i:int = 0;i<count;i++)
        {
            var child:Object = getChildAt(i);
            if(child is FlexTextField)
            {
                child.visible = false;
            }
        }
    }

    /**
     * Сделать таблицу рекордов видимой
     */
    public function ShowRecords():void
    {
        var count:Number=numChildren;
        for(var i:int = 0;i<count;i++)
        {
            var child:Object = getChildAt(i);
            if(child is FlexTextField)
            {
                child.visible = true;
            }
        }
    }

    /**
     * Сформировать записи в таблице рекордов по имеющимся данным
     */
    public function createRecords():void
    {
        records = new Array();
        for each(var obj:Object in Menu.recordArray)
        {
            var tf:TextField=new FlexTextField();
            tf.text=new Record(obj).toString();
            records.push(tf);
        }
        trace(records);
        var i:int = 0;
        for each(var record:FlexTextField in records)
        {
            record.x = 100;
            record.y = i*20;
            record.width=300;
            record.textColor=0xFFFFFF;
            i++;
            this.addChild(record);
        }
        HideRecords();
    }

    /**
     *
     */
    public function MoveDown():void
    {
        /*
        var count:Number=numChildren;
        Menu.currentPosition--;
        var countPerPage:Number = Math.round(Config.windowHeight/20);
        if(Menu.currentPosition>=0-count+countPerPage)
        {
            for(var i:int = 0;i<count;i++)
            {
                var child:Object = getChildAt(i);
                if(child is FlexTextField)
                {
                    child.y-=20;
                }
            }
        }*/
    }
    public function MoveUp():void
    {
        /*
        var count:Number=numChildren;
        Menu.currentPosition++;
        if(Menu.currentPosition+Config.windowHeight<count*20)
        {
            for(var i:int = 0;i<count;i++)
            {
                var child:Object = getChildAt(i);
                if(child is FlexTextField)
                {
                    child.y+=20;
                }
            }
        } */
    }

    /**
     * Очистить таблицу
     */
    public function ClearTable():void
    {
        var count:Number = numChildren;
        for(var i:int = 0;i<numChildren;i++)
        {
            var child:Object = getChildAt(i);
            if(child is FlexTextField)
            {
                this.removeChildAt(i);
                i--;
            }
        }
    }

    /**
     * Загрузить список
     */
    internal function LoadList():void
    {
        var req:URLRequest = new URLRequest("http://test-project.16mb.com/index.php/records/getlist");
        req.method = URLRequestMethod.GET;
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(ErrorEvent.ERROR,onError);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
        loader.addEventListener(Event.COMPLETE,onLoadList);

        loader.load(req);
    }

    internal function onError(e:ErrorEvent):void
    {
        trace(e);
    }

    /**
     * Действие по загрузке списка
     * @param e
     */
    internal function onLoadList(e:Event):void
    {
        Menu.currentPosition = 0;
        Menu.recordArray = Array(JSON.parse(e.target.data))[0];
        Menu.Loaded = true;
        createRecords();
        ShowRecords();
        test.callMenu();
    }


}

}
