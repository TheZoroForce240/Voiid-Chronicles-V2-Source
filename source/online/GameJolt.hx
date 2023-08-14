package online;

import flixel.addons.api.FlxGameJolt;
import flixel.util.FlxTimer;
import flixel.FlxG;
import Popup.MessagePopup;
import haxe.io.Bytes;

class GameJolt
{
    public static final gameID:Int = 810060;

    public static var fetchingData:Bool = false;

    public static var connectedToGame:Bool = false;
    public static var loggedIn:Bool = false;

    public static var connected(get, null):Bool;
    static function get_connected():Bool {
		return connectedToGame && loggedIn;
	}

    public static function initStuffs():String
    {
        if (FlxG.save.data.gameJoltUserName == null)
            return 'no login found';
        if (FlxG.save.data.gameJoltUserToken == null)
            return 'no login found';

        var privateKey:String = "";

        if (privateKey == '')
        {
            //MainMenuState.makePopupThing('GameJolt Disabled, no private key found.');
            Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "GameJolt Disabled, no private key found."));
            return 'no private key';
        }

        var gotResponse:Bool = false;
        new FlxTimer().start(10, function(timer:FlxTimer)
        {
            if (connected)
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

    public static function test()
    {

        //FlxGameJolt.fetchData(getHighscoreSaveString("boxing-match", "voiid", 1, false), false, function(map:Map<String,String>) {trace(map);}, "1");
        //FlxGameJolt.removeData(getHighscoreSaveString("boxing-match", "voiid", 1, false), false, null, "1");
    }
    
    private static var pingTimer:FlxTimer = null;

    public static function setupSession() //call after login
    {
        FlxGameJolt.openSession(function(mapThing:Map<String,String>)
        {
            test();
            trace('started session');
            resetPingTimer();
        });
    }
    public static function resetPingTimer()
    {
        ping();
        pingTimer = new FlxTimer().start(30, function(tmr:FlxTimer) //ping every 30 secs
        {
            var doPing = true;
            if (doPing)
                ping(); 
        }, 0); //0 means loop forever
    }
    public static function ping()
    {
        FlxGameJolt.pingSession(true, function(mapThing:Map<String,String>){
            if (mapThing.get('success') != null && mapThing.get('success') == 'false') //if theres an error message then reset session, probably if you were afk or something
            {                                    //not getting any traces that say it resets but it seems to work on the next ping???
                setupSession();
            }
        }); 
    }

    public static function syncAchievements()
    {
        //rewrite this later
        
    }
    

    public static function unlockAchievement(id:Int)
    {
        if (connected)
        {
            FlxGameJolt.addTrophy(id);
        }
    }

    public static function checkAchievement(id:Int, ?func:Map<String,String>->Void)
    {
        if (connected)
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
        if (connected)
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