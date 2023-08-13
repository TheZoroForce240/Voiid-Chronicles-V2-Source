package;
import flixel.FlxCamera;
import ui.Alphabet;
import ui.Option;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxObject;
import states.PlayState;
import flixel.math.FlxPoint;
import flixel.input.touch.FlxTouch;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&######*,,,,,,,,*#%#####(#/&&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#/&&#/*,,,,,,,,,,,,,,,,,,,......,,,(&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&**,*,,**,,,,,,,*,,***,,..,..,,,,,.......,*&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&/*,,,*****,/(#(**,,,*/**/%&&%/.....,,,.......,,%&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&*,,,,*****,#&@&&&*...***,%@@@&(,... ..,,........,&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&(*,,,,,*,*****,,,,,,,,,.*//**,*,*,,,,,,,...........&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&**,,,,,,***//////*,,,,,.....,***/***,..............&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&***,,,,,,,,,,,,,,,,,.............................,,&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&/********//*,,,,,,,,,,.............,,,,,****,,,,,,*&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&/(&@&%%%%%%&%**,,,,,,,,,,,.............,,,,,,******&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&/#&@@&&%###%%(/////////////////*******,,,,,,******&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&#(%%%%##(/(%((///////////////*****************//&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%%&((#(/((#%%/////////////*************///(%&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#&&%%%###%%%%(///////////////////////((&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%&&&%%%%%%%%%#((((((((((((((((((%&&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%%%%%%%%%%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%%%%%%%&&&&&%#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&&&&(*#&&&&&&&&&&&&&&&&&&&&%&&&&&&&&&%%%%%%&&&%%%&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&&*,,,,,**&&&&&&&&&&&&&&&&%&&&&&%%%%%%%%%%%%%%%%&%&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&*,,..,,,&&&&&&&&&&&&&&&&&&&&&&&&&&%%%%%%%%%%%&%&&%&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&...,**&&&&&&&&&&&&&&&&&&&#&@@@@@@&&&&%%%%%%%%%%%&&&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&..,.(&&&&&&&&&&&&&&&&&&&&&&&@@&&&&%%%%%%%%%###%%##&&&&&&&&&&&&&&&&&&&&&&&&
//&&&&&&*,,/&&&&&&&&&&&&&&&&&&&&&&&&&@&@&&%%%%%%%%#(///(##%%&%&&&&&&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%%&&&@&&&&%%#((#%(/##%##%%%(..,*&&&&&&&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&%%&&&&&&&&&&%&&%#&#(%#(%%#%%#%%##%%#......,,%&&&&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&#%%%%%%&@&((#&&&%#%&#(%&(%%#(/(#%&&&&#*,,.,,,,,,,&&&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&(######&#///*#&&@&&&&%#(**,,,,,,****/((%(*****,,,,,&&&&
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
class MobileControls extends FlxTypedSpriteGroup<FlxSprite>
{
    var buttons:Array<FlxSprite> = [];
    public var justPressed:Array<Bool> = [];
    public var justReleased:Array<Bool> = [];
    public var pressed:Array<Bool> = [];
    public var released:Array<Bool> = [];
    public var keyCount:Int = 4;
    public var hasDodges:Bool = false;
    public function new()
    {
        super();
    }

    public function getDodgeJustPressed()
    {
        return justPressed[Math.floor(keyCount/2)];
    }

    public function generateButtons(kc:Int = 4, dodges:Bool = false)
    {
        keyCount = kc;

        trace(dodges);

        if (keyCount % 2 == 1)
            dodges = false; //odd keycount, just use the center as the dodge one

        this.hasDodges = dodges;

        for (b in buttons)
        {
            remove(b);
        }
        buttons = [];

        keyCount += (hasDodges ? 1 : 0);

        var w:Int = Math.floor(FlxG.width/ keyCount);
        var colors:Array<FlxColor> = [0xFFf0925c, 0xFFd7143b, 0xFF771eb4, 0xFF4b9b8c];
        for (i in 0...keyCount)
        {
            var color:FlxColor = colors[i%4];
            var box:FlxSprite = new FlxSprite(i*w, 0).makeGraphic(w, 720, color);
            box.alpha = 0.4;
            add(box);
            buttons.push(box);
        }

        /*if (hasDodges)
        {
            
            for (i in 0...buttons.length)
            {
                if (i > Math.floor(keyCount/2))
                    buttons[i].x += w;
            }

            buttons[Math.floor(keyCount/2)].x = buttons[Math.floor(keyCount/2)-1].x + w; //move to center

            
        }*/

        resetInput();
    }

