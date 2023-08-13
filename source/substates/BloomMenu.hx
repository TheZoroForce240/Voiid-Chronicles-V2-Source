package substates;

import shaders.Shaders.BloomEffect;
import lime.app.Application;
import openfl.Lib;
import game.Conductor;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;

class BloomMenu extends MusicBeatSubstate
{
    var bloomSetting:Int = 0;
    var offsetText:FlxText = new FlxText(0,0,0,"Bloom Setting: 0",64).setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
    var bloomList = ['Off', 'Low', 'Medium', 'High'];
    var bloomValues:Array<Array<Float>> = [
        [0,0],
        [0.18,1],
        [0.3,1.2],
        [0.4,1.3]
    ];
    var bloomShader:BloomEffect;
    
    public function new()
    {
        super();

        bloomSetting = utilities.Options.getData("bloom");

        bloomShader = new BloomEffect();

        FlxG.camera.setFilters([new ShaderFilter(bloomShader.shader)]);

        
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
        bg.scrollFactor.set();
        add(bg);

        FlxTween.tween(bg, {alpha: 0.75}, 1, {ease: FlxEase.circOut, startDelay: 0});

        offsetText.text = "Bloom Setting: " + bloomList[bloomSetting];
        offsetText.screenCenter();
        add(offsetText);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;

        var left = controls.LEFT;
		var right = controls.RIGHT;

        var accept = controls.ACCEPT;
        var back = controls.BACK;

        if(back)
        {
            utilities.Options.setData(bloomSetting, "bloom");
            FlxG.camera.setFilters([]);
            FlxG.state.closeSubState();
        }

        if(leftP)
            bloomSetting--;
        if(rightP)
            bloomSetting++;

        if (bloomSetting > bloomList.length-1)
            bloomSetting = 0;
        if (bloomSetting < 0)
            bloomSetting = bloomList.length-1;


        offsetText.text = "Bloom Setting: " + bloomList[bloomSetting];
        offsetText.screenCenter();

        bloomShader.strength = bloomValues[bloomSetting][0];
        bloomShader.effect = bloomValues[bloomSetting][1];
        bloomShader.update(elapsed);
    }
}