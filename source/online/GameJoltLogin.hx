package online;

import states.VoiidMainMenuState;
import states.MusicBeatState;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxButtonPlus;
import flixel.text.FlxText;
import flixel.FlxG;
import lime.system.System;
import ui.Alphabet;

class GameJoltLogin extends MusicBeatState
{
    var unInputText:FlxInputText;
    var utInputText:FlxInputText;
    var loginButton:FlxButtonPlus;
    var signOutButton:FlxButtonPlus;
    public function new()
    {
        super();
    }
    override public function create()
    {
        FlxG.mouse.visible = true;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/BG'));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = true;
        add(bg);

        var text:Alphabet = new Alphabet(0, 100, 'GameJolt Login', true, false, 1);
        add(text);
        text.screenCenter(X);

        var text2:Alphabet = new Alphabet(0, 250, 'User Name', true, false, 1);
        add(text2);
        text2.x = FlxG.width*0.1;

        var text3:Alphabet = new Alphabet(0, 400, 'User Token', true, false, 1);
        add(text3);
        text3.x = FlxG.width*0.1;

        
        //set up typers
        unInputText = new FlxInputText(Math.floor(FlxG.width*0.5),250, Math.floor(FlxG.width*0.4), '', 32);
        add(unInputText);
        if (FlxG.save.data.gameJoltUserName != null)
            unInputText.text = FlxG.save.data.gameJoltUserName;

        

        unInputText.y = text2.y + (text2.height/2) - (unInputText.height/2);

        utInputText = new FlxInputText(Math.floor(FlxG.width*0.5),400, Math.floor(FlxG.width*0.4), '', 32);
        add(utInputText);
        utInputText.passwordMode = true;
        if (FlxG.save.data.gameJoltUserToken != null)
            utInputText.text = FlxG.save.data.gameJoltUserToken;

        #if mobile //idk if this works but ye
        unInputText.textField.needsSoftKeyboard = true;
        unInputText.textField.needsSoftKeyboard = true;
        #end

        utInputText.y = text3.y + (text3.height/2) - (utInputText.height/2);

        


        //set up buttons
        loginButton = new FlxButtonPlus(Math.floor(FlxG.width*0.25), 550, function()
        {
            FlxG.save.data.gameJoltUserName = unInputText.text;
            FlxG.save.data.gameJoltUserToken = utInputText.text;
            FlxG.save.flush();
            FlxG.switchState(new VoiidMainMenuState());
        }, 'Log In', 200, 60);
        add(loginButton);
        loginButton.textNormal.setFormat(Paths.font("Contb___.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        loginButton.textHighlight.setFormat(Paths.font("Contb___.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        signOutButton = new FlxButtonPlus(Math.floor(FlxG.width*0.75), 550, function()
        {
            FlxG.save.data.gameJoltUserName = null;
            FlxG.save.data.gameJoltUserToken = null;
            FlxG.save.flush();
            //FlxGameJolt.closeSession();
            //FlxG.resetGame();            
            //GameJoltStuff.loggedIn = false;
            //GameJoltStuff.connectedToGame = false;
            //GameJoltStuff.relogin();

            //LoadingState.loadAndSwitchState(new MainMenuState());
            System.exit(0);
        }, 'Sign Out\n(closes game)', 200, 60);
        add(signOutButton);
        signOutButton.textNormal.setFormat(Paths.font("Contb___.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        signOutButton.textHighlight.setFormat(Paths.font("Contb___.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

    

        signOutButton.x -= signOutButton.width;
        super.create();
    }

    override function update(elapsed:Float)
    {
        if (utInputText.hasFocus || unInputText.hasFocus) //stop 0 from muting lol
        {
            //FlxG.sound.muteKeys = [];
            //FlxG.sound.volumeDownKeys = [];
            //FlxG.sound.volumeUpKeys = [];
        }
        else 
        {
            //FlxG.sound.muteKeys = TitleState.muteKeys;
			//FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			//FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
        }
        if (controls.BACK && !utInputText.hasFocus && !unInputText.hasFocus) {
            FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(new VoiidMainMenuState());
			//LoadingState.loadAndSwitchState(new options.OptionsState());
		}
        super.update(elapsed);
    }
}