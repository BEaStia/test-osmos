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
import rotator.User;
import rotator.UserObject;

[SWF(backgroundColor="0xec9900")]
public class Test extends Sprite {

    /**
     * Массив объектов для удаления
     */
    private var objectsToDelete:Array;

    /**
     * Текстовое поле для вывода таймера
     */
    public var tf:TextField;
    /**
     * Объекты на экране
     */
    private var objects:Array;
    /**
     * Фон, на котором все отрисовывается
     */
    public var backGround:BackGround;
    /**
     * Состояние игры. Имеет вид "Menu","Game","Win","Lose","Pause"
     */
    private var GameState:String = "Menu";
    /**
     * Меню(кнопки, таблица игроков)
     */
    private var menu:Menu;
    /**
     * Нажатость клавиши пользователем
     */
    private var mode:Boolean=false;
    /**
     * таймер
     */
    private var timer:Timer;
    /**
     * Следы за объектами
     */
    public var traces:Array;
    /**
     * Загружены ли цвета
     */
    public var LoadedColors:Boolean=false;
    /**
     * Загружено ли число врагов
     */
    public var LoadedEnemiesCount:Boolean=false;
    /**
     * Звук разделения
     */
    public var Merging:Sound;
    /**
     * Звук победы
     */
    public var Victory:Sound;
    /**
     * Отправлен ли рекорд
     */
    public var RecordSent:Boolean=false;

    /**
     *  количество объектов по дефолту
     */
    private var objectsMaxCount:Number=60;

    /**
     * Функция вызывается при старте/рестарте игры
     */
    public function Load():void
    {
        /**
         * Удаление всех объектов на фоне
         */
        this.backGround.removeAllChildren();
        /**
         * И соответственно их генерация
         */
        Config.GenerateEnemies(objectsMaxCount);
        /**
         * Таймер на 10 мс
         */
        timer=new Timer(10);
        timer.start();
        /**
         * Запуск игры
         */
        GameState = "Game";

        stage.align="left";
        objects = new Array();
        objectsToDelete=new Array();

        /**
         * Размещение объектов
         */
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

        /**
         * Добавление текстового поля для таймера
         */
        tf=new TextField();
        tf.text = "0";
        tf.x = Config.windowWidth/2;
        tf.y = 0;
        this.backGround.addChild(tf);

        RecordSent=false;

    }

    /**
     * Вызывается в самом начале приложения
     * @param e
     */
    private function _loading(e:Event):void
    {
        //Сюда можно поместить лого для загрузки
    }
    public function onError(e:ErrorEvent):void
    {
        trace(e);
    }

