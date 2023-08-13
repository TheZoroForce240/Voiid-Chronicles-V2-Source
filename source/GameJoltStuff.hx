package;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import states.FreeplayState;
import flixel.ui.FlxButton;
import haxe.Json;
import states.PlayState;
import haxe.Serializer;
import substates.MusicBeatSubstate;
import states.LoadingState;
import states.MusicBeatState;
import Popup.MessagePopup;
import haxe.io.Bytes;
import openfl.utils.ByteArray;
import haxe.crypto.Base64;
import states.VoiidAwardsState;
import states.VoiidMainMenuState;
import flixel.math.FlxMath;
import lime.system.System;
import flixel.input.FlxInput;
import flixel.util.FlxTimer;
import flixel.addons.api.FlxGameJolt;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxButtonPlus;
import flixel.text.FlxText;
import ui.Alphabet;

using StringTools;

typedef SongLeaderboard =
{
    var song:String;
    var diff:String;
    var scores:Array<LeaderboardScore>;
} 

typedef LeaderboardScore = 
{
    var name:String;
    var acc:Float;
    var score:Int;
    var misses:Int;
}

//for anyone looking through this file sorry its a bit messy lol

class GameJoltStuff
{
    public static final gameID:Int = 810060;

    public static var fetchingData:Bool = false;

    public static var connectedToGame:Bool = false;
    public static var loggedIn:Bool = false;

