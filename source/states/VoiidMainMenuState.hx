package states;

import online.GameJolt;
import online.ServerCreateSubstate;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import ui.Alphabet;
import substates.MusicBeatSubstate;
import utilities.CoolUtil;
import states.VoiidAwardsState.AwardDisplay;
import utilities.Options;
import online.GameJoltLogin;
import Popup.ClickableMessagePopup;
import states.VoiidAwardsState.AwardManager;
import Popup.AwardPopup;
import Popup.MessagePopup;
import game.Song;
import haxe.Json;
import states.StoryMenuState.StoryGroup;
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

class VoiidMainMenuState extends MusicBeatState
{
    public static final devBuild:Bool = false;
    public static final modVersion:String = "v2.0.2";

    //@:allow(StoryMenuButton.loadButtons)
    static final wiikList = [
        "Wiik 1",
        "Wiik 2",
        "Wiik 3",
        "Wiik 100",
    ];

    static final wiikNumbers:Array<String> = [
        "1",
        "2",
        "3",
        "100"
    ];

    var logoBl:FlxSprite;
    public static var selectedWiik = 0; //starts at 0

    final wiiks:Array<Array<String>> = [ //hardcoding it so people cant cheat by changing the songs
        [
            "Light It Up",
            "Ruckus",
            "Target Practice"
        ],
        [
            "Burnout",
            "Sporting",
            "Boxing Match"
        ],
        [
            "Fisticuffs",
            "Blastout",
            "Immortal",
            "King Hit"
        ],
        [
            "Mat",
            "Banger",
            "Edgy",
        ]
    ];
    var wiiksUnlocked:Array<Bool> = [true, false, false];
    var wiikBGs:Array<FlxSprite> = [];

    var items:Array<MainMenuButton> = [];
    var storyButton:MainMenuButton;
    var optionsButton:MainMenuButton;
    var creditsButton:MainMenuButton;
    var freeplayButton:MainMenuButton;
    var awardsButton:MainMenuButton;
    var onlineButton:MainMenuButton;

    var upArrow:FlxSprite;
    var downArrow:FlxSprite;

    var websiteText:FlxText;

    var rain:Rain;
    override function create()
    {
        Conductor.changeBPM(60);
		MusicBeatState.windowNameSuffix = "";

        if (devBuild)
            FlxG.save.data.playedDevBuild = true; //maybe could use this for something idk
		
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null, "empty", "logo");
		#end
        transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		if (FlxG.sound.music == null || FlxG.sound.music.playing != true)
			TitleState.playTitleMusic();

        var lockedbg = new FlxSprite().loadGraphic(Paths.image('main menu/new/LOCKED_BG'));
        lockedbg.setGraphicSize(Std.int(1280));
        lockedbg.updateHitbox();
        lockedbg.screenCenter();
        lockedbg.antialiasing = true;
        add(lockedbg);

        for (w in 0...wiikList.length)
        {
            var bg = new FlxSprite().loadGraphic(Paths.image('main menu/new/' + wiikNumbers[w] + '_BG'));
            bg.setGraphicSize(Std.int(1280));
            bg.updateHitbox();
            bg.screenCenter();
            bg.antialiasing = true;
            add(bg);

            bg.alpha = 0;

            wiikBGs.push(bg);

            if (w > 0)
            {
                var saveStr = "beat_" + wiikList[w-1].toLowerCase();
                trace(saveStr);
                wiiksUnlocked[w] = (Options.getData(saveStr, "progress") != null); //unlock weeks that are unlocked
            }
        }
        if (wiikBGs.length > 0)
            wiikBGs[0].alpha = 1;

        rain = new Rain();
        rain.makePool(100,0.01);
        add(rain);
        rain.visible = false;

        var extraStuff = ["DOT_DOWN", "DOT_UP", "BLACK_STAINS"];

