package utilities;

import flixel.FlxG;

class NoteHandler
{
    public static function getBinds(keyCount:Int):Array<String>
    {
        return utilities.Options.getData("binds", "binds")[keyCount - 1];
    }
    public static function getControllerBinds(keyCount:Int):Array<String>
    {
        return utilities.Options.getData("controllerBinds", "binds")[keyCount - 1];
    }
    public static function formatControllerBind(bind:String)
    {
        switch(bind) //easier to read lol
        {
            case "LEFT_TRIGGER": 
                return "LT";
            case "RIGHT_TRIGGER": 
                return "RT";
            case "LEFT_SHOULDER": 
                return "LB";
            case "RIGHT_SHOULDER": 
                return "RB";
            case "DPAD_LEFT": 
                return "LEFT";
            case "DPAD_RIGHT": 
                return "RIGHT";
            case "DPAD_UP": 
                return "UP";
            case "DPAD_DOWN": 
                return "DOWN";
        }
        return bind;
    }
}