    public static function initStuffs():String
    {
        if (FlxG.save.data.gameJoltUserName == null)
            return 'no login found';
        if (FlxG.save.data.gameJoltUserToken == null)
            return 'no login found';

        var privateKey:String = '';

        if (privateKey == '')
        {
            //MainMenuState.makePopupThing('GameJolt Disabled, no private key found.');
            Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "GameJolt Disabled, no private key found."));
            return 'no private key';
        }

        var gotResponse:Bool = false;
        new FlxTimer().start(10, function(timer:FlxTimer)
        {
            if (connectedToGame && loggedIn)
                return;

            if (!gotResponse)
            {
                Main.popupManager.addPopup(new MessagePopup(5, 300, 60, 'Couldn\'t connect to GameJolt servers'));
            }
        });

        FlxGameJolt.init(gameID, privateKey, true, FlxG.save.data.gameJoltUserName, FlxG.save.data.gameJoltUserToken, function(didLoginProperly:Bool) 
        {
            gotResponse = true;
            connectedToGame = true;
            loggedIn = didLoginProperly;
            if (loggedIn)
            {
                trace('logged in');
                setupSession();
                Main.popupManager.addPopup(new MessagePopup(5, 300, 60, 'Signed into GameJolt as ' + FlxG.save.data.gameJoltUserName));
                //MainMenuState.makePopupThing('Signed into GameJolt as ' + FlxG.save.data.gameJoltUserName);

                //checkAchievement(171634);
            }
            else 
            {
                Main.popupManager.addPopup(new MessagePopup(5, 300, 50, 'Error signing into GameJolt'));
                //MainMenuState.makePopupThing('Error signing into GameJolt');
            }

            

            
        });
        //if (!loggedIn)
            //return 'couldnt login properly';
        
        
        return 'trying to login'; //should be logged in????  
    }
    
    private static var pingTimer:FlxTimer = null;

    public static function setupSession() //call after login
    {
        //FlxGameJolt.closeSession(); //just in case i guess

        FlxGameJolt.openSession(function(mapThing:Map<String,String>)
        {
            //trace(mapThing);
            trace('started session');
            resetPingTimer();
            AwardManager.syncGamejoltTrophies();
        });
    }
    public static function resetPingTimer()
    {
        ping();
        pingTimer = new FlxTimer().start(30, function(tmr:FlxTimer) //ping every 30 secs
        {
            var doPing = true;
            if (GameJoltStuff.ServerListSubstate.player1Client != null && GameJoltStuff.ServerListSubstate.player2Client != null)
                if (GameJoltStuff.ServerListSubstate.player1Client.playerConnected && GameJoltStuff.ServerListSubstate.player2Client.playerConnected)
                    doPing = false; //already pinging constantly
            if (doPing)
                ping(); 
        }, 0); //0 means loop forever
    }
    public static function ping()
    {
        FlxGameJolt.pingSession(true, function(mapThing:Map<String,String>){
            //trace('pinged gamejolt ' + mapThing);
            //trace(mapThing.get('success'));
            if (mapThing.get('success') != null && mapThing.get('success') == 'false') //if theres an error message then reset session, probably if you were afk or something
            {                                    //not getting any traces that say it resets but it seems to work on the next ping???
                setupSession();
            }
            //trace('ping!');
                
            //if (!ServerListSubstate.createdAClient)
                //GameJoltStuff.syncAchievements();
        }); 
    }

    public static function syncAchievements()
    {
        //rewrite this later
        /*if (connectedToGame && loggedIn)
        {
            for (i in 0...Achievements.achievementsStuff.length)
            {
                if (Achievements.isAchievementUnlocked(Achievements.achievementsStuff[i][2]) && Achievements.achievementsStuff[i][4] != -1) //check psych
                {
                    unlockAchievement(Achievements.achievementsStuff[i][4]);
                    /*checkAchievement(Achievements.achievementsStuff[i][4], function(mapThing:Map<String,String>) //check if unlocked on gj
                    {
                        var isUnlocked = false; 
                        //if (mapThing['achieved'] != null)
                        //{
                        //trace(mapThing.get('achieved'));
                        //if (mapThing.get('achieved') != 'false')
                            //isUnlocked = true;
                        //}

                        if (!isUnlocked)
                        {
                             //idk just try to unlock everytime lol, 
                            //cant figure out how to find if achievement is unlocked already on gj, could be because theyre hidden rn
                            //trace('unlocked gj achievement:' + Achievements.achievementsStuff[i][2] + ' ' + Achievements.achievementsStuff[i][4]);
                        }
                        else 
                        {
                            //trace('already unlocked');
                        }
                    });*/
                //}
            //}

        //}
    }
    public static function convertToLeaderboardScore(data:String):LeaderboardScore
    {
        var shit = data.split(':');
        return { name: shit[0], acc: Std.parseFloat(shit[1]), score: Std.parseInt(shit[2]), misses: Std.parseInt(shit[3])};
    }

    public static function getHighscoreSaveString(songname:String, songdiff:String, speed:Float, opponent:Bool)
    {
        songname = songname.replace(" ", "-");
        songdiff = songdiff.replace(" ", "-");
        speed = FlxMath.roundDecimal(speed, 2);
        var saveStr:String = songname+"-"+songdiff;
        if (speed != 1.0)
            saveStr = songname+"-"+songdiff+"-"+speed;
        if (opponent)
            saveStr += "-opponent";

        switch(songname) //easy system for updated songs/recharts without breaking/resetting the old scores (for older builds)
        {
            case "sporting": 
                saveStr = "new-"+saveStr; 
        }

        return saveStr;
    }

    public static function addHighScore(songname:String, songdiff:String, speed:Float, opponent:Bool, acc:Float, score:Int, misses:Int)
    {
        songname = songname.replace(" ", "-");
        songdiff = songdiff.replace(" ", "-");
     
        var saveStr:String = getHighscoreSaveString(songname, songdiff, speed, opponent);

        //trace(saveStr);
        
        //not using default gj scoreboard because i think it can only show 1 number, here i want it to show 3,
        //also not public on the gj page if i do this way
        if (connectedToGame && loggedIn)
        {
            FlxGameJolt.fetchData(saveStr, false, function(mapThing:Map<String,String>)
            {
                if (mapThing != null)
                {
                    if (mapThing.get('success') == 'true' && mapThing.exists('data'))
                    {
                        var dataString = mapThing.get('data');

                        var scoreList:SongLeaderboard = haxe.Unserializer.run(dataString); //unseralize from string to type

                        var yourScore:LeaderboardScore = {name: FlxG.save.data.gameJoltUserName, acc: acc, score: score, misses: misses};

                        var newScores:Array<LeaderboardScore> = [];
                        var alreadyishigherscore = false;
                        for (i in 0...scoreList.scores.length)
                        {
                            var score = scoreList.scores[i];
                            if ((yourScore.name != score.name) || (yourScore.score < score.score && yourScore.name == score.name))
                                newScores.push(score);
                            if (yourScore.name == score.name && yourScore.score < score.score)
                                alreadyishigherscore = true; //dont add score if theres already a higher one for yours
                        }
                        if (!alreadyishigherscore)
                            newScores.push(yourScore);
                        
                        newScores.sort(function(a, b){
                            if (a.score > b.score)
                                return -1;
                            else if (a.score < b.score)
                                return 1;
                            else
                                return 0;
                        });
    
                        while(newScores.length > 100) //allow up to 100 scores
                            newScores.remove(newScores[newScores.length-1]);

                        scoreList.scores = newScores.copy();

                        var outputString:String = haxe.Serializer.run(scoreList); //serialize it
                        //trace(scoreList);
                        //trace(outputString);
                        FlxGameJolt.setData(saveStr, outputString, false, function(mapThing:Map<String,String>)
                        {
                            //trace(mapThing);
                        });
                    }
                    else 
                    {
                        if (mapThing.exists('message'))
                        {
                            if (mapThing.get('message') == 'No item with that key could be found.')
                            {
                                trace('couldnt find existing score, adding new thingy');
                                var yourScore:LeaderboardScore = {name: FlxG.save.data.gameJoltUserName, acc: acc, score: score, misses: misses};
                                var scoreList:SongLeaderboard = {song: songname, diff: songdiff, scores: [yourScore]};

                                var outputString:String = haxe.Serializer.run(scoreList); //serialize it
                                //trace(scoreList);
                                //trace(outputString);
                                FlxGameJolt.setData(saveStr, outputString, false, function(mapThing:Map<String,String>)
                                {
                                    //trace(mapThing);
                                });
                            }
                        }
                    }
                }
            });
        }
    }
    public static function getLeaderboard(songname:String, songdiff:String, speed:Float, opponent:Bool, callBack:String->Void)
    {
        var saveStr:String = getHighscoreSaveString(songname, songdiff, speed, opponent);

        //trace(saveStr);

        if (connectedToGame && loggedIn)
        {
            FlxGameJolt.fetchData(saveStr, false, function(mapThing:Map<String,String>)
            {
                //trace(mapThing);
                if (mapThing != null)
                {
                    if (mapThing.get('success') == 'true' && mapThing.exists('data'))
                    {
                        var asString = mapThing.get('data');
                        callBack(asString);
                    }
                    else 
                    {
                        if (mapThing.exists('message'))
                        {
                            if (mapThing.get('message') == 'No item with that key could be found.')
                            {
                                callBack('noScores');
                            }
                            else 
                            {
                                callBack('error');
                            }
                        }
                        else 
                        {
                            callBack('error');
                        }
                    }
                }
            });
        }
        else 
        {
            callBack('notLoggedIn');
        }
    }

    public static function unlockAchievement(id:Int)
    {
        if (connectedToGame && loggedIn)
        {
            FlxGameJolt.addTrophy(id);
        }
    }

    public static function checkAchievement(id:Int, ?func:Map<String,String>->Void)
    {
        if (connectedToGame && loggedIn)
        {
            FlxGameJolt.fetchTrophy(id, function(mapThing:Map<String,String>)
            {
                //idk how to do this lol
                //trace(mapThing);
                if (func != null)
                    func(mapThing);
                
            });
        }
    }

    public static function getTimePlayed(func:Map<String,String>->Void)
    {
        if (connectedToGame && loggedIn)
        {
            FlxGameJolt.fetchData('Time', true, function(mapThing:Map<String,String>)
            {
                if (func != null)
                    func(mapThing); //callback thing
            });
        }
    }

    public static function login()
    {
        FlxGameJolt.authUser(FlxG.save.data.gameJoltUserName, FlxG.save.data.gameJoltUserToken, function(didLoginProperly:Bool) 
        {
            loggedIn = didLoginProperly;
            if (loggedIn)
            {
                trace('logged in');
                setupSession();
                //MainMenuState.makePopupThing('Signed in to GameJolt as ' + FlxG.save.data.gameJoltUserName);
            }
            else
            {
                //MainMenuState.makePopupThing('Error signing into GameJolt');
                trace('could not sign in');
            } 
                

        });
    }
}