        for (e in extraStuff)
        {
            var d = new FlxSprite().loadGraphic(Paths.image('main menu/new/'+e));
            d.setGraphicSize(Std.int(1280));
            d.updateHitbox();
            d.screenCenter();
            d.antialiasing = true;
            add(d);
        }

        logoBl = new FlxSprite(-50, 0);
        logoBl.loadGraphic(Paths.image('main menu/new/LOGO_V2'));
        logoBl.antialiasing = true;
        logoBl.setGraphicSize(Std.int(logoBl.width*0.7));
        logoBl.updateHitbox();
        logoBl.screenCenter(X);
        add(logoBl);

        makeItems();

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

        var leText:String = "Press UP or DOWN to switch between wiiks";

		var text:FlxText = new FlxText(textBG.x - 1, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
        text.screenCenter(X);
		text.scrollFactor.set();
		add(text);



        var versionShit:FlxText = new FlxText(FlxG.width-5, 2, 0, "Voiid Chronicles "+modVersion+
        (devBuild ? " (Dev Build)" : "") + "\nLeather Engine Release v0.4.2 Custom\n", 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        versionShit.x = FlxG.width-5-versionShit.width;
		add(versionShit);

        FlxG.mouse.visible = true;

        var loginReturn:String = GameJolt.initStuffs();
        trace(loginReturn);
        if (loginReturn == 'no login found' && FlxG.save.data.seenLoginPopup == null)
        {
            FlxG.save.data.seenLoginPopup = true;
            FlxG.save.flush();
            Main.popupManager.addPopup(new ClickableMessagePopup(10, 400, 150, "Not signed into GameJolt.\nSign in to save scores on the leaderboard.\nClick Here to sign in.", 32, function()
            {
                FlxG.switchState(new GameJoltLogin());
            }));
        }

        websiteText = new FlxText(FlxG.width, FlxG.height, 0, "[Visit Website]");
        websiteText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        websiteText.x = FlxG.width-5-websiteText.width;
        websiteText.y = text.y;
        add(websiteText);

        downArrow = new FlxSprite().loadGraphic(Paths.image('main menu/new/DOWN_ARROW'));
        downArrow.setGraphicSize(Std.int(1280));
        downArrow.updateHitbox();
        downArrow.screenCenter();
        downArrow.antialiasing = true;
        add(downArrow);

        
        upArrow = new FlxSprite().loadGraphic(Paths.image('main menu/new/UP_ARROW'));
        upArrow.setGraphicSize(Std.int(1280));
        upArrow.updateHitbox();
        upArrow.screenCenter();
        upArrow.antialiasing = true;
        add(upArrow);
        






        //test popup for each award
        /*
        for (a in 0...AwardManager.awards.length)
        {
            Main.popupManager.addPopup(new AwardPopup(5+a, 400, 120, AwardManager.awards[a]));
        }
        */
        //Main.popupManager.addPopup(new AwardPopup(5, 400, 120, AwardManager.awards[0]));
                


        //Main.popupManager.addPopup(new Popup(8));

        //add(new AwardDisplay(AwardManager.awards[0]));


        changeWeek(0);

        super.create();
    }

    function makeItems()
    {

        var saveStr = "beat_light it up";
        var freeplayUnlocked:Bool = (Options.getData(saveStr, "progress") != null);
        var onlineUnlocked:Bool = (Options.getData("beat_wiik 3", "progress") != null);
        onlineUnlocked = true;
        #if mobile
        if (VoiidMainMenuState.devBuild)
            freeplayUnlocked = true;
        #end

        storyButton = new StoryMenuButton(0,0);
        storyButton.makeGraphic(363, 363, 0xFF4B05B5);
        storyButton.buttonFunc = function()
        {
            //#if !mobile
            if (!wiiksUnlocked[selectedWiik]) //locked week
            {
                storyButton.clicked = false;
                return;
            }
            //#end
            onSelectItem();

            PlayState.storyPlaylist = wiiks[selectedWiik];
            PlayState.campaignScore = 0;

            var enterSong = function()
            {
                PlayState.isStoryMode = true;
	
                var dif = "Voiid";
    
                PlayState.storyDifficulty = 0;
        
                PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + "-"+dif, PlayState.storyPlaylist[0]);
                PlayState.storyWeek = selectedWiik;
                PlayState.storyDifficultyStr = dif.toUpperCase();
                PlayState.diffLoadedInWith = dif;
                PlayState.groupWeek = "voiidmatt";
                PlayState.songMultiplier = 1;
    
                PlayState.wiikDiscordDisplay = wiikList[selectedWiik];
                trace(PlayState.wiikDiscordDisplay);
        
                new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                    PlayState.chartingMode = false;
                    LoadingState.loadAndSwitchState(new PlayState());
                });
            };

