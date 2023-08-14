package online;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import states.VoiidAwardsState.ScrollBar;
import flixel.text.FlxText;
import substates.MusicBeatSubstate;


class LeaderboardSubstate extends MusicBeatSubstate
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
        Leaderboards.getLeaderboard(songname.toLowerCase(), diff.toLowerCase(), speed, opponent, function(str:String)
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
                    var scoreList:Leaderboards.SongLeaderboard;
                    try
                    {
                        scoreList = Leaderboards.parseLeaderboardString(str); //unseralize from string to type
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