/*
class GamejoltLoginPopup extends MusicBeatState
{
    var yes:Alphabet;
    var no:Alphabet;
    public function new()
    {
        super();

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('optionsmenu'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
        //FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

        var text:Alphabet = new Alphabet(0, 100, 'Do you want to login to GameJolt?', true, false, 0.05, 0.75);
        add(text);
        text.screenCenter(X);

        var text2:Alphabet = new Alphabet(0, 100, "You get access to Achievements,", true, false, 0.05, 0.75);
        add(text2);
        text2.screenCenter(X);
        text2.y += text2.height*2;

        var text3:Alphabet = new Alphabet(0, text2.y, "Leaderboards and Online Multiplayer.", true, false, 0.05, 0.75);
        add(text3);
        text3.screenCenter(X);
        text3.y += text2.height;

        var text4:Alphabet = new Alphabet(0, text3.y, "(This won't appear again.)", true, false, 0.05, 0.75);
        add(text4);
        text4.screenCenter(X);
        text4.y += text3.height;

        yes = new Alphabet(0, 450, 'YES', true);
        yes.x = FlxG.width*0.2;
        add(yes);
        yes.alpha = 0.6;

        no = new Alphabet(0, 450, 'NO', true);
        no.x = FlxG.width*0.8;
        no.x -= no.width;
        add(no);
        no.alpha = 0.6;

        FlxG.save.data.seenGameJoltPopup = true;
        ClientPrefs.saveSettings();

    }

    var selected:Bool = false;
    override function update(elapsed:Float)
    {
        if (!selected)
        {
            no.alpha = 0.6;
            yes.alpha = 0.6;
            if (FlxG.mouse.overlaps(yes)) 
            {
                yes.alpha = 1;
                if (FlxG.mouse.justPressed)
                {
                    selected = true;
                    LoadingState.loadAndSwitchState(new GameJoltLogin());
                }

            }
            else if (FlxG.mouse.overlaps(no)) 
            {
                no.alpha = 1;
                if (FlxG.mouse.justPressed)
                {
                    selected = true;
                    MusicBeatState.switchState(new MainMenuState());
                    
                }

            }
        }
        super.update(elapsed);
    }
}*/

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




class LeaderboardSubstate extends substates.MusicBeatSubstate
{
    var leaderBoardText:FlxText;
    var curScroll:Float = 0;

    var opponent:Bool = false;
    var scrollBar:ScrollBar;

    var songname:String;
    var diff:String;
    var speed:Float;

    var title:FlxText;

	public function new(songname:String, diff:String, speed:Float)
    {
        super();
        
        speed = FlxMath.roundDecimal(speed, 2);
        this.songname = songname;
        this.diff = diff;
        this.speed = speed;

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

        title = new FlxText(FlxG.width * 0.7, 20, 0, "Leaderboards for\n"+songname+' ('+diff+')' + (speed != 1.0 ? " ("+speed+"x)" : "")+ "\n", 20);
		title.setFormat(Paths.font("Contb___.ttf"), 48, FlxColor.WHITE, CENTER);
        title.screenCenter(X);


		

        leaderBoardText = new FlxText(FlxG.width * 0.7, 150, 0, "Fetching scores...", 20);
		leaderBoardText.setFormat(Paths.font("Contb___.ttf"), 32, FlxColor.WHITE, CENTER);
        leaderBoardText.screenCenter(X);
		add(leaderBoardText);

        var pageTabBG = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/thing"));
		pageTabBG.screenCenter();
		pageTabBG.y = 10;
		add(pageTabBG);
        add(title);


        updateText();

        FlxG.mouse.visible = true;



    }

    var waiting:Bool = false;

    function updateText()
    {
        waiting = true;
        title.text = "Leaderboards for\n<  "+songname+' ('+diff+')' + (speed != 1.0 ? " ("+speed+"x)" : "") + (opponent ? " (Opponent)" : "") + "  >\n";
        title.screenCenter(X);
        GameJoltStuff.getLeaderboard(songname.toLowerCase(), diff.toLowerCase(), speed, opponent, function(str:String)
        {
            if (scrollBar != null)
                remove(scrollBar);
            var text:String = '';
            //trace(str);
            switch(str)
            {
                case 'noScores':
                    text += '\nNo scores found.';
                case 'notLoggedIn':
                    text += '\nNot logged in.';
                case 'error': 
                    text += '\nError fetching scores.';
                default: 
                    //trace(str);
                    var scoreList:GameJoltStuff.SongLeaderboard;
                    try
                    {
                        scoreList = haxe.Unserializer.run(str); //unseralize from string to type
                    }
                    catch(e)
                    {
                        text += '\nError fetching scores.';
                        leaderBoardText.text = text+"\n";
                        leaderBoardText.screenCenter(X);
                        return;
                    }                    
                    var limit = scoreList.scores.length;
                    //if (limit > 3)
                        //limit = 3; //only show top 3 
                    
                    for (i in 0...limit)
                    {
                        var data = scoreList.scores[i];
                        text += '\n'+(i+1)+'. ';
                        text += ''+data.name;
                        text += ' | Accuracy: '+data.acc+'%';
                        text += ' | Score: '+data.score;
                        text += ' | Misses: '+data.misses;
                        text += "\n";
                    }
                    //leaderBoardText.text += '\n[Press ALT to view all scores]';
            }
            //leaderboardBG.setGraphicSize(Std.int(FlxG.width*0.5), Std.int(leaderBoardText.height) + 10);
            //leaderboardBG.updateHitbox();
            leaderBoardText.text = text+"\n";
            leaderBoardText.screenCenter(X);

            if (leaderBoardText.height-400 > 0)
            {
                scrollBar = new ScrollBar(1200, 50, 20, 620, this, "curScroll", leaderBoardText.height-400);
                add(scrollBar);
            }

            waiting = false;

        });
    }

