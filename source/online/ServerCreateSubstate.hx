package online;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import states.FreeplayState;
import Popup.MessagePopup;
import flixel.addons.api.FlxGameJolt;
import flixel.util.FlxColor;
import flixel.FlxG;
import ui.Checkbox;
import flixel.text.FlxText;
import flixel.addons.ui.FlxInputText;
import flixel.FlxSprite;
import substates.MusicBeatSubstate;

using StringTools;

class ServerCreateSubstate extends MusicBeatSubstate
{
    public var serverIDInput:FlxInputText;
    var statusText:FlxText;
    var createServerButton:SimpleButton;
    var joinServerButton:SimpleButton;

    var privateCheckbox:Checkbox;
    var privateText:FlxText;

    var currentWinCondition:Int = 0;
    var winCText:FlxText;
    var changeWinC:SimpleButton;
    var changeWinCL:SimpleButton;
    final winConditionList:Array<String> = ["Score", "Accuracy", "Misses"];

	override public function create()
    {
        super.create();

        Multiplayer.updateServerTimestamp();

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

        serverIDInput.maxLength = 10;

        #if mobile //idk if this works but ye
        serverIDInput.textField.needsSoftKeyboard = true;
        #end
        

        var shit = new FlxText(5, FlxG.height+12, 0, 'How to Play:\nType in an ID into the search bar and\npress Connect to create/join a server.\n\nOpen the server list to view joinable servers,\nclick one and press connect to join.\n\n\nIf you encounter issues trying to connect,\ndisconnect and back out,\nthen try again.\n', 48);
        shit.setFormat(Paths.font("Contb___.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        shit.y -= shit.height;
        add(shit);

        

        privateText = new FlxText(FlxG.width, FlxG.height, 0, "Private:");
        privateText.setFormat(Paths.font("Contb___.ttf"), 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(privateText);
        privateCheckbox = new Checkbox(null);
        privateText.x -= privateText.width+privateCheckbox.width+10;
        privateCheckbox.x = privateText.x+privateText.width+5;
        privateCheckbox.y = FlxG.height-(privateCheckbox.height+5);
        privateText.y = privateCheckbox.y + (privateCheckbox.height*0.5)-(privateText.height*0.5);
        add(privateCheckbox);


        winCText = new FlxText(FlxG.width, FlxG.height, 0, "Win Condition: " + winConditionList[currentWinCondition]);
        winCText.setFormat(Paths.font("Contb___.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(winCText);
        winCText.y = privateText.y - (privateText.height+5);

        var updatePos = function()
        {
            if (currentWinCondition < 0)
                currentWinCondition = winConditionList.length-1;
            else if (currentWinCondition > winConditionList.length-1)
                currentWinCondition = 0;

            winCText.text = "Win Condition: " + winConditionList[currentWinCondition];
            winCText.x = changeWinC.x-(winCText.width+5);
            changeWinCL.x = winCText.x-(changeWinCL.width+5);
        }

        changeWinC = new SimpleButton(0, 0, function()
        {
            currentWinCondition++;
            updatePos();
        });
        changeWinC.flipX = true;
        changeWinC.loadGraphic(Paths.image("freeplay/white_arrow"));
        winCText.x -= winCText.width+changeWinC.width+10;
        changeWinC.x = winCText.x+winCText.width+5;

        changeWinC.y = privateCheckbox.y-(changeWinC.height+5);
        winCText.y = changeWinC.y + (changeWinC.height*0.5)-(winCText.height*0.5);
        add(changeWinC);

        
        changeWinCL = new SimpleButton(0, 0, function()
        {
            currentWinCondition--;
            updatePos();
        });
        changeWinCL.y = changeWinC.y;
        changeWinCL.loadGraphic(Paths.image("freeplay/white_arrow"));
        add(changeWinCL);

        updatePos();


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
            //trace(Multiplayer.serverPrefix);
            return Multiplayer.serverPrefix+player+serverIDInput.text.replace(" ", "-").toLowerCase(); //make sure its lowercase and has no spaces
        };

        var createServer = function()
        {
            if (Multiplayer.createdAClient)
                return;
            if (GameJolt.connected)
            {
                statusText.text = 'Creating Server...';
                FlxGameJolt.fetchData(getServerName("P0"), false, function(mapThing:Map<String,String>)
                {
                    if (mapThing != null)
                    {
                        //trace(mapThing);
        
                        if (mapThing.get('success') == 'true' && mapThing.exists('data'))
                        {
                            var asString = mapThing.get('data');
                            var client = Multiplayer.parseClientData(asString);
                            if (Multiplayer.checkTimestampsForDisconnect(client.lastTimestamp, Multiplayer.currentTimestamp)) //in case theres an old disconnected server
                            {
                                trace('resetting old server');
                                //clear old data first to prevent random time outs
                                FlxGameJolt.removeData(getServerName("P0"), false, function(mapa:Map<String,String>)
                                {
                                    FlxGameJolt.removeData(getServerName("P1"), false, function(mapa:Map<String,String>)
                                    {
                                        trace('reset old server');
                                        Multiplayer.createServer(serverIDInput.text.replace(" ", "-").toLowerCase(), privateCheckbox.checked);
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
                            Multiplayer.createServer(serverIDInput.text.replace(" ", "-").toLowerCase(), privateCheckbox.checked);
                            statusText.text = 'Server created.\nWaiting for player 2 to join...';
                        }
                    }
                });
            }
        }

        var joinServer = function()
        {
            if (Multiplayer.createdAClient)
                return;
            if (GameJolt.connected)
            {
                //check if host server exists
                statusText.text = 'Joining server...';
                FlxGameJolt.fetchData(getServerName("P0"), false, function(mapThing:Map<String,String>)
                {
                    if (mapThing != null)
                    {    
                        if (mapThing.get('success') == 'true' && mapThing.exists('data'))
                        {
                            FlxGameJolt.fetchData(getServerName("P1"), false, function(mapThing2:Map<String,String>)
                            {
                                if (mapThing2 != null)
                                {                
                                    if (mapThing2.get('success') == 'true' && mapThing2.exists('data'))
                                    {
                                        //someone is already in the server!!!
                                        
                                        var asString = mapThing2.get('data');
                                        var client = Multiplayer.parseClientData(asString);
                                        if (Multiplayer.checkTimestampsForDisconnect(client.lastTimestamp, Multiplayer.currentTimestamp)) //in case theres an old disconnected server
                                        {
                                            statusText.text = 'Server does not exist!!!'; //it does exist its just disconnected
                                        }
                                        else
                                        {
                                            statusText.text = 'Server is full.';
                                        }
                                    }
                                    else 
                                    {
                                        Multiplayer.joinServer(serverIDInput.text.replace(" ", "-").toLowerCase());
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
            if (Multiplayer.createdAClient)
            {
                Multiplayer.endServer();
                statusText.text = 'Disconnected From Server';
            }
            
        }

        createServerButton = new SimpleButton(Math.floor(FlxG.width*0.25), 400, function()
        {
            if (Multiplayer.createdAClient)
                return;
            statusText.text = 'Checking Status...';
            FlxGameJolt.fetchData(getServerName("P0"), false, function(mapThing:Map<String,String>)
            {
                if (mapThing != null)
                {    
                    if (mapThing.get('success') == 'true' && mapThing.exists('data'))
                    {
                        var asString = mapThing.get('data');
                        var client = Multiplayer.parseClientData(asString);
                        if (Multiplayer.checkTimestampsForDisconnect(client.lastTimestamp, Multiplayer.currentTimestamp))
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
            if (!Multiplayer.createdAClient)
            {
                persistentUpdate = false;
                openSubState(new ServerListViewSubstate(this));
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
        if (controls.BACK && !serverIDInput.hasFocus && !Multiplayer.createdAClient)
        {
            //FlxG.mouse.visible = false;
            FlxG.state.persistentUpdate = true;
            close();
        }

        if (FlxG.keys.justPressed.ONE)
        {

        }

        if (!GameJolt.connected)
            statusText.text = 'Not logged in.';

        var clientsExist = (Multiplayer.player1Client != null &&Multiplayer.player2Client != null);

        if (FlxG.mouse.justPressed)
        {
            if (FlxG.mouse.overlaps(privateCheckbox))
                privateCheckbox.checked = !privateCheckbox.checked;
        }

        if (Multiplayer.player1Client != null && Multiplayer.currentPlayer == 0)
        {
            Multiplayer.player1Client.privateServer = privateCheckbox.checked;
            Multiplayer.player1Client.winCondition = winConditionList[currentWinCondition];
        }

        if (clientsExist)
        {
            
            if (Multiplayer.checkTimestampsForDisconnect(
                Multiplayer.player1Client.lastTimestamp, 
                Multiplayer.player2Client.lastTimestamp) 
                && Multiplayer.player1Client.playerConnected && Multiplayer.player2Client.playerConnected)
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
                if (Multiplayer.player1Client.playerConnected && Multiplayer.player2Client.playerConnected)
                {
                    Multiplayer.waitingForSync = false;
                    Main.popupManager.addPopup(new MessagePopup(5, 300, 100, "Connected to Server " + Multiplayer.player1Client.serverID + "\nWaiting for " + Multiplayer.player1Client.playerName + " to pick a song"));
                    //FlxG.mouse.visible = false;
                    //close();
                    FlxG.switchState(new FreeplayState());
                }
            }

                
        }

        super.update(elapsed);
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