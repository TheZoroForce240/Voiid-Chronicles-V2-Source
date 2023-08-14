package online;

import flixel.math.FlxMath;
import flixel.addons.api.FlxGameJolt;
import flixel.FlxG;

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

class Leaderboards
{
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
        if (GameJolt.connected)
        {
            FlxGameJolt.fetchData(saveStr, false, function(mapThing:Map<String,String>)
            {
                if (mapThing != null)
                {
                    if (mapThing.get('success') == 'true' && mapThing.exists('data'))
                    {
                        var dataString = mapThing.get('data');

                        var scoreList:SongLeaderboard = parseLeaderboardString(dataString);

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

                        var outputString:String = stringifyLeaderboard(scoreList);
                        //trace(scoreList);
                        //trace(outputString);
                        if (!alreadyishigherscore)
                        {
                            FlxGameJolt.setData(saveStr, outputString, false, function(mapThing:Map<String,String>)
                            {
                                //trace(mapThing);
                            }, "addHighscoreSet");
                        }

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

                                var outputString:String = stringifyLeaderboard(scoreList);
                                //trace(scoreList);
                                //trace(outputString);
                                FlxGameJolt.setData(saveStr, outputString, false, function(mapThing:Map<String,String>)
                                {
                                    //trace(mapThing);
                                }, "addHighscoreSet");
                            }
                        }
                    }
                }
            }, "addHighscoreGet");
        }
    }

    //haxe serializer being dumb so yea
    public static function stringifyLeaderboard(scoreList:SongLeaderboard)
    {
        var str:String = "";
        for (i in 0...scoreList.scores.length)
        {   
            var score = scoreList.scores[i];
            score.name = score.name.replace(";", "-"); //just in case i guess
            score.name = score.name.replace(":", "-");
            score.name = score.name.replace(" ", "-");
            str += score.name;
            str += ":";
            str += score.acc;
            str += ":";
            str += score.score;
            str += ":";
            str += score.misses;
            if (i < scoreList.scores.length-1)
                str += ";";
        }
        return str;
    }
    public static function parseLeaderboardString(str:String)
    {
        var scoreList:SongLeaderboard = {song: "", diff: "", scores: []};
        var scores = str.split(";");
        for (scoreStr in scores)
        {
            var score = convertToLeaderboardScore(scoreStr);
            scoreList.scores.push(score);
        }
        return scoreList;
    }

    public static function getLeaderboard(songname:String, songdiff:String, speed:Float, opponent:Bool, callBack:String->Void)
    {
        var saveStr:String = getHighscoreSaveString(songname, songdiff, speed, opponent);

        //trace(saveStr);

        if (GameJolt.connected)
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
            }, "getHighscore");
        }
        else 
        {
            callBack('notLoggedIn');
        }
        }
}