	override function update(elapsed:Float)
    {
        if (controls.BACK)
        {
            FlxG.mouse.visible = false;
            close();
        }
        if (waiting)
        {
            super.update(elapsed);
            return;
        }
            
        if (controls.LEFT_P || controls.RIGHT_P)
        {
            opponent = !opponent;
            updateText();
        }
        curScroll -= FlxG.mouse.wheel*50*elapsed*480;
        if (controls.DOWN)
            curScroll += 800*elapsed;
        if (controls.UP)
            curScroll -= 800*elapsed;
        
        var listHeight:Float = leaderBoardText.height-400;
        if (listHeight < 0)
            listHeight = 0;
        
        curScroll = FlxMath.bound(curScroll, 0, listHeight); //bound

        leaderBoardText.y = FlxMath.lerp(leaderBoardText.y,150-curScroll, elapsed*10);
        super.update(elapsed);
    }
}


typedef ClientData = 
{
    var serverID:String;
    var playerName:String;
    var playerConnected:Bool;
    var playerLoaded:Bool;

    var playerScore:Int;
    var playerMisses:Int;
    var playerAccuracy:Float;
    var playerHealth:Float;
    var playerRatingName:String;
    var playerRatingFC:String;
    var playerCombo:Int;
    var playerDied:Bool;

    var song:String;
    var diff:String;
    var songSpeed:Float;

    var lastTimestamp:Int;
    var playerFinishedSong:Bool;

    var strumAnims:Array<String>;
}





class ServerListSubstate extends MusicBeatSubstate
{
    static function getTime()
    {
        return Date.now().getUTCMinutes();
    }

    public static final serverPrefix:String = "S"+VoiidMainMenuState.modVersion;

    public static function setupNewClient(id:String, player:Int, userName:String):ClientData
    {
        FlxG.autoPause = false; //make sure it doesnt get desynced

        var data:ClientData = {
            serverID: id,
            playerName: userName,
            playerConnected: true,

            playerLoaded: false,
        
            playerScore: 0,
            playerMisses: 0,
            playerAccuracy: 0,
            playerHealth: 1,
            playerRatingName: '?',
            playerRatingFC: '',
            playerCombo: 0,
            playerDied: false,
        
            song: '',
            diff: '',
            songSpeed: 1.0,

            lastTimestamp: currentTimestamp,
    
            playerFinishedSong: false,
            strumAnims: ['static', 'static', 'static', 'static','static', 'static', 'static', 'static','static', 'static', 'static', 'static'],   
        };
        serverID = id;

        var dataAsString:String = stringifyClientData(data);
        currentPlayer = player;

        FlxGameJolt.setData(serverPrefix+'P'+player+id, dataAsString, false, function(mapa:Map<String,String>)
        {
            createdAClient = true;
        });
        

        return data;
    }

    static function stringToBool(str:String)
    {
        return str == 'true';
    }


    //i would have wanted to end up using proper serialization but it really didnt wanna work so this will have to do
    static function stringifyClientData(data:ClientData)
    {

        var dataAsString = '';

        dataAsString += data.serverID+':';
        dataAsString += data.playerName+':';
        dataAsString += data.playerConnected+':';
        dataAsString += data.playerLoaded+':';

        dataAsString += data.playerScore+':';
        dataAsString += data.playerMisses+':';
        dataAsString += data.playerAccuracy+':';
        dataAsString += data.playerHealth+':';
        dataAsString += data.playerRatingName+':';
        dataAsString += data.playerRatingFC+':';
        dataAsString += data.playerCombo+':';
        dataAsString += data.playerDied+':';

        dataAsString += data.song+':';
        dataAsString += data.diff+':';
        dataAsString += data.songSpeed+':';

        dataAsString += data.lastTimestamp+':';
        dataAsString += data.playerFinishedSong+':';

        for (i in 0...data.strumAnims.length)
        {
            dataAsString += data.strumAnims[i];
            if (i < data.strumAnims.length-1)
                dataAsString += ',';
        }

        return dataAsString;
    }
    public static function parseClientData(d:String):ClientData
    {
        var data = d.split(":");
        var strumAnims = data[17].split(',');
        return {
            serverID: data[0],
            playerName: data[1],
            playerConnected: stringToBool(data[2]),
            playerLoaded: stringToBool(data[3]),
        
            playerScore: Std.parseInt(data[4]),
            playerMisses: Std.parseInt(data[5]),
            playerAccuracy: Std.parseFloat(data[6]),
            playerHealth: Std.parseFloat(data[7]),
            playerRatingName: data[8],
            playerRatingFC: data[9],
            playerCombo: Std.parseInt(data[10]),
            playerDied: stringToBool(data[11]),
        
            song: data[12],
            diff: data[13],
            songSpeed: Std.parseFloat(data[14]),

            lastTimestamp: Std.parseInt(data[15]),
            playerFinishedSong: stringToBool(data[16]),
            strumAnims: strumAnims
        };
    }

