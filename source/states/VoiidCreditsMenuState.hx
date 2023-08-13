package states;

import flixel.addons.effects.FlxTrail;
import utilities.CoolUtil;
import flixel.math.FlxMath;
import modding.ModchartUtilities.FlxTextFix;
import flixel.group.FlxGroup;
import haxe.Json;
import game.Conductor;
import flixel.util.FlxTimer;
import game.Replay;
import utilities.MusicUtilities;
import lime.utils.Assets;
#if discord_rpc
import utilities.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import modding.PolymodHandler;

typedef CreditsJson = 
{
    var sections:Array<CreditsSection>;
}
typedef CreditsSection =
{
    var imageName:String;
    var people:Array<Credit>;
}
typedef Credit = 
{
    var name:String;
    var icon:String;
    var link:String;
    var desc:String;
    var iconScale:Float;
}

class VoiidCreditsMenuState extends MusicBeatState
{
    var currentSectionID:Int = 0;
    var currentCreditID:Int = 0;

    var bg:FlxSprite;

    var creditsJson:CreditsJson;
    var currentSection:CreditsSection;
    var currentCredit:Credit;

    var icon:FlxSprite = null;
    var section:FlxSprite = null;
    var creditTextGroup:FlxTypedGroup<FlxText>;
    var creditTextList:Array<Array<FlxText>> = [];

    var selectedCreditSprite:FlxSprite;

    var descText:FlxText;

    var camPos:FlxObject = new FlxObject(0, 0, 1, 1);

    var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

