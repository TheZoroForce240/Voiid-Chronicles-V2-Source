package ui;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BlendMode;
import openfl.display.BitmapDataChannel;
import flixel.math.FlxPoint;
import openfl.display.BitmapData;
import flixel.math.FlxMath;
import game.Conductor;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.display.FlxPieDial;
import states.PlayState;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using flixel.util.FlxSpriteUtil;

class CircleShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        float PI = 3.14159265358;
        uniform float percent;

        vec2 rotate(vec2 v, float a) {
            float s = sin(a);
            float c = cos(a);
            mat2 m = mat2(c, -s, s, c);
            return m * v;
        }

        void main()
        {
            vec2 uv = openfl_TextureCoordv;
            vec4 spritecolor = flixel_texture2D(bitmap, openfl_TextureCoordv);

            //rotate uv so circle matches properly
            uv -= vec2(0.5, 0.5);
            uv = rotate(uv, PI*0.5);
            uv += vec2(0.5, 0.5);

            float percentAngle = (percent*360.0) / (180.0/PI);

            vec2 center = vec2(0.5, 0.5);
            float radius = 0.5;
            float angle = atan(uv.y - center.y, uv.x - center.x);
            float distance = length(uv - center);

            if ((angle + (PI)) > percentAngle)
            {
                spritecolor = vec4(0.0,0.0,0.0,0.0);
            }
        
            gl_FragColor = spritecolor;
        }
    ')

    public function new()
    {
       super();
    }
}

class NoteTimer extends FlxTypedSpriteGroup<FlxSprite>
{
    private var instance:PlayState;
    private var timerText:FlxText;
    private var timerCircle:FlxSprite;
    private var circleShader:CircleShader = new CircleShader();
    public function new(instance:PlayState)
    {
        super();
        this.instance = instance;

        timerCircle = new FlxSprite().loadGraphic(Paths.image("circleThing"));
        timerCircle.antialiasing = true;
        timerCircle.shader = circleShader;
        timerCircle.scale *= 0.75;
        timerCircle.updateHitbox();
        add(timerCircle);
        timerText = new FlxText(0,0,0,"");
        timerText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(timerText);

        timerCircle.screenCenter();
        timerText.screenCenter();

        circleShader.percent.value = [0.0];

        //alpha = 0;
    }

    private var lastStartTime:Float = FlxMath.MAX_VALUE_FLOAT;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        var timeTillNextNote:Float = FlxMath.MAX_VALUE_FLOAT;

        if (instance != null)
        {
            var show:Bool = false;
            if (Conductor.songPosition > 0)
            {
                for (daNote in instance.notes)
                    if (daNote.mustPress == (PlayState.characterPlayingAs == 0)) //check notes for closest
                    {
                        var timeDiff = daNote.strumTime-Conductor.songPosition;
                        if (timeDiff < timeTillNextNote)
                            timeTillNextNote = timeDiff;
                    }

                if (timeTillNextNote == FlxMath.MAX_VALUE_FLOAT) //now check unspawnNotes if not found anything
                {
                    for (daNote in instance.unspawnNotes)
                        if (daNote.mustPress == (PlayState.characterPlayingAs == 0))
                        {
                            var timeDiff = daNote.strumTime-Conductor.songPosition;
                            if (timeDiff < timeTillNextNote)
                            {
                                timeTillNextNote = timeDiff;
                                break;
                            }
                                
                        }
                }
                show = timeTillNextNote != FlxMath.MAX_VALUE_FLOAT; //if found a note and time is larger than 2 secs
            }

            //visible = false;
            var targetAlpha:Float = 0.0;
            if (show)
            {
                //trace('show timer');
                if (lastStartTime == FlxMath.MAX_VALUE_FLOAT && timeTillNextNote > 3000)
                    lastStartTime = timeTillNextNote;

                //trace(timeTillNextNote);

                if (lastStartTime != FlxMath.MAX_VALUE_FLOAT)
                {
                    var secsLeft:Float = Math.ceil(timeTillNextNote*0.001);
                    var percent:Float = timeTillNextNote/lastStartTime;
                    //timerCircle.amount = percent;
                    // trace(percent);
                    if (percent <= 0.0)
                    {
                        lastStartTime = FlxMath.MAX_VALUE_FLOAT; //reset
                        timerText.text = "";
                        circleShader.percent.value = [0.0];
                    }
                    else
                    {
                        circleShader.percent.value = [percent];
                        timerText.text = ""+secsLeft;
                    }
                    updatePosition();
                    
                }
                if (timeTillNextNote > 1000)
                {
                    //visible = true;
                    targetAlpha = 1.0;
                }
            }

            timerText.alpha = FlxMath.lerp(timerText.alpha, targetAlpha, elapsed*5);
            timerCircle.alpha = timerText.alpha;
        }
    }

    function updatePosition()
    {
        timerCircle.screenCenter();
        timerText.screenCenter();
        if (utilities.Options.getData("downscroll"))
        {
            timerCircle.y += 260;
            timerText.y += 260;
        }
        else 
        {
            timerCircle.y -= 260;
            timerText.y -= 260;
        }
 
    }
}