            if (FlxG.save.data.lastWeek != null && FlxG.save.data.lastWeek == wiikList[selectedWiik])
            {
                persistentUpdate = false;
                openSubState(new ContinueWeekSubstate(enterSong));
            }
            else 
            {
                enterSong();
            }


        }
        storyButton.screenCenter();
        storyButton.y += 60;
        add(storyButton);
        storyButton.loadButtons("");
        items.push(storyButton);

        creditsButton = new MainMenuButton(FlxG.width*0.15,FlxG.height-270);
        creditsButton.makeGraphic(177, 235, 0xFF4B05B5);
        creditsButton.buttonFunc = function()
        {
            onSelectItem();	
			new FlxTimer().start(0.6, function(tmr:FlxTimer)
			{
				FlxG.switchState(new VoiidCreditsMenuState());
			});
        }
        add(creditsButton);
        creditsButton.x += 20;
        creditsButton.loadButtons("credits");
        items.push(creditsButton);

        freeplayButton = new MainMenuButton(FlxG.width*0.35,FlxG.height-270);
        freeplayButton.makeGraphic(177, 235, 0xFF4B05B5);
        freeplayButton.enabled = freeplayUnlocked;
        freeplayButton.buttonFunc = function()
        {
            if (freeplayUnlocked)
            {
                onSelectItem();	
                new FlxTimer().start(0.6, function(tmr:FlxTimer)
                {
                    FlxG.switchState(new FreeplayState());
                });
            }
            else 
                freeplayButton.clicked = false;

        }
        add(freeplayButton);
        freeplayButton.x += 30;
        freeplayButton.loadButtons("freeplay");
        items.push(freeplayButton);

        awardsButton = new MainMenuButton(FlxG.width*0.65,FlxG.height-270);
        awardsButton.makeGraphic(177, 235, 0xFF4B05B5);
        awardsButton.buttonFunc = function()
        {
            onSelectItem();	
			new FlxTimer().start(0.6, function(tmr:FlxTimer)
			{
				FlxG.switchState(new VoiidAwardsState());
			});
        }
        add(awardsButton);
        awardsButton.x -= 15;
        awardsButton.loadButtons("awards");
        items.push(awardsButton);

        optionsButton = new MainMenuButton(FlxG.width*0.85,FlxG.height-270);
        optionsButton.makeGraphic(177, 235, 0xFF4B05B5);
        optionsButton.x = FlxG.width-50-optionsButton.width;
        optionsButton.x -= 15;
        optionsButton.buttonFunc = function()
        {
            onSelectItem();	
			new FlxTimer().start(0.6, function(tmr:FlxTimer)
			{
				FlxG.switchState(new OptionsMenu());
			});
        }
        add(optionsButton);
        optionsButton.loadButtons("options");
        items.push(optionsButton);

        creditsButton.x = 50;
        freeplayButton.x = creditsButton.x + 30 + creditsButton.width;

        optionsButton.x = FlxG.width-50-optionsButton.width;
        awardsButton.x = optionsButton.x - 30 - awardsButton.width;


        var upButton = new MainMenuButton(storyButton.x, storyButton.y-105);
        upButton.makeGraphic(363, 100, 0xFF4B05B5);
        upButton.buttonFunc = function()
        {
            changeWeek(-1);
        }
        add(upButton);
        items.push(upButton);

        var downButton = new MainMenuButton(storyButton.x, storyButton.y+5+363);
        downButton.makeGraphic(363, 100, 0xFF4B05B5);
        downButton.buttonFunc = function()
        {
            changeWeek(1);
        }
        add(downButton);
        items.push(downButton);


        var onlineButton = new MainMenuButton(FlxG.width-310, optionsButton.y-130);
        onlineButton.enabled = onlineUnlocked;
        onlineButton.makeGraphic(250, 120, 0xFF4B05B5);
        onlineButton.updateHitbox();
        onlineButton.buttonFunc = function()
        {
            FlxG.sound.play(Paths.sound('confirmMenu'));
            onlineButton.clicked = false;
            persistentUpdate = false;
            openSubState(new ServerCreateSubstate());
        }
        onlineButton.loadButtons("online");
        add(onlineButton);
        items.push(onlineButton);

        if (!onlineUnlocked)
        {
            onlineButton.hoverText = new FlxText(onlineButton.x, onlineButton.y, 0, "Unlocked after beating Wiik 3");
            onlineButton.hoverText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            add(onlineButton.hoverText);
        }
        
    }
    var selectedOption:Bool = false;
    function onSelectItem()
    {
        FlxG.sound.play(Paths.sound('confirmMenu'));
        FlxG.mouse.visible = false;
        selectedOption = true;
        for (item in items)
            item.enabled = false;
    }

    override function update(elapsed:Float)
    {       
        if (FlxG.sound.music.volume < 0.8)
        {
            FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
        }
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        if (!selectedOption)
        {
            if (controls.UP_P)
                changeWeek(-1);
            if (controls.DOWN_P)
                changeWeek(1);

            if (FlxG.mouse.overlaps(websiteText))
            {
                websiteText.bold = true;
                websiteText.color = 0xFF8B2BD9;
                if (FlxG.mouse.justPressed)
                    CoolUtil.openURL("https://www.voiidchronicles.xyz/home");
            }
            else 
            {
                websiteText.bold = false;
                websiteText.color = 0xFFFFFFFF;
            }

            /*if (FlxG.keys.justPressed.ONE)
            {
                onSelectItem();	
                new FlxTimer().start(0.6, function(tmr:FlxTimer)
                {
                    FlxG.switchState(new LevelPlayState("testLevel"));
                });
            }*/
        }

        upArrow.y = FlxMath.lerp(upArrow.y, 0, elapsed*9);
        downArrow.y = FlxMath.lerp(downArrow.y, 0, elapsed*9);

        for (w in 0...wiikBGs.length)
        {
            if (w == selectedWiik && wiiksUnlocked[w])
            {
                if (Math.abs(wiikBGs[w].alpha-1) > 0.05)
                    wiikBGs[w].alpha = FlxMath.lerp(wiikBGs[w].alpha, 1, elapsed*10);
                else 
                    wiikBGs[w].alpha = 1;
            }
            else 
            {
                if (Math.abs(wiikBGs[w].alpha) > 0.05)
                    wiikBGs[w].alpha = FlxMath.lerp(wiikBGs[w].alpha, 0, elapsed*10);
                else 
                    wiikBGs[w].alpha = 0;
            }
        }



        super.update(elapsed);
    }

    override function beatHit()
    {
        super.beatHit();
        //trace('beat hit');
    }

    function changeWeek(change:Int = 0):Void
    {
        selectedWiik += change;
        if (change != 0)
        {
            if (change < 0)
                upArrow.y -= 20;
            if (change > 0)
                downArrow.y += 20;
        }
        FlxG.sound.play(Paths.sound('scrollMenu'));

        if (selectedWiik > wiiks.length - 1)
            selectedWiik = 0;

        if (selectedWiik < 0)
            selectedWiik = wiiks.length - 1;

        if (wiikList[selectedWiik] != null && wiikList[selectedWiik] == "Wiik 100" && wiiksUnlocked[selectedWiik])
            rain.visible = rain.active = true;
        else 
            rain.visible = rain.active = false;

        //wiikText.text = "Wiik " + (selectedWiik+1);
    }

    override function closeSubState() 
    {
        persistentUpdate = true;
        super.closeSubState();
    }
}
class MainMenuButton extends FlxSprite
{
    public var buttonFunc:Void->Void = null;
    public var enabled:Bool = true;