    /**
     * Вызывается по окончанию загрузки всех объектов
     */
    public function Start():void//вызывается по окончанию загрузки файлов
    {
        this.removeEventListener(Event.ENTER_FRAME,_loading);
        removeChildren();
        //создание новой конфигурации
        var config:Config;
        Config.windowWidth=stage.stageWidth;
        Config.windowHeight=stage.stageHeight;
        if(Config.configText=="")
            config = new Config("",objectsMaxCount);
        else
            config = new Config(Config.configText,objectsMaxCount);
        //Добавление фона
        backGround=new BackGround();
        Config.SetStage(this.stage);
        backGround.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
        backGround.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
        addEventListener(MouseEvent.MOUSE_MOVE,moveObjects);
        addEventListener(Event.ACTIVATE,activate);
        addEventListener(Event.DEACTIVATE,deactivate);
        addEventListener(Event.ENTER_FRAME,checkEnd);
        stage.addEventListener(KeyboardEvent.KEY_DOWN,CheckKeyboard);
        addChild(backGround);

        //Создание и добавление меню
        this.menu=new rotator.Menu(this);
        menu.createRecords();
        this.addChild(menu);
        Load();//Загрузка уровня
        addEventListener(Event.ENTER_FRAME, doEveryFrame);
        stage.align = StageAlign.TOP;

    }
    public function Test() {
        /**
         * Добавление политики
         */
        Security.loadPolicyFile("http://test-project.16mb.com/crossdomain.xml");
        /**
         * Загрузка цветов
         */
        loadColors("http://test-project.16mb.com/config.conf");
        /**
         * Загрузка числа врагов
         */
        loadEnemiesCount("http://test-project.16mb.com/enemiesCount.txt");
        /**
         * Загрузка таблицы рекордов
         */
        LoadList();
        /**
         * Вывод сообщения об ожидании
         */
        var tA:TextField=new TextField();
        tA.text="Loading! \r\n Please wait!";
        tA.x = stage.stageWidth*0.4;
        tA.y = stage.stageHeight*0.45;
        this.addChild(tA);
        /**
         * Загрузка звуков
         */
        var req:URLRequest = new URLRequest("http://test-project.16mb.com/wind.mp3");
        Merging = new Sound(req);
        req = new URLRequest("http://test-project.16mb.com/triangle.mp3");
        Victory = new Sound(req);

        stage.frameRate = 30;
        var _loader:URLLoader;
        var _request:URLRequest;
        this.addEventListener(Event.ENTER_FRAME,_loading);

        /**
         * Загрузка цветов с адреса
         * @param url
         */
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

        /**
         * Действие по завершению загрузки цветов
         * @param e
         */
        function onLoadColors(e:Event):void
        {
            Config.configText= e.target.data;
            LoadedColors=true;
            /**
             * Игра начинается только по окончанию всех загрузок
             */
            if(LoadedEnemiesCount&&Menu.Loaded)
                Start();
        }

        function onDataFailedToLoad(e:Event):void
        {
            trace("error in loading from server");
        }

        /**
         * Загрузка количества врагов
         * @param url
         */
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

        /**
         * Действие по загрузке количества врагов
         * @param e
         */
        function onLoadEnemiesCount(e:Event):void
        {
            this.objectsMaxCount= parseInt(e.target.data);
            LoadedEnemiesCount=true;

            /**
             * Игра начинается только по окончанию всех загрузок
             */
            if(LoadedColors&&Menu.Loaded)
                Start();
        }

        /**
         * Загрузка таблицы рекордов
         */
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

        /**
         * Действие по окончанию загрузки этой таблицы
         * @param e
         */
        function onLoadList(e:Event):void
        {
            Menu.currentPosition = 0;
            Menu.recordArray =  new Array(JSON.parse(e.target.data))[0];
            Menu.Loaded = true;
            /**
             * Игра начинается только по окончанию всех загрузок
             */
            if(LoadedColors&&LoadedEnemiesCount)
                Start();
        }
    }

    /**
     * Событие по нажатию кнопки мыши
     * @param event
     */
    public function onMouseDown(event:MouseEvent):void
    {
        this.mode = true;
    }

    /**
     * Событие по отпусканию кнопки мыши
     * @param event
     */
    public function onMouseUp(event:MouseEvent):void
    {
        this.mode = false;
    }

    /**
     * Поставить игру на паузу
     */
    public function Pause():void
    {
        if(this.GameState=="Pause")
        {
            GameState="Game";
            timer.start();
        }
        else
        {
            if(GameState=="Game")
            {
                GameState="Pause";
                timer.stop();
            }
        }
    }

    /**
     * Очистка массива
     * @param array
     */
    internal function ClearArray(array:Array):void
    {
        while(array.length>0)
            array.pop();
    }

    /**
     * Вызов меню по нажатию кнопки
     */
    public function callMenu():void //вызов меню
    {
        if(GameState =="Menu")
        {
            menu.ListVisible=false;
            GameState = "Game";
            timer.start();
        }
        else
        {
            if(GameState =="Game")
            {
                menu.ListVisible=true;
                GameState = "Menu";
                timer.stop();
            }
        }
    }