    private static var serverPingTimer:FlxTimer = null;

    public static function resetServerPingTimer()
    {
        if (createdAClient)
            updateServer();

        var pingTime:Int = 5;

        serverPingTimer = new FlxTimer().start(pingTime, function(tmr:FlxTimer) //ping every 5 secs
        {
            var clientsConnected = false;
            if (player1Client != null && player2Client != null)
                clientsConnected = player1Client.playerConnected && player2Client.playerConnected;

            updateServerTimestamp();

            if (createdAClient && !clientsConnected)
                updateServer();
            else 
                serverPingTimer = null;
        }, 0); //0 means loop forever
    }
    public static var player1Client:ClientData = null;
    public static var player2Client:ClientData = null;
    public static var clients:Array<ClientData> = [player2Client, player1Client];
    public static var currentPlayer:Int = 2;
    public static var createdAClient:Bool = false;
    public static var waitingForSync:Bool = false;
    public static var serverID:String = '';


    public static var currentTimestamp:Int = 0;
    public static function updateServerTimestamp()
    {
        FlxGameJolt.getTime(function(mapThing:Map<String,String>)
        {
            //trace(mapThing);
            if (mapThing != null)
            {
                if (mapThing.get('success') == 'true' && mapThing.exists('timestamp'))
                {
                    currentTimestamp = Std.parseInt(mapThing.get("timestamp")); 
                    //trace(currentTimestamp);
                }
            }
        });
    }
    public static function checkTimestampsForDisconnect(stamp1:Int, stamp2:Int)
    {
        return Math.abs(stamp1-stamp2) > 20;
    }

    public static function updateServer()
    {
        if (!GameJoltStuff.loggedIn && !GameJoltStuff.connectedToGame)
            return;

        clients = [player2Client, player1Client];
        //get opponent client data
        var opponentPlayer = 1;
        if (currentPlayer == 1)
            opponentPlayer = 0;


        FlxGameJolt.getTime(function(mapThing:Map<String,String>)
        {
            if (mapThing != null)
            {
                if (mapThing.get('success') == 'true' && mapThing.exists('timestamp'))
                {
                    currentTimestamp = Std.parseInt(mapThing.get("timestamp")); //no more stupid date.now
                    clients[currentPlayer].lastTimestamp = currentTimestamp;
                }
            }
        });


        //update ping time
        //clients[currentPlayer].lastPingSeconds = Date.now().getUTCSeconds();
        //clients[currentPlayer].lastPingMinutes = Date.now().getUTCMinutes();
        //clients[currentPlayer].lastPingHours = Date.now().getUTCHours(); //need hours to check for dead servers

        //get opponent data
        FlxGameJolt.fetchData(serverPrefix+'P'+opponentPlayer+serverID, false, function(mapThing:Map<String,String>)
        {
            if (mapThing != null)
            {
                if (mapThing.get('success') == 'true' && mapThing.exists('data'))
                {
                    var asString = mapThing.get('data');

                    var clientData = parseClientData(asString);
                    //trace(clientData);
                    if (currentPlayer == 1)
                        player2Client = clientData;
                    else 
                        player1Client = clientData;

                }
            }
            //send your client data to the server
            var dataAsString = stringifyClientData(clients[currentPlayer]);
            FlxGameJolt.setData(serverPrefix+'P'+currentPlayer+serverID, dataAsString, false, function(mapa:Map<String,String>)
            {
                if (player1Client != null && player2Client != null)
                    if (player1Client.playerConnected && player2Client.playerConnected)
                        if (checkTimestampsForDisconnect(player1Client.lastTimestamp, player2Client.lastTimestamp) && !waitingForSync) //if you go 20 secs without a ping
                            endServer(); //disconnect
                        else 
                            updateServer(); //constantly ping
            });
        });

        clients = [player2Client, player1Client];


        
    }


    public static function endServer()
    {
        if (!GameJoltStuff.loggedIn && !GameJoltStuff.connectedToGame)
            return;

        player1Client = null;
        player2Client = null;
        createdAClient = false;
        waitingForSync = false;
        PlayState.inMultiplayerSession = false;
        FlxGameJolt.removeData(serverPrefix+'P1'+serverID, false, function(mapa:Map<String,String>)
        {
            FlxGameJolt.removeData(serverPrefix+'P0'+serverID, false, function(mapa:Map<String,String>)
            {
    
            });
        });

 
    }



    public var serverIDInput:FlxInputText;
    var statusText:FlxText;
    var createServerButton:SimpleButton;
    var joinServerButton:SimpleButton;