    public var selectedImage:FlxSprite;
    public var unselectedImage:FlxSprite;

    public var lock:FlxSprite;

    public var hoverText:FlxText;

    private static var hitboxesVisible:Bool = false;
    override public function new(X:Float = 0, Y:Float = 0)
    {
        super(X,Y);
        visible = hitboxesVisible;
    }

    public function loadButtons(type:String)
    {
        selectedImage = new FlxSprite(0,0);
        unselectedImage = new FlxSprite(0,0);
        switch(type)
        {
            case "awards" | "freeplay" | "options": 
                selectedImage.loadGraphic(Paths.image('main menu/new/BOXES/SELECTED/' + type.toUpperCase()));
                unselectedImage.loadGraphic(Paths.image('main menu/new/BOXES/UNSELECTED/' + type.toUpperCase()));
            case "online": 
                selectedImage.loadGraphic(Paths.image('main menu/new/BOXES/SELECTED/' + type.toUpperCase()));
                unselectedImage.loadGraphic(Paths.image('main menu/new/BOXES/UNSELECTED/' + type.toUpperCase()));
                selectedImage.setPosition(x,y);
                unselectedImage.setPosition(x,y);

            case "credits": 
                //for random button
                var list:Array<String> = ["MEL", "MLOM", "RHYS", "ZORO"];
                var suffix:String = "_" + list[FlxG.random.int(0, list.length-1)];

                selectedImage.loadGraphic(Paths.image('main menu/new/BOXES/SELECTED/' + type.toUpperCase() + suffix));
                unselectedImage.loadGraphic(Paths.image('main menu/new/BOXES/UNSELECTED/' + type.toUpperCase() + suffix));

        }


        switch(type)
        {
            case "online": 
                selectedImage.setGraphicSize(Std.int(selectedImage.width*0.666));
                selectedImage.updateHitbox();
                unselectedImage.setGraphicSize(Std.int(unselectedImage.width*0.666));
                unselectedImage.updateHitbox();
            default: 
                selectedImage.setGraphicSize(1280);
                selectedImage.updateHitbox();
                unselectedImage.setGraphicSize(1280);
                unselectedImage.updateHitbox();
        }


        selectedImage.antialiasing = true;
        unselectedImage.antialiasing = true;

        selectedImage.alpha = 0;
        FlxG.state.add(unselectedImage);
        FlxG.state.add(selectedImage);

        if (!enabled)
        {
            lock = new FlxSprite(0,0).loadGraphic(Paths.image("main menu/new/STORYMODE/SM LOCKED/LOCK"));
            lock.setGraphicSize(1280);
            lock.updateHitbox();
            lock.antialiasing = true;
            //trace('lock freeplay');
            //lock.screenCenter();
            lock.x = x - ((lock.width)*0.5);
            lock.y = y - ((lock.height)*0.5);
            lock.x -= 132;
            lock.y += 30;

            if (type == "online")
            {
                lock.setGraphicSize(800);
                lock.updateHitbox();
                lock.x = x + (width*0.5) - (lock.width*0.5);
                lock.y = y + (height*0.5) - (lock.height*0.5);
                lock.y -= 50;
                lock.x -= 30;
            }

            FlxG.state.add(lock);
        }
        
    }

