/**
 * Created with NumberelliJ IDEA.
 * User: igorp
 * Date: 15.03.13
 * Time: 13:25
 * To change this template use File | Settings | File Templates.
 */
package rotator {
import flash.display.Graphics;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.security.X500DistinguishedName;

public class BaseObject extends Sprite {

    /**
     * Размер
     */
    private var Size:Number=40;
    /**
     * Цвет
     */
    private var Color:Number=0;
    /**
     * Тип объекта
     */
    protected var type:Number = 0;
    /**
     * Ускорение по X
     */
    public var VelocityX:Number = 0;
    /**
     * Ускорение по Y
     */
    public var VelocityY:Number = 0;
    /**
     * Максимальная скорость
     */
    protected var MaxSpeed:Number = 5;
    /**
     * Необходимо ли удалять объект
     */
    private var ToDestroy:Boolean = false;
    /**
     * Ссылка на главный класс
     */
    public var test:Test;
    /**
     * предыдущее значение x
     */
    protected var prevDx:Number = 0;
    /**
     * предыдущее значение y
     */
    protected var prevDy:Number = 0;

    /**
     * getter
     * @return
     */
    public function getToDestroy():Boolean
    {
        return ToDestroy;
    }

    /**
     * setter
     */
    public function setToDestroy():void
    {
        ToDestroy=true;
    }

    /**
     * getter
     * @return
     */
    public function getX():Number
    {
        return this.x;
    }

    /**
     * getter
     * @return
     */
    public function getY():Number
    {
        return this.y;
    }

    /**
     * getter
     * @return
     */
    public function getType():Number
    {
        return this.type;
    }

    /**
     * get the size of the object. Notice, that it varies in ten times of real pixel size.
     * @return
     */
    public function getSize():Number
    {
        return Size;
    }

    /**
     * установка размера объекта. Учесть, что разница реального размера и задаваемого - 10 раз.
     * @param size
     */
    public function setSize(size:Number):void
    {
        Config.checkMaxSize(size);
        this.Size = size;
    }

    public function BaseObject(X:Number, Y:Number) {
        this.x = X;
        this.y = Y;
    }

    public virtual function Draw():void
    {

    }

    /**
     * Отрисовать серый круг. Обозначенные серым кружком объекты можно есть.
     */
    public virtual function DrawSimpleCircle():void
    {
        test.backGround.graphics.beginFill(0xEEEEEE,0.8);
        test.backGround.graphics.drawCircle(this.x, this.y, this.getSize()/10+1);
    }

    /**
     * Отрисовать красный круг. Обозначенные им объекты являются опасными.
     */
    public virtual function DrawEatingCircle():void
    {
        //test.backGround.graphics.beginFill(0x00DD00,1.0);
        test.backGround.graphics.beginFill(0xDD0000,0.6);
        test.backGround.graphics.drawCircle(this.x, this.y, this.getSize()/10+1);
    }

    /**
     * Передвинуть объект
     */
    public virtual function Move():void
    {
        /**
         * мера убывания скорости
         */
        var DegradationRate:Number = Config.DegradationRate;
        var dx:Number=VelocityX,dy:Number=VelocityY;
        /**
         * Проверка на минимальное значение скорости, ниже которого она зануляется
         */
        if(Math.abs(VelocityX)>0.01)
        {
            /**
             * Перемещение
             */
            this.x+=dx;
            /**
             * Рикошет от стенок
             */
            if(this.x+dx-this.getSize()/10<0)
            {
                this.x=this.getSize()/10;
                this.VelocityX=-this.VelocityX;
            }
            if(this.x+dx+this.getSize()/10>Config.windowWidth)
            {
                this.x = Config.windowWidth-this.getSize()/10;
                this.VelocityX=-this.VelocityX;
            }
            this.VelocityX*=DegradationRate;
        }
        else
        {

            this.VelocityX=0.0;
        }
        /**
         * Проверка на минимальное значение скорости, ниже которого она зануляется
         */
        if(Math.abs(VelocityY)>0.01)
        {
            /**
             * Перемещение
             */
            this.y+=dy;
            /**
             * Рикошет
             */
            if(this.y+dy-this.getSize()/10<0)
            {
                this.y=this.getSize()/10;
                this.VelocityY=-this.VelocityY;
            }
            if(this.y+dy+this.getSize()/10>Config.windowHeight)
            {
                this.y = Config.windowHeight-this.getSize()/10;
                this.VelocityY=-this.VelocityY;
            }
            this.VelocityY*=DegradationRate;
        }
        else
        {
            this.VelocityY=0.0;
        }
        this.prevDx=dx;
        this.prevDy=dy;
    }
    public function AddVelocity(X:Number, Y:Number):void
    {
        if(Math.abs(this.VelocityX+X)<Config.MaxVelocity)
            this.VelocityX+=X;
        else
            this.VelocityX=Config.MaxVelocity*Math.abs(VelocityX)/VelocityX;
        if(Math.abs(this.VelocityY+Y)<Config.MaxVelocity)
            this.VelocityY+=Y;
        else
            this.VelocityY=Config.MaxVelocity*Math.abs(VelocityY)/VelocityY;
    }
}
}
