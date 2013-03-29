package {

import com.developmentarc.core.datastructures.utils.HashTable;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.sampler.getSavedThis;
import flash.system.Security;
import flash.system.System;
import flash.text.TextField;
import flash.ui.Mouse;
import flash.utils.Timer;
import rotator.BackGround;
import rotator.BaseObject;
import rotator.ConcurrentObject;
import rotator.Config;
import rotator.Menu;
import rotator.MyTrace;
import rotator.MyUrlLoader;
import rotator.User;
import rotator.UserObject;

[SWF(backgroundColor="0xec9900")]
public class Test extends Sprite {

    private var objectsToDelete:Array;
    public var tf:TextField;
    private var objects:Array;
    public var backGround:BackGround;

    private var GameState:String = "Menu";
    private var menu:Menu;

    private var mode:int=0;
    private var timer:Timer;
    public var traces:Array;
    public var LoadedColors:Boolean=false;
    public var LoadedEnemiesCount:Boolean=false;
    public var Merging:Sound;
    public var Victory:Sound;
    public var RecordSent:Boolean=false;

    private var objectsMaxCount:Number=60;

    public function Load()
    {
        if(this.backGround.numChildren!=0)
            this.backGround.removeChildren();
        Config.GenerateEnemies(objectsMaxCount);
        timer=new Timer(10);
        timer.start();
        GameState = "Game";

        stage.align="left";
        objects = new Array();
        objectsToDelete=new Array();
        var obj:BaseObject;
        var i:int = 0;
        for(i=0;i<Config.Positions.length-1;i++)
        {
            var X:int=HashTable(Config.Positions[i]).getItem("X"),Y:int=HashTable(Config.Positions[i]).getItem("Y"),R:int=HashTable(Config.Positions[i]).getItem("R");
            obj = new ConcurrentObject(X,Y);
            obj.test = this;
            obj.setSize(R);
            objects.push(obj);
        }

        obj = new UserObject(HashTable(Config.Positions[Config.Positions.length-1]).getItem("X"), HashTable(Config.Positions[Config.Positions.length-1]).getItem("Y"));
        obj.test = this;
        objects.push(obj);

        traces = new Array();

        tf=new TextField();
        tf.text = "0";
        tf.x = Config.windowWidth/2;
        tf.y = 0;
        this.backGround.addChild(tf);

        RecordSent=false;

    }
    private function _loading(e:Event):void
    {
        //Сюда можно поместить лого для загрузки
    }
    public function onError(e:ErrorEvent):void
    {
        //SendData("error"+ e.toString());
        trace(e);
    }
    public function Start():void//вызывается по окончанию загрузки файлов
    {
        this.removeEventListener(Event.ENTER_FRAME,_loading);
        removeChildren();

        var config:Config;
        Config.windowWidth=stage.stageWidth;
        Config.windowHeight=stage.stageHeight;
        if(Config.configText=="")
            config = new Config("",objectsMaxCount);
        else
            config = new Config(Config.configText,objectsMaxCount);
        backGround=new BackGround();
        Config.SetStage(this.stage);
        backGround.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
        backGround.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
        addEventListener(MouseEvent.MOUSE_MOVE,moveObjects);
        addEventListener(Event.ACTIVATE,activate);
        addEventListener(Event.DEACTIVATE,deactivate);
        addEventListener(Event.ENTER_FRAME,checkEnd);
        //stage.addEventListener(KeyboardEvent.KEY_UP, CheckKeyboard);
        stage.addEventListener(KeyboardEvent.KEY_DOWN,CheckKeyboard);
        addChild(backGround);


        this.menu=new rotator.Menu(this);
        menu.createRecords();
        this.addChild(menu);


        Load();
        addEventListener(Event.ENTER_FRAME, doEveryFrame);
        stage.align = StageAlign.TOP;


        function onSoundLoaded(event:Event):void
        {
            var localSound:Sound = event.target as Sound;
            localSound.play();
        }

    }
    public function Test() {

        Security.loadPolicyFile("http://test-project.16mb.com/crossdomain.xml");

        loadColors("http://test-project.16mb.com/config.conf");
        loadEnemiesCount("http://test-project.16mb.com/enemiesCount.txt");
        LoadList();
        var tA:TextField=new TextField();
        tA.text="Loading! \r\n Please wait!";
        tA.x = stage.stageWidth*0.4;
        tA.y = stage.stageHeight*0.45;
        this.addChild(tA);
        var req:URLRequest = new URLRequest("http://test-project.16mb.com/wind.mp3");
        Merging = new Sound(req);
        req = new URLRequest("http://test-project.16mb.com/triangle.mp3");
        Victory = new Sound(req);

        stage.frameRate = 30;
        var _loader:URLLoader;
        var _request:URLRequest;
        this.addEventListener(Event.ENTER_FRAME,_loading);

        function loadColors(url:String):void
        {
            _loader = new URLLoader();
            _request = new URLRequest(url);
            _request.method = URLRequestMethod.POST;
            _loader.addEventListener(Event.COMPLETE, onLoadColors);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, onDataFailedToLoad);
            _loader.addEventListener(IOErrorEvent.NETWORK_ERROR, onDataFailedToLoad);
            _loader.addEventListener(IOErrorEvent.VERIFY_ERROR, onDataFailedToLoad);
            _loader.addEventListener(IOErrorEvent.DISK_ERROR, onDataFailedToLoad);
            _loader.load(_request);
        }
        function onLoadColors(e:Event):void
        {
            Config.configText= e.target.data;
            LoadedColors=true;
            if(LoadedEnemiesCount&&Menu.Loaded)
                Start();
        }
        function onDataFailedToLoad(e:Event):void
        {
            trace("error in loading from server");
        }
        function loadEnemiesCount(url:String):void
        {
            _loader = new URLLoader();
            _request = new URLRequest(url);
            _request.method = URLRequestMethod.POST;
            _loader.addEventListener(Event.COMPLETE, onLoadEnemiesCount);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, onDataFailedToLoad);
            _loader.addEventListener(IOErrorEvent.NETWORK_ERROR, onDataFailedToLoad);
            _loader.addEventListener(IOErrorEvent.VERIFY_ERROR, onDataFailedToLoad);
            _loader.addEventListener(IOErrorEvent.DISK_ERROR, onDataFailedToLoad);
            _loader.load(_request);
        }
        function onLoadEnemiesCount(e:Event):void
        {
            this.objectsMaxCount= parseInt(e.target.data);
            LoadedEnemiesCount=true;
            if(LoadedColors&&Menu.Loaded)
                Start();
        }
        function LoadList():void
        {
            var req:URLRequest = new URLRequest("http://test-project.16mb.com/index.php/records/getlist");
            req.method = URLRequestMethod.GET;
            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE,onLoadList);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onDataFailedToLoad);
            loader.addEventListener(IOErrorEvent.NETWORK_ERROR, onDataFailedToLoad);
            loader.addEventListener(IOErrorEvent.VERIFY_ERROR, onDataFailedToLoad);
            loader.addEventListener(IOErrorEvent.DISK_ERROR, onDataFailedToLoad);
            loader.load(req);
        }
        function onLoadList(e:Event):void
        {
            Menu.currentPosition = 0;
            Menu.recordArray = Array(JSON.parse(e.target.data))[0];
            Menu.Loaded = true;

            if(LoadedColors&&LoadedEnemiesCount)
                Start();
        }
    }
    public function onMouseDown(event:MouseEvent):void
    {
        this.mode = 1;

    }
    public function onMouseUp(event:MouseEvent):void
    {
        this.mode = 0;

    }
    public function Pause():void
    {
        if(this.GameState=="Pause")
        {
            GameState="Game";
        }
        else
        {
            if(GameState=="Game")
                GameState="Pause";
        }
    }
    function ClearArray(array:Array):void
    {
        while(array.length>0)
            array.pop();
    }
    public function callMenu():void //вызов меню
    {
        if(GameState =="Menu")
        {
            menu.ListVisible=false;
            GameState = "Game";
        }
        else
        {
            if(GameState =="Game")
            {
                menu.ListVisible=true;
                GameState = "Menu";
            }
        }
    }
    function CheckKeyboard(event:KeyboardEvent):void
    {
        if(event.keyCode==48)
        {
            doFullScreen();
        }
        if(event.keyCode==49)
        {
            if(GameState =="Menu")
            {
                GameState = "Game";
            }
            else
            {
                if(GameState =="Game")
                {
                    GameState = "Menu";
                }
            }
        }
        if(event.keyCode==50)
        {
            if(GameState =="Pause")
            {
                GameState = "Game";
            }
            else
            {
                if(GameState =="Game")
                {
                    GameState = "Pause";
                }
            }

        }
        if(event.keyCode==51)
        {
            Load();
        }
        if(event.keyCode==13)
        {
            //trace(objects);
            var i:int=objects.length;
            trace(objects[i-1].x.toString()+" "+objects[i-1].y.toString());
            backGround.graphics.beginFill(0x0);
            backGround.graphics.drawCircle(objects[i-1].x,objects[i-1].y,20);
        }
        if(this.GameState=="Menu")
        {
            if(event.keyCode==40)
            {
                //вниз
                menu.MoveDown();
            }
            if(event.keyCode==38)
            {
                //вверх
                menu.MoveUp();
            }
            if(event.keyCode==39)
            {
                //вправо
            }
            if(event.keyCode==37)
            {
                //влево
            }
        }
        trace(event.keyCode);
    }
    public function doFullScreen():void
    {
        if(stage.displayState==StageDisplayState.NORMAL)
        {

            stage.scaleMode=StageScaleMode.EXACT_FIT;
            stage.displayState=StageDisplayState.FULL_SCREEN_INTERACTIVE;
        }
        else
        {
            stage.displayState=StageDisplayState.NORMAL;
            stage.scaleMode=StageScaleMode.SHOW_ALL;
        }
    }
    function checkEnd(event:Event):void
    {
        if(GameState =="Game")
        {
            var end:Boolean=false,win:Boolean = false;
            var Size:Number = 0;
            var HasUser:Boolean=false;
            for each(var Object:BaseObject in objects)
            {
                Size+=Object.getSize();//возьмем величину всех остальных
                if(Object.getType()==1)
                {
                    HasUser=true;
                }
            }
            if(!HasUser)
            {
                end = true;
                win = false;
            }
            else
            {
                for each(var Object:BaseObject in objects)
                {
                    if(Size-Object.getSize()<=Object.getSize())//и если какой-нибудь объект по размерам больше или равен всем остальным вместе взятым, то он выигрывает
                    {
                        end=true;
                        timer.stop();
                        if(Object.getType()==1)//определение, выиграл ли игрок
                        {
                            win=true;
                        }
                        else
                            win = false;
                    }
                }
            }
            if(end)//наступил ли конец
            {
                if(win)
                {   //победа
                    GameState ="Win";
                    var textfield:TextField = new TextField();
                    //textfield.antiAliasType="advanced";
                    textfield.htmlText="<h4>Победа!</h4>\r\n<i>Ваш результат: "+tf.text+"c</i>";
                    textfield.multiline=true;
                    if(stage.displayState==StageDisplayState.FULL_SCREEN)
                        textfield.x=stage.stageWidth/2.5;
                    else
                        textfield.x=stage.stageWidth/2.55;
                    textfield.y=stage.stageHeight/2.3;
                    textfield.width=180;
                    backGround.addChild(textfield);
                    if(Config.SoundEnabled)
                        Victory.play();
                    if(!RecordSent)
                    {
                        var user:User=new User(this);
                        user.AddRecord(Number(tf.text),this.stage);
                        RecordSent=true;
                    }
                }
                else
                {   //проигрыш
                    GameState = "Lose";
                    var textfield:TextField = new TextField;
                    textfield.htmlText="<i>Вы проиграли!</i>";
                    textfield.x=stage.stageWidth/2.35;
                    textfield.y=stage.stageHeight/2.1;
                    textfield.width=140;
                    backGround.addChild(textfield);
                    /*var user:User=new User();
                    user.AddRecord(Number(tf.text));*/
                    if(!RecordSent)
                    {
                        var user:User=new User(this);
                        user.AddRecord(Number(tf.text)+10,this.stage);
                        RecordSent=true;
                    }
                }
            }
        }
    }
    function doEveryFrame(event:Event):void
    {
        //trace((System.freeMemory/1024).toString()+"/"+(System.totalMemory/1024).toString());

        if(GameState=="Game")
        {
            backGround.Update(event);
            tf.text=(timer.currentCount/100).toString();//вывод времени на экран
            var i:int = 0,count:int = traces.length;
            for(i = 0;i<count;i++)
            {
                var Object:MyTrace=traces[i];
                if(Object.TimeToLive <= 0)
                {
                    traces.splice(i, 1);
                    count--;
                    i--;
                }
                else
                {
                    Object.TimeToLive-=1;
                    Object.Draw();
                }
            }
            if(mode == 1)
            {
                moveObjects(new MouseEvent("type"));//выполнение движения объекта
            }
            i = 0;
            if(objectsToDelete.length>0)
            {
                trace(objectsToDelete);
                for(i=0;i<objectsToDelete.length;i++)
                {
                    var j:int=objects.indexOf(objectsToDelete[i]);
                    //trace("removed object:");//перебор на объекты для удаления
                    //trace(objectsToDelete[i]);

                    objects.splice(j, 1);
                    j = null;
                }
                ClearArray(objectsToDelete);
            }


            var userSize:Number = getUserSize();
            for each(var object:BaseObject in objects)
            {
                object.Move();
                var Size:Number = object.getSize();
                if(Size<userSize)
                {
                    object.DrawSimpleCircle();
                }
                else
                {
                    if(Size>userSize)
                    {
                        object.DrawEatingCircle();
                    }
                }
                object.Draw();
                CheckCollisions(object);


            }

        }
        if(GameState == "Pause")
        {
            backGround.Update(event);
            for each(var object:BaseObject in objects)
            {
                object.Draw();
            }
            backGround.graphics.beginFill(0x777777,0.2);
            backGround.graphics.drawRect(0,0,stage.width, stage.height);

        }
        if(GameState == "Win")
        {
            backGround.graphics.clear();
            backGround.graphics.beginFill(0xB099A2,0.2);
            backGround.graphics.drawRect(0,0,stage.width, stage.height);
            backGround.graphics.beginFill(0xBBBBBB,0.6);
            backGround.graphics.drawCircle(stage.stageWidth/2,stage.stageHeight/2,70);

            //backGround.graphics.drawEllipse(stage.stageWidth/2.2,stage.stageHeight/2.2,150,40);
        }
        if(GameState =="Lose")
        {
            backGround.graphics.clear();
            backGround.graphics.beginFill(0x8C0F41,0.2);
            backGround.graphics.drawRect(0,0,stage.width, stage.height);
            backGround.graphics.beginFill(0xBBBBBB,0.6);
            backGround.graphics.drawCircle(stage.stageWidth/2,stage.stageHeight/2,70);
        }
        if(GameState =="Menu")
        {
            DrawMenu();
        }

    }
    function CheckCollisions(object:BaseObject)
    {
        //перебор для определения совпадений
        for each(var lookingObject:BaseObject in objects)
        {
            if(lookingObject!=object&&!lookingObject.getToDestroy()&&!object.getToDestroy())
            {
                var dx:Number,dy:Number;
                dx=object.x-lookingObject.x;
                dy=object.y-lookingObject.y;
                var length:Number=Math.sqrt(dx*dx+dy*dy);
                if(length<(object.getSize()+lookingObject.getSize())/10)
                {
                    if(object.getType()==1||lookingObject.getType()==1&&Config.SoundEnabled)
                        Merging.play();
                    if(object.getSize()>lookingObject.getSize())
                    {
                        lookingObject.setSize(lookingObject.getSize()-Config.EatingRate);
                        if(lookingObject.getSize()<=Config.DeleteRate)
                        {
                            lookingObject.setToDestroy();
                            objectsToDelete.push(lookingObject);

                        }
                        object.setSize(object.getSize()+Config.EatingRate);
                    }
                    if(object.getSize()<lookingObject.getSize())
                    {
                        lookingObject.setSize(lookingObject.getSize()+Config.EatingRate);
                        object.setSize(object.getSize()-Config.EatingRate);
                        if(object.getSize()<=Config.DeleteRate)
                        {
                            object.setToDestroy();
                            objectsToDelete.push(object);

                        }
                    }
                }
                if(length<(object.getSize()+lookingObject.getSize())/10*2)
                {
                    /*backGround.graphics.beginFill(0xEDF562);
                    backGround.graphics.lineStyle(1,0xEDF562,0.75);
                    backGround.graphics.moveTo(object.x,object.y);
                    backGround.graphics.lineTo(lookingObject.x, lookingObject.y);*/
                }
                dx = null;
                dy = null;
                length = null;
            }
        }
    }
    function moveObjects(event:MouseEvent):void
    {
        if(mode ==1)
        {
            var angle:Number=0;
            var x:Number=this.mouseX;
            var y:Number=this.mouseY;
            for each(var object:BaseObject in objects)
            {
                if(object.getType()==1)
                {
                    angle=FindVector(object.x, object.y, x,y);
                    var dx:Number, dy:Number;
                    dx = -Math.cos(angle)*(Config.UserSpeed);
                    dy = -Math.sin(angle)*(Config.UserSpeed);
                    object.VelocityX=dx;
                    object.VelocityY=dy;
                }
            }
            angle = null;
        }
    }
    function radianToDegrees(radians:Number):Number
    {
        return radians*180/Math.PI;
    }
    function degreesToRadians(degrees:Number):Number
    {
        return degrees*Math.PI/180;
    }
    function FindVector(x0:Number,y0:Number,x1:Number,y1:Number):Number
    {
        return Math.atan2(y1-y0, x1-x0);
    }
    function activate(event:Event):void
    {
        if(GameState=="Pause")
            GameState = "Game";
        stage.frameRate=30;
        //mode=0;
    }
    function deactivate(event:Event):void
    {
        if(GameState=="Game")
            GameState = "Pause";
        stage.frameRate = 1;
        //mode=1;
    }


    function DrawMenu():void
    {
        menu.Draw(backGround.graphics);
    }
    public function getUserSize():int
    {
        var userSize:int=0;
        for each(var object:BaseObject in objects)
        {
            if(object.getType()==1)
            {
                userSize = object.getSize();
                return userSize;
            }
        }
        return userSize;
    }
}
}
