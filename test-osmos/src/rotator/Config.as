/**
 * Created with IntelliJ IDEA.
 * User: root
 * Date: 16.03.13
 * Time: 15:53
 * To change this template use File | Settings | File Templates.
 */
package rotator {


import com.developmentarc.core.datastructures.utils.HashTable;


import flash.display.Stage;

import vk.api.serialization.json.JSON;

public class Config {
        //Текст для конфигурации
        public static var configText:String ="";
        //Данные цветов
        public static var data:HashTable;
        //Максимальный размер
        public static var MaxSize:int=0;
        //Размеры пользовательского окна
        public static var windowHeight:int = 0;
        public static var windowWidth:int = 0;
        //Стартовые позиции объектов
        public static var Positions:Array;
        //Количество противников
        public static var NumberOfEnemies:int=0;
        //Порог размера, меньше которого объекты удаляются
        public static var DeleteRate:int = 10;
        //Скорость поедания
        public static var EatingRate:int = 2;
        //Штраф к скорости (от 0 до 1). Чем меньше - тем сильнее уменьшается скорость
        public static var DegradationRate:Number = 0.99;
        //ссылка на stage Главного класса
        public static var stage:Stage;
        //Скорость перемещения пользователя
        public static var UserSpeed:Number = 1.2;
        //Максимальное ускорение пользователя(deprecated)
        public static var MaxVelocity:Number = 1.2;
        //Включен ли звук
        public static var SoundEnabled:Boolean=true;

        //setter для stage
        public static function SetStage(_stage:Stage):void
        {
            stage = _stage;
        }

        //При отстутствии подключения к внешнему серверу, самостоятельно сгенерировать цвета
        public static function GenerateColorConfig():void
        {
            /*configText='{"user": {"color": [102, 88, 110]}, "enemy": {';
            var j:int, i:int;
            j = 0;
            i = 0;
            for(i=27;i<220;i++)
            {
                j++;
                configText+='"color'+j.toString()+'" :['+ i.toString()+", 27,244],";
            }
            configText=configText.substr(0,configText.length-1);
            configText+='}}';*/
            configText="";
        }
        //Задать позиции обхектов
        public static function GenerateEnemies(number:int):void
        {
            NumberOfEnemies=number;
            Positions=[];
            for(var i:int=0;i<NumberOfEnemies;i++)
            {
                var arr:HashTable=new HashTable();
                var X:Number = Math.round(Math.random()*Config.windowWidth);
                var Y:Number = Math.round(Math.random()*Config.windowHeight);
                var R:Number = Math.round(Math.random()*100)+10;
                while(!positionSuits(X, Y, R))
                {
                    X = Math.round(Math.random()*Config.windowWidth);
                    Y = Math.round(Math.random()*Config.windowHeight);
                    R = Math.round(Math.random()*100)+10;
                }
                arr.addItem("X",X);
                arr.addItem("Y",Y);
                arr.addItem("R",R);

                Positions.push(arr);
            }

        }
        //Подходит ли позиция для постановки объекта радиусом R в координаты X,Y
        private static function positionSuits(X:Number, Y:Number, R:Number):Boolean
        {
            var flag:Boolean=true;
            for(var i:int=0;i<Positions.length;i++)
            {
                if(!suits(Positions[i].getItem("X")-X, Positions[i].getItem("Y")-Y, Positions[i].getItem("R")+R))
                {
                    flag = false;
                    break;
                }
            }
            return flag;
        }
        //проверка коллизии объектов при генерации
        private static function suits(dx:Number, dy:Number, R:Number):Boolean
        {
            return Math.sqrt(dx * dx + dy * dy) - R > 0;
        }

        //конструктор
        public function Config(config:String,numberOfEnemies:int) {
            //Если не обнаружен конфиг, то сами создаем его
            if(config=="")
                GenerateColorConfig();
            GenerateEnemies(numberOfEnemies);

            var conf:Object = vk.api.serialization.json.JSON.decode(configText);
            data = new HashTable();
            data.addItem("user",conf.user);
            data.addItem("enemy",conf.enemy);
        }
        public static function getEnemyColorsCount():int
        {

            var obj:Object=data.getItem("enemy");
            var colorsCount:int=0;
            for(var prop in obj)
            {
                colorsCount++;
            }
            return colorsCount;
        }
        public static function getEnemyColor(user:int, enemy:int):int
        {
            var obj:Object=data.getItem("enemy");
            var colorsCount:int=getEnemyColorsCount();

            var colorNumber:int = Math.round(colorsCount*enemy/getMaxSize());
            colorNumber=Math.round(colorsCount/2+user-enemy);
            if(colorNumber<=0)
                colorNumber=1;
            if(colorNumber>=colorsCount)
                colorNumber=colorsCount-1;
            return ConvertArrayToInt(obj["color"+colorNumber.toString()]);
        }
        public static function getUserColor():int
        {
            var User:Object = data.getItem("user");
            var colorArray:Array=User.color;
            return ConvertArrayToInt(colorArray);
        }
        public static function ConvertArrayToInt(array:Array):int
        {
            var colorR:int = array[0]<<16;
            var colorG:int = array[1]<<8;
            var colorB:int = array[2];
            var colorInt:int = colorR+colorG+colorB;
            return colorInt;
        }
        public static function getMaxSize():int
        {
            return MaxSize;
        }
        public static function setMaxSize(newSize:int):void
        {
            MaxSize=newSize;
        }
        public static function checkMaxSize(checkSize:int):void
        {
            if(getMaxSize()<checkSize)
            {
                setMaxSize(checkSize);
            }

        }


    }
}
