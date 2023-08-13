package substates;

import utilities.NoteHandler;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import states.PlayState;
import flixel.FlxCamera;
import game.StrumNote;
import utilities.PlayerSettings;
import flixel.text.FlxText;
import utilities.CoolUtil;
import flixel.tweens.FlxEase;
import utilities.NoteVariables;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.utils.Assets;

class ControlMenuSubstate extends MusicBeatSubstate
{
    var key_Count:Int = 4;
    var arrow_Group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
    var text_Group:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

    var binds:Array<Array<String>> = utilities.Options.getData("binds", "binds");
    var controllerBinds:Array<Array<String>> = utilities.Options.getData("controllerBinds", "binds");

    var selectedControl:Int = 0;
    var selectingStuff:Bool = false;

    var coolText:FlxText = new FlxText(0,25,0,"Use LEFT and RIGHT to change number of keys\nESCAPE to save binds and exit menu\nRESET+SHIFT to Reset Binds to default\n", 32);

    var killKey:FlxSprite = new FlxSprite();
    var killBind:String = utilities.Options.getData("kill", "binds");
    var killText:FlxText = new FlxText();

    var fullscreenKey:FlxSprite = new FlxSprite();
    var fullscreenBind:String = utilities.Options.getData("fullscreenBind", "binds");
    var fullscreenText:FlxText = new FlxText();

    var pauseKey:FlxSprite = new FlxSprite();
    var pauseBind:String = utilities.Options.getData("pauseBind", "binds");
    var pauseText:FlxText = new FlxText();

    var dodgeKey:FlxSprite = new FlxSprite();
    var dodgeBind:String = utilities.Options.getData("dodgeBind", "binds");
    var dodgeControllerBind:String = utilities.Options.getData("dodgeControllerBind", "binds");
    var dodgeText:FlxText = new FlxText();

    var uiSkin:UISkin;

    public function new()
    {
        FlxG.mouse.visible = true;

        uiSkin = new UISkin("default");

        super();

        coolText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        coolText.screenCenter(X);
        
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
        bg.scrollFactor.set();
        add(bg);

        FlxTween.tween(bg, {alpha: 0.75}, 1, {ease: FlxEase.circOut, startDelay: 0});

        #if PRELOAD_ALL
        create_Arrows();
        add(arrow_Group);
        #else
        Assets.loadLibrary("shared").onComplete(function (_) {
            create_Arrows();
            add(arrow_Group);
        });
        #end
        
        add(text_Group);
        add(coolText);

        setupKeySprite(fullscreenKey, -190);

        var fullscreenIcon:FlxSprite = new FlxSprite();
        fullscreenIcon.frames = Paths.getSparrowAtlas("Bind_Menu_Assets", "preload");
        fullscreenIcon.animation.addByPrefix("idle", "Fullscreen Symbol", 24);
        fullscreenIcon.animation.play("idle");
        fullscreenIcon.updateHitbox();

        fullscreenIcon.x = fullscreenKey.x + (fullscreenKey.width / 2) - (fullscreenIcon.width / 2);
        fullscreenIcon.y = fullscreenKey.y - fullscreenIcon.height - 11;

        fullscreenText.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);

        fullscreenText.text = fullscreenBind;
        fullscreenText.x = fullscreenKey.x + (fullscreenKey.width / 2) - (fullscreenText.width / 2);
        fullscreenText.y = fullscreenKey.y;

        add(fullscreenKey);
        add(fullscreenIcon);
        add(fullscreenText);

        setupKeySprite(killKey, 0);

        var killIcon:FlxSprite = new FlxSprite();
        killIcon.frames = Paths.getSparrowAtlas("Bind_Menu_Assets", "preload");
        killIcon.animation.addByPrefix("idle", "Death Icon", 24);
        killIcon.animation.play("idle");
        killIcon.updateHitbox();

        killIcon.x = killKey.x + (killKey.width / 2) - (killIcon.width / 2);
        killIcon.y = killKey.y - killIcon.height - 16;