    /**
     * Просмотр нажатий на клавиатуру
     * @param event
     */
    internal function CheckKeyboard(event:KeyboardEvent):void
    {
        if(event.keyCode==48)
        {
            doFullScreen();
        }
        if(event.keyCode==49)
        {
            callMenu();
        }
        if(event.keyCode==50)
        {
            Pause();
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
    }

    /**
     * Применить полноэкранный режим
     */
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

    /**
     * Проверка на окончание игрового цикла
     * @param event
     */
    internal function checkEnd(event:Event):void
    {
        if(GameState =="Game")
        {
            var end:Boolean=false,win:Boolean = false;
            var Size:Number = 0;
            var HasUser:Boolean=false;
            var Object:BaseObject;
            for each(Object in objects)
            {
                Size+=Object.getSize();//возьмем величину всех остальных
                if(Object.getType()==1)
                {
                    HasUser=true; //поиск юзера в массиве объектов
                }
            }
            if(!HasUser)
            {
                end = true;
                win = false;
            }
            else
            {//если юзер есть, проверяем на победу
                for each(Object in objects)
                {
                    if(Size-Object.getSize()<=Object.getSize())//и если какой-нибудь объект по размерам больше или равен всем остальным вместе взятым, то он выигрывает
                    {
                        end=true;
                        timer.stop();
                        win = Object.getType() == 1;
                    }
                }
            }
            if(end)//наступил ли конец
            {
                var textfield:TextField = new TextField();
                if(win)
                {   //победа
                    GameState ="Win";

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
                    textfield.htmlText="<i>Вы проиграли!</i>";
                    textfield.x=stage.stageWidth/2.35;
                    textfield.y=stage.stageHeight/2.1;
                    textfield.width=140;
                    backGround.addChild(textfield);
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

    /**
     * Основная функция, выполняющая для каждого кадра
     * @param event - событие
     */
    internal function doEveryFrame(event:Event):void
    {
        //trace((System.freeMemory/1024).toString()+"/"+(System.totalMemory/1024).toString());
        switch (GameState)
        {
            case "Game":
                backGround.Update(event);//отрисовка фона
                tf.text=(timer.currentCount/100).toString();//вывод времени на экран
                //Отрисовка хвостов объектов
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
                //перемещение объекта
                if(mode)
                {
                    moveObjects(new MouseEvent("type"));//выполнение движения объекта
                }
                //удаление объектов в массиве для удаления
                i = 0;
                if(objectsToDelete.length>0)
                {
                    trace(objectsToDelete);
                    for(i=0;i<objectsToDelete.length;i++)
                    {
                        var j:int=objects.indexOf(objectsToDelete[i]);
                        objects.splice(j, 1);
                        j = null;
                    }
                    ClearArray(objectsToDelete);
                }

                //Отрисовка всех объектов и их перемещение
                var userSize:Number = getUserSize();
                for each(var object:BaseObject in objects)
                {
                    object.Move();
                    //кружки вокруг объекта не нужны пользовательскому объекту
                    if(!(object is UserObject))
                    {
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
                    }
                    object.Draw();
                    //проверка на пересечения
                    CheckCollisions(object);
                }
                break;
            //если игровое состояние - пауза
            case "Pause":
                backGround.Update(event);
                for each(var object:BaseObject in objects)
                {
                    object.Draw();
                }
                backGround.graphics.beginFill(0x777777,0.2);
                backGround.graphics.drawRect(0,0,stage.width, stage.height);
                break;
            //если игровое состояние - победа
            case "Win":
                backGround.graphics.clear();
                backGround.graphics.beginFill(0xB099A2,0.2);
                backGround.graphics.drawRect(0,0,stage.width, stage.height);
                backGround.graphics.beginFill(0xBBBBBB,0.6);
                backGround.graphics.drawCircle(stage.stageWidth/2,stage.stageHeight/2,70);
                break;
            //если игровое состояние - проигрыш
            case "Lose":
                backGround.graphics.clear();
                backGround.graphics.beginFill(0x8C0F41,0.2);
                backGround.graphics.drawRect(0,0,stage.width, stage.height);
                backGround.graphics.beginFill(0xBBBBBB,0.6);
                backGround.graphics.drawCircle(stage.stageWidth/2,stage.stageHeight/2,70);
                break;
            //если игровое состояние - меню
            case "Menu":
                DrawMenu();
                break;
        }
    }

    /**
     * Проверить пересечения одного объекта с другими
 * @param object
     */
    internal function CheckCollisions(object:BaseObject):void
    {
        //перебор для определения совпадений
        for each(var lookingObject:BaseObject in objects)
        {
            /**
             * Для каждого объекта мы делаем полный перебор относительно других объектов
             * И если искомый объект
             */
            if(lookingObject!=object&&!lookingObject.getToDestroy()&&!object.getToDestroy())
            {
                /**
                 * Находим разность координат
                 */
                var dx:Number,dy:Number;
                dx=object.x-lookingObject.x;
                dy=object.y-lookingObject.y;

                /**
                 * Находим расстояние между объектами
                 */
                var length:Number=Math.sqrt(dx*dx+dy*dy);
                /**
                 * Так как мы имеем дело с кругами, то соотственно достаточно проверять условие,
                 * что расстояние меньше суммы радиусов.
                 */
                if(length<(object.getSize()+lookingObject.getSize())/10)
                {
                    /**
                     * Воспроизведение аудиокомпонента при пересечении с объектом игрока
                     */
                    if(object.getType()==1||lookingObject.getType()==1&&Config.SoundEnabled)
                        Merging.play();
                    /**
                     * Определение поедаемого компонента и, собственно, само его поедание
                     */
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
                /**
                 * Обнуление переменных. В каком-то гайде увидел, что так следует делать...
                 */
                dx = null;
                dy = null;
                length = null;
            }
            /**
             * Если необходимо уничтожить объект, то зачем лишний раз гонять его по циклу?
             * Соответственно, обрываем цикл
             */
            if(object.getToDestroy())
                break;

        }
    }
    internal function moveObjects(event:MouseEvent):void
    {
        /**
         * Дополнительная проверка на тот факт, что пользователь нажал на мышь
         */
        if(mode)
        {
            var angle:Number=0;
            var x:Number=this.mouseX;
            var y:Number=this.mouseY;
            /**
             * Ищем и перемещаем объект пользователя
             */
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

    /**
     * Преобразование радиан в градусы
     * @param radians - угол в радианах
     * @return - угол в градусах
     */
    internal function radianToDegrees(radians:Number):Number
    {
        return radians*180/Math.PI;
    }

    /**
     *Преобразование градусов в радианы
     * @param degrees - угол в градусах
     * @return угол в радианах
     */
    internal function degreesToRadians(degrees:Number):Number
    {
        return degrees*Math.PI/180;
    }

    /**
     * Нахождение угла по вектору
     * @param x0 - x начала
     * @param y0 - y начала
     * @param x1 - x конца
     * @param y1 - y конца
     * @return - угол в радианах
     */
    internal function FindVector(x0:Number,y0:Number,x1:Number,y1:Number):Number
    {
        return Math.atan2(y1-y0, x1-x0);
    }

    /**
     * Активация окна, когда пользователь снова выбирает его
     * @param event
     */
    internal function activate(event:Event):void
    {
        if(GameState=="Pause")
            GameState = "Game";
        stage.frameRate=30;
    }

    /**
     * Деактивация окна, когда пользователь выбирает что-то отличное от данного приложения для улучшенной производительности
     * @param event
     */
    internal function deactivate(event:Event):void
    {
        if(GameState=="Game")
            GameState = "Pause";
        stage.frameRate = 1;
    }

    /**
     * Отрисовка меню на фоновый слой
     */
    internal function DrawMenu():void
    {
        menu.Draw(backGround.graphics);
    }

    /**
     * Получение размера пользовательского объекта
     * @return Размер пользовательского шарика
     */
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
