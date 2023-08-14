import game.Song.Event;
import states.VoiidMainMenuState;
import states.PlayState;
import game.Note;
using StringTools;
typedef ChartData = 
{
    var song:String;
    var diff:String; 

    var totalNoteCount:Int;
    var playerNoteCount:Int;
    var ?keyCount:Null<Int>;
    var ?playerKeyCount:Null<Int>;
    var ?deathNoteCount:Null<Int>;
    var ?warningNoteCount:Null<Int>;
    var ?dodgeCount:Null<Int>;
}
class ChartChecker
{
    private static final chartList:Array<ChartData> =
    [
        {song: "light-it-up", diff: "voiid", totalNoteCount: 761, playerNoteCount: 380 },
        {song: "ruckus", diff: "voiid", totalNoteCount: 2559, playerNoteCount: 1318},
        {song: "target-practice", diff: "voiid", totalNoteCount: 2061, playerNoteCount: 1040 },

        {song: "burnout", diff: "voiid", totalNoteCount: 1546, playerNoteCount: 732},
        {song: "sporting", diff: "voiid", totalNoteCount: 2392, playerNoteCount: 1210},
        {song: "boxing-match", diff: "voiid", totalNoteCount: 3421, playerNoteCount: 1680, warningNoteCount: 22},

        {song: "flaming-glove", diff: "voiid", totalNoteCount: 1806, playerNoteCount: 862},

        {song: "fisticuffs", diff: "voiid", totalNoteCount: 1535, playerNoteCount: 766, warningNoteCount: 45},
        {song: "blastout", diff: "voiid", totalNoteCount: 2890, playerNoteCount: 1261, warningNoteCount: 39, dodgeCount: 14},
        {song: "immortal", diff: "voiid", totalNoteCount: 2026, playerNoteCount: 1075, warningNoteCount: 103, dodgeCount: 9},
        {song: "king-hit", diff: "voiid", totalNoteCount: 3425, playerNoteCount: 1729, warningNoteCount: 350, playerKeyCount: 5, dodgeCount: 27},
        //{song: "king-hit-wawa", diff: "voiid", totalNoteCount: 3090, playerNoteCount: 1455},
        {song: "tko", diff: "voiid", totalNoteCount: 1498, playerNoteCount: 796, warningNoteCount: 50, dodgeCount: 3},

        {song: "mat", diff: "voiid", totalNoteCount: 1342, playerNoteCount: 699},
        {song: "banger", diff: "voiid", totalNoteCount: 1626, playerNoteCount: 876, warningNoteCount: 318},
        {song: "edgy", diff: "voiid", totalNoteCount: 2432, playerNoteCount: 1632, warningNoteCount: 135},

        {song: "alter-ego", diff: "voiid", totalNoteCount: 1210, playerNoteCount: 562, warningNoteCount: 65},

        {song: "rejected", diff: "voiid", totalNoteCount: 4717, playerNoteCount: 2726, deathNoteCount: 724},

        {song: "sport-swinging", diff: "voiid", totalNoteCount: 1724, playerNoteCount: 919},
        {song: "boxing-gladiators", diff: "voiid", totalNoteCount: 2055, playerNoteCount: 1125},

        {song: "average-voiid-song", diff: "voiid", totalNoteCount: 534, playerNoteCount: 277},
        {song: "voiid-rush", diff: "voiid", totalNoteCount: 1723, playerNoteCount: 847, warningNoteCount: 21},    
    ];

    private static function getChartFromList(song:String, diff:String)
    {
        for (c in chartList)
            if (c.song == song && c.diff == diff)
                return c;
        return null;
    }

    public static function exists(song:String)
    {
        song = song.replace(" ", "-");
        for (c in chartList)
            if (c.song == song)
                return true;
        return false;
    }

    public static function getTotalNotes(notes:Array<Note>, mustPress:Bool)
    {
        var c:Int = 0;
        for (n in notes)
        {
            if (!n.isSustainNote)
            {
                if (n.mustPress == mustPress)
                    c++;
                if (n.arrow_Type == 'REJECTED_NOTES' || n.arrow_Type == 'death' || n.arrow_Type == 'hurt')
                    c--;
            }

        }
        return c;
    }