    override function create()
    {
        Conductor.changeBPM(60);
        MusicBeatState.windowNameSuffix = "";
        
        #if discord_rpc
        // Updating Discord Rich Presence
        DiscordClient.changePresence("In the Credits Menu", null, "empty", "logo");
        #end
        if (FlxG.sound.music == null || FlxG.sound.music.playing != true)
            TitleState.playTitleMusic();

        bg = new FlxSprite().loadGraphic(Paths.image('credits/Credits-BG'));
        bg.setGraphicSize(Std.int(1280));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = true;
        bg.scrollFactor.set();
        add(bg);

        var sideThing:FlxSprite = new FlxSprite().loadGraphic(Paths.image("credits/rectangle"));
        sideThing.x = FlxG.width-sideThing.width;
        sideThing.screenCenter(Y);
        sideThing.antialiasing = true;
        sideThing.scrollFactor.set();
        add(sideThing);

        creditTextGroup = new FlxTypedGroup<FlxText>();
        add(creditTextGroup);

        creditsJson = cast Json.parse(Assets.getText(Paths.json("credits")));

        for (sec in 0...creditsJson.sections.length)
        {
            creditTextList.push([]);
            for (cred in 0...creditsJson.sections[sec].people.length)
            {
                var text:FlxTextFix = new FlxTextFix(FlxG.width*0.7, 150+(72*cred), 0, creditsJson.sections[sec].people[cred].name);
                var size:Float = 64;
                if (creditsJson.sections[sec].people[cred].name.length > 12)
                {
                    size = (12/creditsJson.sections[sec].people[cred].name.length)*64;
                }
                text.setFormat(Paths.font("Contb___.ttf"), Std.int(size), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                text.screenCenter(X);
                text.x += FlxG.width*0.325;
                creditTextList[sec].push(text);
            }
        }

        selectedCreditSprite = new FlxSprite(2000).loadGraphic(Paths.image('credits/arrow'));
        selectedCreditSprite.setGraphicSize(40, 40);
        selectedCreditSprite.updateHitbox();
        selectedCreditSprite.antialiasing = true;
        var funnyTrail = new FlxTrail(selectedCreditSprite, null, 10, 3, 0.4, 0.05);
        funnyTrail.antialiasing = true;
        add(funnyTrail);
        add(selectedCreditSprite);

        camPos.screenCenter();
        FlxG.camera.follow(camPos, LOCKON, 1);

        descText = new FlxText(50, 100, 0, "");
        descText.setFormat(Paths.font("Contb___.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(descText);
        descText.scrollFactor.set();

        var arrow_Tex = Paths.getSparrowAtlas('campaign menu/ui_arrow');

		leftArrow = new FlxSprite(0, 0);
		leftArrow.frames = arrow_Tex;
		leftArrow.animation.addByPrefix('idle', "arrow0");
		leftArrow.animation.addByPrefix('press', "arrow push", 24, false);
		leftArrow.animation.play('idle');

		rightArrow = new FlxSprite(0, 0);
		rightArrow.frames = arrow_Tex;
		rightArrow.animation.addByPrefix('idle', 'arrow0');
		rightArrow.animation.addByPrefix('press', "arrow push", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.flipX = true;

        leftArrow.scrollFactor.set();
        rightArrow.scrollFactor.set();

        add(leftArrow);
        add(rightArrow);

        rightArrow.antialiasing = true;
        leftArrow.antialiasing = true;

        changeSection(0);

        super.create();
    }
    var iconScaleMult:Float = 1;
    var goingBack:Bool = false;
    override function update(elapsed:Float)
    {       
        if (FlxG.sound.music.volume < 0.8)
        {
            FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
        }
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        if (controls.LEFT_P)
            changeSection(-1);
        if (controls.RIGHT_P)
            changeSection(1);
        if (controls.UP_P)
            changeCredit(-1);
        if (controls.DOWN_P)
            changeCredit(1);

        if (controls.RIGHT)
            rightArrow.animation.play('press')
        else
            rightArrow.animation.play('idle');

        if (controls.LEFT)
            leftArrow.animation.play('press');
        else
            leftArrow.animation.play('idle');

        if (controls.BACK && !goingBack)
        {
            goingBack = true;
            FlxG.switchState(new VoiidMainMenuState());
        }
        if (controls.ACCEPT)
        {
            CoolUtil.openURL(currentCredit.link);
        }

        var lerpTarget = creditTextGroup.members[currentCreditID];
        selectedCreditSprite.x = FlxMath.lerp(selectedCreditSprite.x, lerpTarget.x-45, elapsed*15);
        selectedCreditSprite.y = FlxMath.lerp(selectedCreditSprite.y, lerpTarget.y + (lerpTarget.height*0.5) - (selectedCreditSprite.height*0.5), elapsed*15);


        if (icon != null)
        {
            iconScaleMult = FlxMath.lerp(iconScaleMult, 1, CoolUtil.boundTo(elapsed*5, 0, 1));
            updateIconScale();
        }

        var camY = FlxG.height*0.5;
        if (currentCreditID > 4)
        {
            camY += (currentCreditID-4)*72;
        }
        camPos.y = FlxMath.lerp(camPos.y, camY, elapsed*20);


        super.update(elapsed);
    }
    function updateIconScale()
    {
        icon.scale.set(currentCredit.iconScale*iconScaleMult, currentCredit.iconScale*iconScaleMult);
        icon.updateHitbox();
        icon.x = (FlxG.width*0.33)-(icon.width*0.5);
        icon.screenCenter(Y);
    }
    override function beatHit()
    {
        super.beatHit();
        iconScaleMult = 1.25;
        updateIconScale();
    }

    function changeSection(change:Int)
    {
        currentSectionID += change;
        currentSectionID = numLoop(currentSectionID, creditsJson.sections.length);
        currentCreditID = 0;
        updateSection();

    }
    function changeCredit(change:Int)
    {
        currentCreditID += change;
        currentCreditID = numLoop(currentCreditID, creditsJson.sections[currentSectionID].people.length);
        updateIcon();
    }

    function updateSection()
    {
        currentSection = creditsJson.sections[currentSectionID];
        creditTextGroup.clear();
        for (creds in creditTextList[currentSectionID])
            creditTextGroup.add(creds);


        if (section != null)
        {
            section.kill();
            remove(section);
        }
        section = new FlxSprite(0, 0);
        var path = Paths.image("credits/"+currentSection.imageName);
        if(Assets.exists(path))
        {
            section.loadGraphic(path);
        }
        else 
            section.makeGraphic(300, 100);
        
        section.updateHitbox();
        add(section);
        section.x = (FlxG.width*0.825)-(section.width*0.5);
        section.y = 10;
        section.antialiasing = true;
        section.scrollFactor.set();

        leftArrow.x = section.x-leftArrow.width;
        leftArrow.y = section.y+(section.height*0.5)-(leftArrow.height*0.5);
        rightArrow.x = section.x+section.width;
        rightArrow.y = leftArrow.y;

        updateIcon();
    }
    function updateIcon()
    {
        currentCredit = currentSection.people[currentCreditID];
        if (icon != null)
        {
            icon.kill();
            remove(icon);
        }
        icon = new FlxSprite(0, 0);
        var path = Paths.image("credits/icons/"+currentCredit.icon);
        if(!Assets.exists(path))
        {
            path = Paths.image("credits/icons/none");
        }
        icon.loadGraphic(path);
        icon.scale.set(currentCredit.iconScale,currentCredit.iconScale);
        icon.updateHitbox();
        add(icon);
        icon.x = (FlxG.width*0.33)-(icon.width*0.5);
        icon.screenCenter(Y);
        icon.antialiasing = true;
        icon.scrollFactor.set();

        for (c in 0...creditTextGroup.members.length)
        {
            creditTextGroup.members[c].alpha = 0.8;
            if (c-currentCreditID < -4)
                creditTextGroup.members[c].alpha = 0;
        }
        creditTextGroup.members[currentCreditID].alpha = 1;

        descText.text = currentCredit.desc;
        descText.x = icon.x+(icon.width*0.5)-(descText.width*0.5);
    }

    function numLoop(num:Int, limit:Int)
    {
        if (num > limit-1)
            num = 0;
        if (num < 0)
            num = limit-1;
        return num;
    }
}