    private function resetInput()
    {
        justPressed = [];
        justReleased = [];
        pressed = [];
        released = [];
        for (i in 0...keyCount)
        {
            justPressed.push(false);
            justReleased.push(false);
            pressed.push(false);
            released.push(true);
        }
    }

    public function updateInput()
    {
        resetInput();
        #if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
                var hit = checkOverlap(touch);
                if (hit > -1)
                    justPressed[hit] = true;
			}
            if (touch.justReleased)
            {
                var hit = checkOverlap(touch);
                if (hit > -1)
                    justReleased[hit] = true;
            }
            if (touch.pressed)
            {
                var hit = checkOverlap(touch);
                if (hit > -1)
                    pressed[hit] = true;
            }
		}
        #else //for testing
        if (FlxG.mouse.justPressed)
        {
            var hit = checkMouseOverlap();
            if (hit > -1)
                justPressed[hit] = true;
        }
        if (FlxG.mouse.justReleased)
        {
            var hit = checkMouseOverlap();
            if (hit > -1)
                justReleased[hit] = true;
        }
        if (FlxG.mouse.pressed)
        {
            var hit = checkMouseOverlap();
            if (hit > -1)
                pressed[hit] = true;
        }
        #end
        for (i in 0...keyCount)
        {
            if (justPressed[i] || pressed[i])
                released[i] = false; //set released

            if (released[i])
            {
                if (buttons[i] != null)
                    buttons[i].alpha = 0.05; //released
            }
            if (pressed[i] || justPressed[i])
            {
                if (buttons[i] != null)
                    buttons[i].alpha = 0.2; //pressed
            }
        }
    }

    function checkOverlap(touch:FlxTouch) 
    {
        for (b in 0...buttons.length)
        {
            if (buttons[b] != null && PlayState.instance != null)
            {
                if (buttons[b].overlapsPoint(touch.getScreenPosition(PlayState.instance.camTransition), true))
                {
                    return b;
                }
            }
        }
        return -1;
    }

    function checkMouseOverlap()  //for testing
    {
        for (b in 0...buttons.length)
        {
            if (buttons[b] != null && PlayState.instance != null)
            {
                if (buttons[b].overlapsPoint(FlxG.mouse.getScreenPosition(PlayState.instance.camTransition), true))
                {
                    return b;
                }
            }
        }
        return -1;
    }

    public static function checkTouchOverlap(touch:FlxTouch, x:Float, y:Float, w:Float, h:Float, ?camera:FlxCamera)
    {
        var rect:FlxObject = new FlxObject(x,y,w,h); //check entire width/height and not specific sprites within the group
        return rect.overlapsPoint(touch.getScreenPosition(camera), false);
    }
    public static function leftPress()
    {
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
            {
                if (touch.x <= FlxG.width*0.33)
                    return true;
            }
        }
        return false;
    }
    public static function rightPress()
    {
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
            {
                if (touch.x >= FlxG.width*0.66)
                    return true;
            }
        }
        return false;
    }

    public static function verticalPressOptions(grp:FlxTypedGroup<Option>, curSelected:Int, ?camera:FlxCamera)
    {
        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
            {
                var selectedAlphabet = grp.members[curSelected].Alphabet_Text;
                if (selectedAlphabet != null)
                {
                    if (MobileControls.checkTouchOverlap(touch, selectedAlphabet.x, selectedAlphabet.y, grp.members[curSelected].getAlphabetWidth(), selectedAlphabet.height, camera))
                    {
                        return 0;
                    }
                    else
                    {
                        if (touch.getScreenPosition(camera).y < selectedAlphabet.y)
                        {
                            return -1;
                        }
                        else if (touch.getScreenPosition(camera).y > selectedAlphabet.y)
                        {
                            return 1;
                        }
                    }
                }
            }
        }
        #end

        return -9999;
    }
    public static function verticalPressAlphabet(grp:FlxTypedGroup<Alphabet>, curSelected:Int, ?camera:FlxCamera)
    {
        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
            {
                var selectedAlphabet = grp.members[curSelected];
                if (selectedAlphabet != null)
                {
                    if (MobileControls.checkTouchOverlap(touch, selectedAlphabet.x, selectedAlphabet.y, selectedAlphabet.width, selectedAlphabet.height, camera))
                    {
                        return 0;
                    }
                    else
                    {
                        if (touch.getScreenPosition(camera).y < selectedAlphabet.y)
                        {
                            return -1;
                        }
                        else if (touch.getScreenPosition(camera).y > selectedAlphabet.y)
                        {
                            return 1;
                        }
                    }
                }
            }
        }
        #end

        return -9999;
    }
    public static function justPressedAny()
    {
        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
            {
                return true;
            }
        }
        #end
        return false;
    }
}