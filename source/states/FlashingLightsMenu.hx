package states;

import utilities.Options;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class FlashingLightsMenu extends MusicBeatState
{
    override public function create()
    {
        super.create();

        var text = new FlxText(0,0,0,"Hey! Leather Engine has flashing lights\nPress Y to enable them, or anything else to not.\n(Any key closes this menu)", 32);
        #if mobile 
        var t = "Hey! Leather Engine has flashing lights\nPress Y to enable them, or anything else to not.\n(Any key closes this menu)\n\n";
        t += "This is a Mobile port of Voiid Chonicles,\nsome things may not work correctly\nor some songs maybe crash depending on your device.\n";
        t += "Shaders and Modcharts are disabled by default,\nyou can turn them back on but it may crash on some songs,\nif youre still getting crashes check\nGraphics->Optimization in the options menu and mess with the settings\n";
        text.size = 24;
        text.text = t;
        Options.setData(false, "shaders"); //turned off by default      
        Options.setData(false, "modcharts");
        Options.setData(false, "gpuTextures");   
        #end
        text.font = Paths.font("vcr.ttf");
        text.screenCenter();
        text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5, 1);
        add(text);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var pressed:Bool = false;
        #if mobile
		if (MobileControls.justPressedAny())
            pressed = true;
		#end

        if(FlxG.keys.justPressed.Y)
            Options.setData(true, "flashingLights");
        else if(!FlxG.keys.justPressed.Y && FlxG.keys.justPressed.ANY)
            Options.setData(false, "flashingLights");

        if(FlxG.keys.justPressed.ANY || pressed)
            FlxG.switchState(new TitleState());
    }
}