    public var clicked:Bool = false;
    override public function update(elapsed:Float) 
    {
        super.update(elapsed);
        if (doesOverlap() && isJustPressed() && enabled)
        {
            clicked = true;
            if (buttonFunc != null)
                buttonFunc();
        }   

        if (selectedImage != null)
        {
            var targetAlpha:Float = 0;
            if (clicked || doesOverlap())
            {
                targetAlpha = 1;
            }
            if (!enabled && !clicked)
                targetAlpha = 0;

            if (Math.abs(selectedImage.alpha-targetAlpha) > 0.05)
                selectedImage.alpha = FlxMath.lerp(selectedImage.alpha, targetAlpha, elapsed*10); //lerp alpha
            else 
                selectedImage.alpha = targetAlpha;
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


class StoryMenuButton extends MainMenuButton
{
    //allow for multiple ones lol
    public var selectedImages:Array<FlxSprite> = [];
    public var unselectedImages:Array<FlxSprite> = [];

    var unlockedWiiks:Array<Bool> = [];
    override public function loadButtons(type:String)
    {
        @:privateAccess
        for (w in 0...VoiidMainMenuState.wiikList.length)
        {
            var s = new FlxSprite(0,0);
            var u = new FlxSprite(0,0);
            
            var wiikNum:String = VoiidMainMenuState.wiikNumbers[w];
            var unlocked:Bool = true;
            if (w > 0)
            {
                var saveStr = "beat_" + VoiidMainMenuState.wiikList[w-1].toLowerCase();
                trace(saveStr);
                unlocked = (Options.getData(saveStr, "progress") != null);
            }
            if (unlocked)
            {
                s.loadGraphic(Paths.image('main menu/new/STORYMODE/SELECTED/WIIK_' + wiikNum));
                u.loadGraphic(Paths.image('main menu/new/STORYMODE/SM UNSELECTED/WIIK_' + wiikNum));
            }
            else 
            {
                s.loadGraphic(Paths.image('main menu/new/STORYMODE/SM LOCKED/WIIK_' + wiikNum));
                u.loadGraphic(Paths.image('main menu/new/STORYMODE/SM LOCKED/WIIK_' + wiikNum));
            }
            unlockedWiiks.push(unlocked);
 

            s.setGraphicSize(1280);
            s.updateHitbox();
            u.setGraphicSize(1280);
            u.updateHitbox();
            s.antialiasing = true;
            u.antialiasing = true;

            selectedImages.push(s);
            unselectedImages.push(u);

            FlxG.state.add(u);
            FlxG.state.add(s);
            s.alpha = 0;
            u.alpha = 0;
            if (w == VoiidMainMenuState.selectedWiik)
                u.alpha = 1;
        }

        lock = new FlxSprite(0,0).loadGraphic(Paths.image("main menu/new/STORYMODE/SM LOCKED/LOCK"));
        lock.setGraphicSize(1280);
        lock.updateHitbox();
        lock.antialiasing = true;
        lock.alpha = 0;
        FlxG.state.add(lock);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var targetAlpha:Float = 0;
        if (!unlockedWiiks[VoiidMainMenuState.selectedWiik])
        {
            targetAlpha = 1.0;
        }
        if (Math.abs(lock.alpha-targetAlpha) > 0.05)
            lock.alpha = FlxMath.lerp(lock.alpha, targetAlpha, elapsed*10); //update lock
        else 
            lock.alpha = targetAlpha;

        //update buttons
        for (s in 0...selectedImages.length)
        {
            var targetAlpha:Float = 0;
            if (s == VoiidMainMenuState.selectedWiik)
            {
                if (clicked || doesOverlap())
                {
                    targetAlpha = 1;
                }
                if (!enabled && !clicked)
                    targetAlpha = 0;
            }
            if (Math.abs(selectedImages[s].alpha-targetAlpha) > 0.05)
                selectedImages[s].alpha = FlxMath.lerp(selectedImages[s].alpha, targetAlpha, elapsed*10);
            else 
                selectedImages[s].alpha = targetAlpha;
        }
        for (s in 0...unselectedImages.length)
        {
            var targetAlpha:Float = 0;
            if (s == VoiidMainMenuState.selectedWiik)
            {
                targetAlpha = 1;
            }
            if (Math.abs(unselectedImages[s].alpha-targetAlpha) > 0.05)
                unselectedImages[s].alpha = FlxMath.lerp(unselectedImages[s].alpha, targetAlpha, elapsed*10);
            else 
                unselectedImages[s].alpha = targetAlpha;
        }

    }
}

class ContinueWeekSubstate extends MusicBeatSubstate
{
    var yes:FlxText;
    var no:FlxText;
    var enterFunc:Void->Void;

    public function new(enterFunc:Void->Void)
    {
        super();
        this.enterFunc = enterFunc;
    }
    override public function create()
    {
        super.create();
        var bg:FlxSprite = new FlxSprite(0,0).makeGraphic(1280,720,FlxColor.BLACK);
        bg.alpha = 0.7;
        add(bg);

        var text:FlxText = new FlxText(0,50,0, "Do you want to continue from\nwhere you left off?\n");
        text.setFormat(Paths.font("Contb___.ttf"), 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        text.screenCenter(X);
        add(text);

        yes = new FlxText(FlxG.width*0.25,300,0, "Yes");
        yes.setFormat(Paths.font("Contb___.ttf"), 72, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(yes);
        no = new FlxText(FlxG.width*0.25,300,0, "No");
        no.setFormat(Paths.font("Contb___.ttf"), 72, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(no);

        yes.screenCenter(X);
        yes.x -= FlxG.width*0.25;
        no.screenCenter(X);
        no.x += FlxG.width*0.25;

        FlxG.mouse.visible = true;
    }
    function doesOverlap(spr:FlxSprite) : Bool
    {
        #if mobile
        for (touch in FlxG.touches.list)
        {
            if (touch.overlaps(spr))
                return true;
        }
        #end
        return FlxG.mouse.overlaps(spr);
    }
    function isJustPressed() : Bool
    {
        #if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
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
    override public function update(elapsed:Float)
    {
        if (doesOverlap(yes))
        {
            yes.color = 0xFF8B2BD9;
            if (isJustPressed())
            {
                PlayState.storyPlaylist = FlxG.save.data.lastWeekPlaylist.copy();
                PlayState.campaignScore = FlxG.save.data.lastCampaignScore;
                enterFunc();
                FlxG.mouse.visible = false;
                close();
            }

        }
        else 
            yes.color = 0xFFFFFFFF;

        if (doesOverlap(no))
        {
            no.color = 0xFF8B2BD9;
            if (isJustPressed())
            {
                enterFunc();
                FlxG.mouse.visible = false;
                close();
            }
        }
        else 
            no.color = 0xFFFFFFFF;

    }
}

//rain lua script but haxe cuz its in the menu lol
class Rain extends FlxTypedSpriteGroup<FlxSprite>
{
    var curIdx:Int = 0;
    var pool:Array<FlxSprite> = [];
    var emitTime:Float = 0.01;
    var time:Float = 0;
    var velocityAngle:Float = 140;
    var velocitySpeed:Float = 5000;
    public function makePool(size:Int = 200, emitTime:Float = 0.01)
    {
        this.emitTime = emitTime;
        for (i in 0...size)
        {
            var spr:FlxSprite = new FlxSprite(0,-10000).makeGraphic(60,3);
            pool.push(spr);
            add(spr);
        }
    }
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        time += elapsed;
        if (time > emitTime)
        {
            time -= emitTime;
            emit();
        }
    }
    private function emit()
    {
        var p:FlxSprite = pool[curIdx];
        var pos:Float = FlxG.random.float(500, 3000);
        p.x = pos;
        p.y = -500;
        p.angle = velocityAngle;
        p.alpha = FlxG.random.float(0.25,0.7);
        p.velocity.x = Math.cos(velocityAngle*(Math.PI/180))*velocitySpeed;
        p.velocity.y = Math.sin(velocityAngle*(Math.PI/180))*velocitySpeed;

        curIdx++;
        if (curIdx > pool.length-1)
            curIdx = 0;
    }
}