	override public function create()
    {
        super.create();

        updateServerTimestamp();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

        var chars:FlxSprite = new FlxSprite().loadGraphic(Paths.image("online/MATT_BF"));
        chars.setGraphicSize(1280);
        chars.updateHitbox();
        chars.screenCenter();
        add(chars);

        FlxG.mouse.visible = true;

        var inputBG = new FlxSprite(Math.floor(FlxG.width*0.5),240).loadGraphic(Paths.image("online/Bar"));
        inputBG.antialiasing = true;
        inputBG.screenCenter(X);
        add(inputBG);

        serverIDInput = new FlxInputText(Math.floor(FlxG.width*0.5),250, Math.floor(FlxG.width*0.4), '', 32, FlxColor.BLACK, FlxColor.TRANSPARENT);
        serverIDInput.filterMode = FlxInputText.ONLY_NUMERIC;
        serverIDInput.screenCenter(X);
        add(serverIDInput);

        #if mobile //idk if this works but ye
        serverIDInput.textField.needsSoftKeyboard = true;
        #end
        

        var shit = new FlxText(5, FlxG.height+12, 0, 'How to Play:\nType in an ID into the search bar and\npress Connect to create/join a server.\n\nOpen the server list to view joinable servers,\nclick one and press connect to join.\n\n\nIf you encounter issues trying to connect,\ndisconnect and back out,\nthen try again.\n', 48);
        shit.setFormat(Paths.font("Contb___.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        shit.y -= shit.height;
        add(shit);


        var the = new FlxSprite(0, serverIDInput.y-serverIDInput.height-10).loadGraphic(Paths.image("online/Server_ID"));
        the.screenCenter();
        the.antialiasing = true;
        add(the);

        var dog = new FlxText(50, 50, Math.floor(FlxG.width*0.4), 'Player Stats:', 48);
        dog.setFormat(Paths.font("Contb___.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(dog);
        if (FlxG.save.data.wins == null)
			FlxG.save.data.wins = 0;
		if (FlxG.save.data.winStreak == null)
			FlxG.save.data.winStreak = 0;
		if (FlxG.save.data.matchesPlayed == null)
			FlxG.save.data.matchesPlayed = 0;
        dog.text += '\nTotal matches played: '+FlxG.save.data.matchesPlayed;
        dog.text += '\nTotal wins: '+FlxG.save.data.wins;
        dog.text += '\nCurrent winstreak: '+FlxG.save.data.winStreak;
        dog.text += '\n';


        statusText = new FlxText(serverIDInput.x, serverIDInput.y+serverIDInput.height+10, Math.floor(FlxG.width*0.4), '', 32);
        statusText.setFormat(Paths.font("Contb___.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        statusText.screenCenter(X);
        add(statusText);

        var getServerName = function(player:String)
        {
            trace(serverPrefix);
            return serverPrefix+player+serverIDInput.text.replace(" ", "-").toLowerCase(); //make sure its lowercase and has no spaces
        };

        var createServer = function()
        {
            if (createdAClient)
                return;
            if (GameJoltStuff.loggedIn && GameJoltStuff.connectedToGame)
            {
                statusText.text = 'Creating Server...';
                FlxGameJolt.fetchData(getServerName("P1"), false, function(mapThing:Map<String,String>)
                {
                    if (mapThing != null)
                    {
                        //trace(mapThing);
        
                        if (mapThing.get('success') == 'true' && mapThing.exists('data'))
                        {
                            var asString = mapThing.get('data');
                            var client = parseClientData(asString);
                            if (checkTimestampsForDisconnect(client.lastTimestamp, currentTimestamp)) //in case theres an old disconnected server
                            {
                                trace('resetting old server');
                                //clear old data first to prevent random time outs
                                FlxGameJolt.removeData(getServerName("P1"), false, function(mapa:Map<String,String>)
                                {
                                    FlxGameJolt.removeData(getServerName("P0"), false, function(mapa:Map<String,String>)
                                    {
                                        trace('reset old server');
                                        GameJoltStuff.ServerListSubstate.player1Client = GameJoltStuff.ServerListSubstate.setupNewClient(serverIDInput.text.replace(" ", "-").toLowerCase(), 1, FlxG.save.data.gameJoltUserName);			
                                        GameJoltStuff.ServerListSubstate.resetServerPingTimer();
                                        waitingForSync = true;
                                        statusText.text = 'Server created.\nWaiting for player 2 to join...';   
                                    });
                                });
 
                            }
                            else 
                            {
                                //server already exists!!
                                statusText.text = 'Server already exists!!!';
                            }
                        }
                        else //server doesnt exist so make a new one
                        {
                            GameJoltStuff.ServerListSubstate.player1Client = GameJoltStuff.ServerListSubstate.setupNewClient(serverIDInput.text.replace(" ", "-").toLowerCase(), 1, FlxG.save.data.gameJoltUserName);			
                            GameJoltStuff.ServerListSubstate.resetServerPingTimer();
                            waitingForSync = true;
                            statusText.text = 'Server created.\nWaiting for player 2 to join...';
                        }
                    }
                });
            }
        }

        var joinServer = function()
        {
            if (createdAClient)
                return;
            if (GameJoltStuff.loggedIn && GameJoltStuff.connectedToGame)
            {
                //check if host server exists
                statusText.text = 'Joining server...';
                FlxGameJolt.fetchData(getServerName("P1"), false, function(mapThing:Map<String,String>)
                {
                    if (mapThing != null)
                    {    
                        if (mapThing.get('success') == 'true' && mapThing.exists('data'))
                        {
                            FlxGameJolt.fetchData(getServerName("P0"), false, function(mapThing2:Map<String,String>)
                            {
                                if (mapThing2 != null)
                                {                
                                    if (mapThing2.get('success') == 'true' && mapThing2.exists('data'))
                                    {
                                        //someone is already in the server!!!
                                        

                                        var asString = mapThing2.get('data');
                                        var client = parseClientData(asString);
                                        if (checkTimestampsForDisconnect(client.lastTimestamp, currentTimestamp)) //in case theres an old disconnected server
                                        {
                                            //trace('trying to join an old disconnect server lol');
                                            //GameJoltStuff.ServerListSubstate.player1Client = GameJoltStuff.ServerListSubstate.setupNewClient(serverIDInput.text, 1, FlxG.save.data.gameJoltUserName);			
                                            //GameJoltStuff.ServerListSubstate.resetServerPingTimer();
                                            statusText.text = 'Server does not exist!!!'; //it does exist its just disconnected
                                        }
                                        else
                                        {
                                            statusText.text = 'Server is full.';
                                        }
                                    }
                                    else 
                                    {
                                        GameJoltStuff.ServerListSubstate.player2Client = GameJoltStuff.ServerListSubstate.setupNewClient(serverIDInput.text.replace(" ", "-").toLowerCase(), 0, FlxG.save.data.gameJoltUserName);			
                                        GameJoltStuff.ServerListSubstate.resetServerPingTimer();
                                        waitingForSync = true;
                                        statusText.text = 'Joined Server.\nWaiting for sync...';
                                    }
                                }
                            });
                        }
                        else 
                        {
                            statusText.text = 'Server does not exist!!!';
                        }
                    }
                });
            }
        }

        var disconnect = function()
        {
            if (createdAClient)
            {
                GameJoltStuff.ServerListSubstate.endServer();
                statusText.text = 'Disconnected From Server';
            }
            
        }

        createServerButton = new SimpleButton(Math.floor(FlxG.width*0.25), 400, function()
        {
            if (createdAClient)
                return;
            statusText.text = 'Checking Status...';
            FlxGameJolt.fetchData(getServerName("P1"), false, function(mapThing:Map<String,String>)
            {
                if (mapThing != null)
                {    
                    if (mapThing.get('success') == 'true' && mapThing.exists('data'))
                    {
                        var asString = mapThing.get('data');
                        var client = parseClientData(asString);
                        if (checkTimestampsForDisconnect(client.lastTimestamp, currentTimestamp))
                        {
                            //the server is disconnected so create a server over it
                            createServer();
                        }
                        else 
                        {
                            //server exists and is active so try joining
                            joinServer();
                        }
                    }
                    else 
                        createServer();
                }
            });
        });
        createServerButton.loadGraphic(Paths.image("online/Connect"));
        add(createServerButton);

        /*joinServerButton = new SimpleButton(Math.floor(FlxG.width*0.75), 400, function()
        {
            joinServer();
        });
        joinServerButton.loadGraphic(Paths.image("online/Connect"));
        joinServerButton.x -= joinServerButton.width;
        add(joinServerButton);*/


        var disconnectButton = new SimpleButton(Math.floor(FlxG.width*0.75), 400, function()
        {
            disconnect();                
        });
        disconnectButton.loadGraphic(Paths.image("online/Disconnect"));
        disconnectButton.x -= disconnectButton.width;
        add(disconnectButton);

        //var create = new SimpleButton(400, 600, function()
       // {
        //    createServer();
        //});
        //create.makeGraphic(100,100);
        //add(create);


        var viewServers = new SimpleButton(0, 500, function()
        {
            if (!createdAClient)
            {
                persistentUpdate = false;
                openSubState(new ServerViewSubstate(this));
            }
        });
        viewServers.loadGraphic(Paths.image("online/View_Server_List"));
        viewServers.screenCenter(X);
        add(viewServers);


    }

	override function update(elapsed:Float)
    {
        if (serverIDInput.hasFocus) //stop 0 from muting lol
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
        if (controls.BACK && !serverIDInput.hasFocus && !createdAClient)
        {
            //FlxG.mouse.visible = false;
            FlxG.state.persistentUpdate = true;
            close();
        }

        if (FlxG.keys.justPressed.ONE)
        {

        }

        if (!GameJoltStuff.loggedIn && !GameJoltStuff.connectedToGame)
            statusText.text = 'Not logged in.';

        var clientsExist = (GameJoltStuff.ServerListSubstate.player1Client != null && GameJoltStuff.ServerListSubstate.player2Client != null);

        if (clientsExist)
        {
            
            if (checkTimestampsForDisconnect(
                GameJoltStuff.ServerListSubstate.player1Client.lastTimestamp, 
                GameJoltStuff.ServerListSubstate.player2Client.lastTimestamp) 
                && player1Client.playerConnected && player2Client.playerConnected)
            {
                
                //dont bother disconnecting, just wait for a sync
                //trace('clients are desynced, waiting for sync');
                //trace(player1Client);
                //trace(player2Client);
                //GameJoltStuff.ServerListSubstate.endServer();
                //statusText.text = 'Server timed out.';
            }
            else 
            {
                if (player1Client.playerConnected && player2Client.playerConnected)
                {
                    waitingForSync = false;
                    var opponentPlayer = 1;
                    if (GameJoltStuff.ServerListSubstate.currentPlayer == 1)
                        opponentPlayer = 0;
                    var opponentClient = GameJoltStuff.ServerListSubstate.clients[opponentPlayer];

                    Main.popupManager.addPopup(new MessagePopup(5, 300, 100, "Connected to Server " + player1Client.serverID + "\nWaiting for " + player1Client.playerName + " to pick a song"));
                    //FlxG.mouse.visible = false;
                    //close();
                    FlxG.switchState(new FreeplayState());
                }
            }

                
        }

        super.update(elapsed);
    }

    public static var activeServers:Array<String> = [];
    public static var activeServersPlayerName:Array<String> = [];
    public static function getActiveServers(serversToCheck:Array<String>, callBack:Void->Void)
    {
        activeServers = [];
        activeServersPlayerName = [];

        trace(serversToCheck);
        var finish = function()
        {
            trace(activeServers);
            if (callBack != null)
                callBack();
        }

        var func:Void->Void;
        func = function()
        {
            if (serversToCheck.length <= 0)
            {
                finish(); //gone through each server
                return;
            }

            var cont = function()
            {
                if (serversToCheck.length > 0) 
                {
                    serversToCheck.remove(serversToCheck[0]); //remove and redo func until all are checked
                    func();
                }
                else 
                {
                    finish();
                }
            }
                
            FlxGameJolt.fetchData(serversToCheck[0], false, function(mapThingP1:Map<String,String>)
            {
                if (mapThingP1 != null)
                {                
                    if (mapThingP1.get('success') == 'true' && mapThingP1.exists('data'))
                    {
                        FlxGameJolt.fetchData(serversToCheck[0].replace(serverPrefix+"P1", serverPrefix+"P0"), false, function(mapThingP2:Map<String,String>)
                        {
                            var player2Exists:Bool = false;
                            if (mapThingP2 != null)
                            {
                                if (mapThingP2.get('success') == 'true' && mapThingP2.exists('data'))
                                {
                                    var asString = mapThingP2.get('data');
                                    var client = parseClientData(asString);
                                    if (checkTimestampsForDisconnect(client.lastTimestamp, currentTimestamp)) //in case theres an old disconnected server
                                    {
                                        
                                    }
                                    else 
                                    {
                                        player2Exists = true; //probably already connected
                                    }
                                }
                            }

                            var asString = mapThingP1.get('data');
                            var client = parseClientData(asString);
                            if (checkTimestampsForDisconnect(client.lastTimestamp, currentTimestamp) || player2Exists) //in case theres an old disconnected server
                            {
                                trace(serversToCheck[0] + " not active");
                                FlxGameJolt.removeData(serversToCheck[0], false, function(mapThing:Map<String,String>)
                                {
                                    trace("removed " + serversToCheck[0]); //remove dead servers????, if it ends up not being dead the person connected should have it remade on the next ping i guess?????
                                    cont();
                                });
                            }
                            else 
                            {
                                activeServers.push(serversToCheck[0]);
                                activeServersPlayerName.push(client.playerName);
                                trace(serversToCheck[0] + " is active");
                                cont();
                            }

                            
                        });
                    }
                    else 
                        cont();
                }
                else 
                    cont();
            });
        }
        func();
    }
}

class SimpleButton extends FlxSprite
{
    var buttonFunc:Void->Void;
    public function new(X:Float,Y:Float, func:Void->Void)
    {
        super(X,Y);
        buttonFunc = func;
        antialiasing = true;
    }
    override public function update(elapsed:Float)
    {
        if (doesOverlap() && isJustPressed())
        {
            if (buttonFunc != null)
                buttonFunc();
        }
    }

    function doesOverlap() : Bool
    {
        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.overlaps(this))
                return true;
        }
        #end
        return FlxG.mouse.overlaps(this);
    }
    function isJustPressed() : Bool
    {
        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed && touch.overlaps(this))
                return true;
        }
        #end
        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
        if (gamepad != null)
        {
            if (gamepad.anyJustPressed([FlxGamepadInputID.A, FlxGamepadInputID.START]))
            {
                return true;
            }
        }
        return FlxG.mouse.justPressed;
    }
}

class ServerViewSubstate extends MusicBeatSubstate
{

    var instance:ServerListSubstate;
    public function new(instance:ServerListSubstate)
    {
        super();
        this.instance = instance;
    }

    var list:Array<FlxText> = [];


    var infoText:FlxText;
    var curScroll:Float = 0;
    var scrollBar:ScrollBar;

    override public function create()
    {
        super.create();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

        ServerListSubstate.updateServerTimestamp();

        var text = new FlxText(0, 10, 0, "Server List", 48);
        text.setFormat(Paths.font("Contb___.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.screenCenter(X);
        add(text);

        infoText = new FlxText(0, 50, FlxG.width, "", 48);
        infoText.setFormat(Paths.font("Contb___.ttf"), 48, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(infoText);

        refreshServers();
    }

    function loadText()
    {
        trace(ServerListSubstate.activeServers);
        trace(ServerListSubstate.activeServersPlayerName);
        for (i in 0...ServerListSubstate.activeServers.length)
        {
            var text = new FlxText(0, 150 + (40*i), 0, ServerListSubstate.activeServers[i].replace(ServerListSubstate.serverPrefix+"P1", "") + " - " + ServerListSubstate.activeServersPlayerName[i], 48);
            text.setFormat(Paths.font("Contb___.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.screenCenter(X);
            add(text);
            list.push(text);
        }
        if (ServerListSubstate.activeServers.length <= 0)
        {
            infoText.text = "No Servers Found";
        }
        else 
        {
            infoText.text = "";
            if (list.length*40 > 400)
            {
                scrollBar = new ScrollBar(1200, 50, 20, 620, this, "curScroll", (list.length*40)-400);
                add(scrollBar);
            }

        }
            
    }

    function refreshServers()
    {
        for (l in list)
            remove(l);
        remove(scrollBar);

        infoText.text = "Refreshing Servers...";

        FlxGameJolt.getAllKeys(false, ServerListSubstate.serverPrefix+"P1", function(map:Map<String,String>)
        {
            if (map.get('success') == 'true')
            {
                var serversToCheck:Array<String> = [];
                for (key => val in map)
                {
                    if (key != "success" && key != "data" && key != "message")
                        serversToCheck.push(val);
                }
                ServerListSubstate.getActiveServers(serversToCheck, loadText);
            }
        });
    }

    override public function update(elapsed:Float)
    {
        

        if (controls.BACK)
        {
            //FlxG.mouse.visible = false;
            instance.persistentUpdate = true;
            close();
        }

        curScroll -= FlxG.mouse.wheel*50*elapsed*480;
        if (controls.DOWN)
            curScroll += 800*elapsed;
        if (controls.UP)
            curScroll -= 800*elapsed;
        
        var listHeight:Float = (list.length*40)-400;
        if (listHeight < 0)
            listHeight = 0;

        curScroll = FlxMath.bound(curScroll, 0, listHeight); //bound

        super.update(elapsed);

        for (i in 0...list.length)
        {
            list[i].y = FlxMath.lerp(list[i].y,(150 + (40*i))-curScroll, elapsed*10);

            if (FlxG.mouse.overlaps(list[i]))
            {
                list[i].color = 0xFF8C00FF;
                if (FlxG.mouse.justPressed)
                {
                    instance.serverIDInput.text = ServerListSubstate.activeServers[i].replace(ServerListSubstate.serverPrefix+"P1", "");
                    instance.persistentUpdate = true;
                    close();
                }
            }
            else 
            {
                list[i].color = FlxColor.WHITE;
            }
        }
    }
}
