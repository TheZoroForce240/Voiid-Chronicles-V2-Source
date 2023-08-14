package online;

import flixel.math.FlxMath;
import flixel.addons.api.FlxGameJolt;
import states.VoiidAwardsState.ScrollBar;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import substates.MusicBeatSubstate;

using StringTools;

class ServerListViewSubstate extends MusicBeatSubstate
{
    var instance:ServerCreateSubstate;
    public function new(instance:ServerCreateSubstate)
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

        Multiplayer.updateServerTimestamp();

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
        trace(Multiplayer.activeServers);
        //trace(Multiplayer.activeServersClients);
        for (i in 0...Multiplayer.activeServers.length)
        {
            var text = new FlxText(0, 150 + (40*i), 0, Multiplayer.activeServers[i].replace(Multiplayer.serverPrefix+"P0", "") + " - " + Multiplayer.activeServersClients[i].playerName + " - Win Condition: " + Multiplayer.activeServersClients[i].winCondition, 48);
            text.setFormat(Paths.font("Contb___.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.screenCenter(X);
            add(text);
            list.push(text);
        }
        if (Multiplayer.activeServers.length <= 0)
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

        FlxGameJolt.getAllKeys(false, Multiplayer.serverPrefix+"P0", function(map:Map<String,String>)
        {
            if (map.get('success') == 'true')
            {
                var serversToCheck:Array<String> = [];
                for (key => val in map)
                {
                    if (key != "success" && key != "data" && key != "message")
                        serversToCheck.push(val);
                }
                Multiplayer.getActiveServers(serversToCheck, loadText);
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
                    instance.serverIDInput.text = Multiplayer.activeServers[i].replace(Multiplayer.serverPrefix+"P0", "");
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