        killText.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);

        killText.text = killBind;
        killText.x = killKey.x + (killKey.width / 2) - (killText.width / 2);
        killText.y = killKey.y;

        add(killKey);
        add(killIcon);
        add(killText);

        setupKeySprite(pauseKey, 190);

        var pauseIcon:FlxSprite = new FlxSprite();
        pauseIcon.frames = Paths.getSparrowAtlas("Bind_Menu_Assets", "preload");
        pauseIcon.animation.addByPrefix("idle", "Pause Icon", 24);
        pauseIcon.animation.play("idle");
        pauseIcon.updateHitbox();

        pauseIcon.x = pauseKey.x + (pauseKey.width / 2) - (pauseIcon.width / 2);
        pauseIcon.y = pauseKey.y - pauseIcon.height - 16;

        pauseText.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);

        pauseText.text = pauseBind;
        pauseText.x = pauseKey.x + (pauseKey.width / 2) - (pauseText.width / 2);
        pauseText.y = pauseKey.y;

        add(pauseKey);
        add(pauseIcon);
        add(pauseText);


        setupKeySprite(dodgeKey, -190*2);


        var dodgeIcon:FlxSprite = new FlxSprite();
        dodgeIcon.loadGraphic(Paths.image("dodgeIcon", "preload"));
        dodgeIcon.scale *= 0.5;
        dodgeIcon.antialiasing = true;
        dodgeIcon.updateHitbox();

        dodgeIcon.x = dodgeKey.x + (dodgeKey.width / 2) - (dodgeIcon.width / 2);
        dodgeIcon.y = dodgeKey.y - dodgeIcon.height - 16;

        dodgeText.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);

        dodgeText.text = dodgeBind;
        dodgeText.x = dodgeKey.x + (dodgeKey.width / 2) - (dodgeText.width / 2);
        pauseText.y = dodgeKey.y;

        add(dodgeKey);
        add(dodgeIcon);
        add(dodgeText);
    }



    override function update(elapsed:Float) {
        super.update(elapsed);

        var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
        var reset = controls.RESET;
        var back = controls.BACK;
        var shift = FlxG.keys.pressed.SHIFT;

        if(arrow_Group != null)
        {
            if(reset && shift)
            {
                binds = NoteVariables.Default_Binds;
                controllerBinds = NoteVariables.Default_Controller_Binds;
                fullscreenBind = "F11";
                killBind = "R";
                pauseBind = "ENTER";
                dodgeBind = "SPACE";
                dodgeControllerBind = "LEFT_TRIGGER";
            }
            
            if(back)
            {
                utilities.Options.setData(this.binds, "binds", "binds");
                utilities.Options.setData(this.controllerBinds, "controllerBinds", "binds");
                utilities.Options.setData(fullscreenBind, "fullscreenBind", "binds");
                utilities.Options.setData(killBind, "kill", "binds");
                utilities.Options.setData(pauseBind, "pauseBind", "binds");
                utilities.Options.setData(dodgeBind, "dodgeBind", "binds");
                utilities.Options.setData(dodgeControllerBind, "dodgeControllerBind", "binds");
    
                PlayerSettings.player1.controls.loadKeyBinds();
    
                FlxG.mouse.visible = false;
                FlxG.state.closeSubState();
            }

            var cam = FlxG.camera;
            if (PlayState.instance != null && FlxG.state == PlayState.instance)
                cam = PlayState.instance.camHUD;


            var justPressed:Bool = FlxG.mouse.justPressed;
            var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
            if (gamepad != null)
            {
                if (gamepad.anyJustPressed([FlxGamepadInputID.A, FlxGamepadInputID.START]))
                {
                    justPressed = true;
                    trace('press');
                }
            }
    
            if(fullscreenKey.overlapsPoint(FlxG.mouse.getScreenPosition(cam), false) && FlxG.mouse.justPressed && !selectingStuff)
            {
                selectedControl = -1;
                selectingStuff = true;
            }
            else if(fullscreenKey.overlapsPoint(FlxG.mouse.getScreenPosition(cam), false))
                fullscreenKey.color = FlxColor.GRAY;
            else
                fullscreenKey.color = FlxColor.WHITE;
    
            if(killKey.overlapsPoint(FlxG.mouse.getScreenPosition(cam), false) && FlxG.mouse.justPressed && !selectingStuff)
            {
                selectedControl = -2;
                selectingStuff = true;
            }
            else if(killKey.overlapsPoint(FlxG.mouse.getScreenPosition(cam), false))
                killKey.color = FlxColor.GRAY;
            else
                killKey.color = FlxColor.WHITE;

            if(pauseKey.overlapsPoint(FlxG.mouse.getScreenPosition(cam), false) && FlxG.mouse.justPressed && !selectingStuff)
            {
                selectedControl = -3;
                selectingStuff = true;
            }
            else if(pauseKey.overlapsPoint(FlxG.mouse.getScreenPosition(cam), false))
                pauseKey.color = FlxColor.GRAY;
            else
                pauseKey.color = FlxColor.WHITE;

            if(dodgeKey.overlapsPoint(FlxG.mouse.getScreenPosition(cam), false) && justPressed && !selectingStuff)
            {
                selectedControl = -4;
                selectingStuff = true;
            }
            else if(dodgeKey.overlapsPoint(FlxG.mouse.getScreenPosition(cam), false))
                dodgeKey.color = FlxColor.GRAY;
            else
                dodgeKey.color = FlxColor.WHITE;
    
            var justSelected:Bool = false;
            for(x in arrow_Group)
            {
                if(x.overlapsPoint(FlxG.mouse.getScreenPosition(cam), false) && justPressed && !selectingStuff)
                {
                    selectedControl = x.ID;
                    selectingStuff = true;
                    justSelected = true;
                    trace('select');
                }
    
                if(x.overlapsPoint(FlxG.mouse.getScreenPosition(cam), false) || x.ID == selectedControl && selectingStuff)
                    x.color = FlxColor.GRAY;
                else
                    x.color = FlxColor.WHITE;
            }
    
            if(selectingStuff && FlxG.keys.justPressed.ANY)
            {
                var curKey = FlxG.keys.getIsDown()[0].ID.toString();
    
                if(selectedControl > -1)
                    this.binds[key_Count - 1][selectedControl] = curKey;
                else
                {
                    switch(selectedControl)
                    {
                        case -1:
                            fullscreenBind = curKey;
                        case -2:
                            killBind = curKey;
                        case -3:
                            pauseBind = curKey;
                        case -4:
                            dodgeBind = curKey;
                    }
                }
            }
            if(selectingStuff && gamepad != null && gamepad.firstJustPressedID() != FlxGamepadInputID.NONE && !justSelected)
            {
                //var curKey = FlxG.keys.getIsDown()[0].ID.toString();
                var curKey:String = FlxGamepadInputID.toStringMap.get(gamepad.firstJustPressedID());
    
                if(selectedControl > -1)
                    this.controllerBinds[key_Count - 1][selectedControl] = curKey;
                else
                {
                    switch(selectedControl)
                    {
                        case -4:
                            dodgeControllerBind = curKey;
                    }
                }
            }
    
            if(!selectingStuff && (leftP || rightP))
            {
                if(leftP)
                    key_Count -= 1;
    
                if(rightP)
                    key_Count += 1;
    
                if(key_Count < 1)
                    key_Count = 1;
    
                if(key_Count > NoteVariables.Note_Count_Directions.length)
                    key_Count = NoteVariables.Note_Count_Directions.length;
    
                create_Arrows();
            }
    
            if(selectingStuff && (FlxG.keys.justPressed.ANY || (gamepad != null && gamepad.anyButton(JUST_PRESSED))) && !justSelected)
                selectingStuff = false;
    
            update_Text();
        }
    }

    function update_Text()
    {
        for(i in 0...text_Group.length)
        {
            if (MusicBeatSubstate.usingController)
                text_Group.members[i].text = NoteHandler.formatControllerBind(controllerBinds[key_Count - 1][i]);
            else
                text_Group.members[i].text = binds[key_Count - 1][i];
        }

        fullscreenText.text = (MusicBeatSubstate.usingController ? "---" : fullscreenBind);
        fullscreenText.x = fullscreenKey.x + (fullscreenKey.width / 2) - (fullscreenText.width / 2);
        fullscreenText.y = fullscreenKey.y + (fullscreenKey.height / 2) - (fullscreenText.height / 2);

        killText.text = (MusicBeatSubstate.usingController ? "---" : killBind);
        killText.x = killKey.x + (killKey.width / 2) - (killText.width / 2);
        killText.y = killKey.y + (killKey.height / 2) - (killText.height / 2);

        pauseText.text = (MusicBeatSubstate.usingController ? "---" : pauseBind);
        pauseText.x = pauseKey.x + (pauseKey.width / 2) - (pauseText.width / 2);
        pauseText.y = pauseKey.y + (pauseKey.height / 2) - (pauseText.height / 2);

        dodgeText.text = (MusicBeatSubstate.usingController ? NoteHandler.formatControllerBind(dodgeControllerBind) : dodgeBind);
        dodgeText.x = dodgeKey.x + (dodgeKey.width / 2) - (dodgeText.width / 2);
        dodgeText.y = dodgeKey.y + (dodgeKey.height / 2) - (dodgeText.height / 2);
    }

    function create_Arrows(?new_Key_Count)
    {
        if(new_Key_Count != null)
            key_Count = new_Key_Count;

        arrow_Group.clear();
        
        text_Group.forEach(function(text:FlxText) {
            text_Group.remove(text);
            text.kill();
            text.destroy();
        });

        text_Group.clear();

        var strumLine:FlxSprite = new FlxSprite(0, FlxG.height / 2);

		for (i in 0...key_Count)
        {
            var babyArrow:StrumNote = new StrumNote(0, strumLine.y, i, uiSkin, key_Count);

            babyArrow.loadStrum();
            babyArrow.setupStrumPosition(0.5);

            arrow_Group.add(babyArrow);

            //var coolWidth = Std.int(40 - ((key_Count - 5) * 2) + (key_Count == 10 ? 30 : 0));
                                                    // funny 4 key math i guess, full num is 2.836842105263158 (width / previous key width thingy which was 38)
            var coolWidth = Math.ceil(babyArrow.width / 2.83684);

            var coolText = new FlxText((babyArrow.x + (babyArrow.width / 2)) - (coolWidth / 2), babyArrow.y - (coolWidth / 2), coolWidth, binds[key_Count - 1][i], coolWidth);
            add(coolText);

            text_Group.add(coolText);
        }
    }

    function setupKeySprite(key:FlxSprite, ?x:Float = 0.0)
    {
        key.frames = Paths.getSparrowAtlas("Bind_Menu_Assets", "preload");
        key.animation.addByPrefix("idle", "Button", 24);
        key.animation.play("idle");
        key.updateHitbox();

        key.screenCenter(X);
        key.y = FlxG.height - key.height - 8;

        key.x += x;
    }
}