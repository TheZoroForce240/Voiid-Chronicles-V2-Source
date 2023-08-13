package;

import flixel.FlxObject;
import states.VoiidAwardsState.AwardManager;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.display.FPS;
import flixel.FlxG;
import lime.app.Application;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
import states.VoiidAwardsState.Award;

class Popup extends Sprite
{
    var timeElapsed:Float = 0;
    var time:Float = 0;
    public var alive:Bool = true;
    public var shouldKill:Bool = false;

    public var popupY:Float = 0;
    public var popupHeight:Float = 120;
    public var popupWidth:Float = 300;

    var bg:Bitmap;

    function getScreenWidth()
    {
        return Lib.application.window.width;
    }

    public function new(time:Float, w:Int = 300, h:Int = 120)
    {
        super();
        this.time = time;
        popupWidth = w;
        popupHeight = h;
        popupY = -popupHeight;

        bg = new Bitmap(new BitmapData(w, h, true, 0xFF000000));
        addChild(bg);
        bg.x = getScreenWidth()-popupWidth;
    }
	public function update(deltaTime:Float)
	{
        timeElapsed += deltaTime;
        bg.y = popupY;
        if (timeElapsed >= time)
            alive = false;

        shouldKill = (timeElapsed >= time+1);
    }
}

class MessagePopup extends Popup
{
    var text:TextField;
    override public function new(time:Float, w:Int = 300, h:Int = 120, m:String = "", size:Int = 16)
    {
        super(time, w, h);
        text = new TextField();
        text.text = m;
        text.defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont(Paths.font("Contb___.ttf")).fontName,
        size, 0xFFFFFF, null, null, null, null, null, LEFT);
        addChild(text);
        text.border = true;
        text.borderColor = 0xFFFFFF;
        text.width = w-10;
        text.height = h-10;
        text.selectable = false;
        text.wordWrap = true;

        text.x = getScreenWidth()-w+5;
    }
    override public function update(deltaTime:Float)
    {
        super.update(deltaTime);
        text.y = popupY+5;
    }
}
class ClickableMessagePopup extends Popup
{
    var text:TextField;
    var clickFunc:Void->Void = null;
    var hitbox:FlxObject;
    override public function new(time:Float, w:Int = 300, h:Int = 120, m:String = "", size:Int = 16, clickFunc:Void->Void)
    {
        super(time, w, h);
        this.clickFunc = clickFunc;
        text = new TextField();
        text.text = m;
        text.defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont(Paths.font("Contb___.ttf")).fontName,
        size, 0xFFFFFF, null, null, null, null, null, LEFT);
        addChild(text);
        text.border = true;
        text.borderColor = 0xFFFFFF;
        text.width = w-10;
        text.height = h-10;
        text.selectable = false;
        text.wordWrap = true;
        text.x = getScreenWidth()-w+5;

        hitbox = new FlxObject(0,0,w,h);
        
    }
    override public function update(deltaTime:Float)
    {
        super.update(deltaTime);
        text.y = popupY+5;
        hitbox.x = bg.x;
        hitbox.y = bg.y;

       
        if (alive && FlxG.mouse.justPressed && hitbox.overlapsPoint(FlxG.mouse.getScreenPosition()))
        {
            alive = false;
            if (clickFunc != null)
                clickFunc();
        }
    }
}
class AwardPopup extends Popup
{
    var text:TextField;
    var text2:TextField;
    var image:Bitmap;
    override public function new(time:Float, w:Int = 300, h:Int = 120, award:Award)
    {
        if (award == null)
        {
            award = {name: "Null Award lol", desc: "", saveData: "", gjTrophyID: -1};
        }
        super(time, w, h);
        text = new TextField();
        text.text = award.name;
        text.defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont(Paths.font("Contb___.ttf")).fontName,
        32, 0xFFFFFF, null, null, null, null, null, LEFT);
        addChild(text);
        text.border = true;
        text.borderColor = 0xFFFFFF;
        text.width = w-10;
        text.height = h-10;
        text.selectable = false;
        text.wordWrap = true;

        text2 = new TextField();
        text2.text = award.desc;
        text2.defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont(Paths.font("Contb___.ttf")).fontName,
        16, 0xFFFFFF, null, null, null, null, null, LEFT);
        addChild(text2);
        text2.width = w-100;
        text2.height = h-50;
        text2.selectable = false;
        text2.wordWrap = true;


        var imagePath = Paths.image("awards/"+AwardManager.getAwardImageName(award));
        if(!lime.utils.Assets.exists(imagePath))
            imagePath = Paths.image("awards/default");

        var spriteImage:FlxSprite = new FlxSprite(0,0).loadGraphic(imagePath);
        spriteImage.setGraphicSize(100, 100);
        spriteImage.updateHitbox();
        image = new Bitmap(spriteImage.updateFramePixels()); //easy flixel to openfl shit
        addChild(image);
        image.smoothing = true;
        image.scaleX = spriteImage.scale.x;
        image.scaleY = spriteImage.scale.y;
        

        



        text.x = getScreenWidth()-w+5;
        text2.x = getScreenWidth()-w+5;
        image.x = getScreenWidth()-105;
    }
    override public function update(deltaTime:Float)
    {
        super.update(deltaTime);
        text.y = popupY+5;
        text2.y = popupY+5+40;
        image.y = popupY+10;
    }
}

class PopupManager extends Sprite
{
    var popups:Array<Popup> = [];
    @:noCompletion private var currentTime:Float;
    public function new()
    {
        super();
        currentTime = 0;
        FlxG.signals.postUpdate.add(function()
        {
            update(FlxG.elapsed);
        });
        FlxG.signals.postStateSwitch.add(function()
        {
            for (p in popups)
            {
                FlxG.addChildBelowMouse(p); //fix for switching state
            }
        });
    }
	function update(elapsed:Float):Void
	{
        if (popups.length > 0)
        {
            var currentPopupHeight:Float = 0;
            for (p in 0...popups.length)
            {
                var popup:Popup = popups[p];
                var popupPos:Float = 0-popup.popupHeight; //default to offscreen
                if (popup.alive)
                {
                    popupPos = currentPopupHeight; //target y position
                    currentPopupHeight += popup.popupHeight;
                }
                popup.popupY = FlxMath.lerp(popup.popupY, popupPos, elapsed*6); //get y pos

                popup.update(elapsed);
            }

            for (popup in popups)
            {
                if (popup.shouldKill)
                {
                    removeChild(popup);
                    popups.remove(popup);
                }
            }
        }
    }

    public function addPopup(p:Popup)
    {
        FlxG.addChildBelowMouse(p);
        popups.push(p);
    }

}