    public static function checkEvents(song:String, diff:String, events:Array<Array<Dynamic>>)
    {
        song = song.replace(" ", "-");
        diff = diff.replace(" ", "-");
        var chartData = getChartFromList(song, diff);
        var dodgeCount = 0;

        for (event in events)
        {
            if (event[0] == "punch" || event[0] == "slash")
                dodgeCount++;
        }
        if (VoiidMainMenuState.devBuild)
            trace(dodgeCount);
        if (chartData != null)
        {
            if (chartData.dodgeCount != null)
                if (chartData.dodgeCount != dodgeCount)
                    return false;
            return true;
        }

        return false;
    }

    public static function checkChart(song:String, diff:String, notes:Array<Note>) : Bool
    {
        song = song.replace(" ", "-");
        diff = diff.replace(" ", "-");
        var chartData = getChartFromList(song, diff);
        var noteCount = notes.length;
        var playerNoteCount = 0;
        var deathNoteCount = 0;
        var punchCount = 0;
        for (n in notes)
        {
            if (n.mustPress)
                playerNoteCount++;
            if (n.arrow_Type == 'REJECTED_NOTES' || n.arrow_Type == 'death' || n.arrow_Type == 'hurt')
                deathNoteCount++;
            if (n.arrow_Type == 'Wiik3Punch' || n.arrow_Type == 'BoxingMatchPunch' || n.arrow_Type == "caution"
                || n.arrow_Type == "Wiik4Sword" || n.arrow_Type == "VoiidBullet")
                punchCount++;
        }
        //trace(noteCount);
        //trace(playerNoteCount);
        //trace(deathNoteCount);
        //trace(punchCount);

        var doPrint:Bool = VoiidMainMenuState.devBuild;
        if (doPrint) //to make my life easier
        {
            var printStr = '{';
            printStr += "song: ";
            printStr += '"'+PlayState.SONG.song.toLowerCase().replace(" ", "-") + '"';
            printStr += ", ";

            printStr += "diff: ";
            printStr += '"'+PlayState.storyDifficultyStr.toLowerCase().replace(" ", "-") + '"';
            printStr += ", ";

            printStr += "totalNoteCount: ";
            printStr += noteCount;
            printStr += ", ";

            printStr += "playerNoteCount: ";
            printStr += playerNoteCount;

            if (deathNoteCount > 0)
            {
                printStr += ", deathNoteCount: ";
                printStr += deathNoteCount;
            }
            if (punchCount > 0)
            {
                printStr += ", warningNoteCount: ";
                printStr += punchCount;
            }
            if (PlayState.SONG.keyCount != 4)
            {
                printStr += ", keyCount: ";
                printStr += PlayState.SONG.keyCount;
            }
            if (PlayState.SONG.playerKeyCount != 4)
            {
                printStr += ", playerKeyCount: ";
                printStr += PlayState.SONG.playerKeyCount;
            }
            //printStr += ", ";

            printStr += '},';

            trace(printStr); //just copy paste into the list
        }

        if (chartData != null)
        {
            if (chartData.keyCount != null)
                if (chartData.keyCount != PlayState.SONG.keyCount)
                    return false;
            if (chartData.playerKeyCount != null)
                if (chartData.playerKeyCount != PlayState.SONG.playerKeyCount)
                    return false;
            if (chartData.deathNoteCount != null)
            {
                if (chartData.deathNoteCount != deathNoteCount)
                    return false;
            }
            else if (deathNoteCount > 0)
                return false;

            if (chartData.warningNoteCount != null)
            {
                if (chartData.warningNoteCount != punchCount)
                    return false;
            }
            else if (punchCount > 0)
                return false; //just in case punches are added after, it would still get accepted


            if (chartData.totalNoteCount == noteCount && chartData.playerNoteCount == playerNoteCount)
                return true; //chart is good
            else 
                return false; //evil chart
        }

        return false;
    }
}