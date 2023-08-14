package states;

import flixel.graphics.FlxGraphic;
import online.GameJoltLogin;
import game.Note;
import game.Conductor;
import game.StrumNote;
import utilities.Ratings;
import game.GameHUD;
import substates.BloomMenu;
import utilities.CoolUtil;
import substates.UISkinSelect;
import substates.ControlMenuSubstate;
import modding.CharacterCreationState;
import utilities.MusicUtilities;
import ui.Option;
import ui.Checkbox;
import flixel.group.FlxGroup;
import debuggers.ChartingState;
import debuggers.StageMakingState;
import flixel.system.FlxSound;
import debuggers.AnimationDebug;
import utilities.Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import ui.Alphabet;
import game.Song;
import debuggers.StageMakingState;
import game.Highscore;
import openfl.utils.Assets as OpenFLAssets;
import debuggers.ChartingStateDev;

class OptionsMenu extends MusicBeatState
{
	var curSelected:Int = 0;

	public static var inMenu = false;

	public var hud:GameHUD;

	function getEnterPress()
	{
		#if mobile
		if (MobileControls.justPressedAny())
			return true;
		#end
		return FlxG.keys.justPressed.ENTER;
	}

	public var pages:Array<Dynamic> = [
		[
			"Categories",
			new PageOption("Mod Settings", 0, "Mod Settings"),
			new PageOption("Gameplay", 1, "Gameplay"),
			new PageOption("HUD", 2, "HUD"),
			new PageOption("Graphics", 3, "Graphics"),
			new PageOption("Misc", 4, "Misc"),
			new GameStateOption("GameJolt Login", 5, new GameJoltLogin()),
			//new PageOption("Tools (Very WIP)", 6, "Tools"),
		],
		[
			"Gameplay",
			//#if !mobile //still allow because of controller support
			new ControlMenuSubStateOption("Binds", 1),
			//#end
			new BoolOption("Downscroll", "downscroll", 2),
			new BoolOption("Middlescroll", "middlescroll", 3),
			new BoolOption("Use Custom Scrollspeed", "useCustomScrollSpeed", 4),
			new ScrollSpeedMenuOption("Custom Scroll Speed", 5),
			new PageOption("Judgements", 6, "Judgements"),
			new PageOption("Input Options", 7, "Input Options"),
			new SongOffsetOption("Song Offset", 8),
			new BoolOption("Reset Button", "resetButton", 9),
			new BoolOption("Invisible Notes", "invisibleNotes", 10)
		],
		[
			"HUD",
			new PageOption("Note Options", 1, "Note Options"),
			new BoolOption("Key Bind Reminders", "extraKeyReminders", 2),
			new PageOption("FPS / Memory Display Settings", 3, "Info Display"),
			new BoolOption("Bigger Score Text", "biggerScoreInfo", 4),
			new BoolOption("Bigger Info Text", "biggerInfoText", 5),
			new StringSaveOption("Time Bar Style", ["leather engine", "psych engine", "new kade engine", "old kade engine"], 6, "timeBarStyle"),
			new BoolOption("Show Rating Popup", "ratingPopup", 7),
			new BoolOption("Show Combo Popup", "comboPopup", 8),
			new BoolOption("Show MS Text", "displayMs", 9),
			new BoolOption("Show Side Ratings", "sideRatings", 10),
			new BoolOption("Show Break Timer", "breakTimer", 11),
		],
		[
			"Graphics",
			new PageOption("Optimizations", 0, "Optimizations"),
			new MaxFPSOption("Max FPS", 1),
			new BoolOption("Camera Bounce", "cameraZooms", 2),
			new BoolOption("Flashing Lights", "flashingLights", 3),
			new BoolOption("Screen Shake", "screenShakes", 4)
		],
		[
			"Tools",
			new GameStateOption("Charter", 1, new ChartingState()),
			#if debug
			new GameStateOption("Charter Dev", 1, new ChartingStateDev()),
			#end
			new GameStateOption("Animation Debug", 2, new AnimationDebug("dad")),
			new GameStateOption("Stage Editor", 3, new StageMakingState("stage")),
			new GameStateOption("Character Creator", 4, new CharacterCreationState("bf"))
		],
		[
			"Misc",
			new StringSaveOption("Hitsound", CoolUtil.coolTextFile(Paths.txt("hitsoundList")), 0, "hitsound"),
			new BoolOption("Camera Follows Note Direction", "cameraTracksDirections", 1),
			new StringSaveOption("Cutscenes Play On", ["story","freeplay","both"], 2, "cutscenePlaysOn"),
			new BoolOption("Auto Pause", "autoPause", 3),
			new BoolOption("Watermarks", "watermarks", 4),
			new BoolOption("Freeplay Music Auto Play", "freeplayMusic", 5),
			#if discord_rpc
			new BoolOption("Discord RPC", "discordRPC", 6),
			#end
			new BoolOption("Disable Debug Menus", "disableDebugMenus", 7),
		],
		[
			"Optimizations",
			new BoolOption("Antialiasing", "antialiasing", 1),
			new BoolOption("Health Icons", "healthIcons", 2),
			new BoolOption("Chars And BGs", "charsAndBGs", 3),
			new BoolOption("Force Disable Scripts", "forceDisableScripts", 4),
			new BoolOption("Preload Stage Events", "preloadChangeBGs", 5),
			new BoolOption("GPU Textures", "gpuTextures", 6),
		],
		[
			"Info Display",
			new DisplayFontOption("Display Font", ["_sans", OpenFLAssets.getFont(Paths.font("vcr.ttf")).fontName, OpenFLAssets.getFont(Paths.font("pixel.otf")).fontName], 1, "infoDisplayFont"),
			new BoolOption("FPS Counter", "fpsCounter", 2),
			new BoolOption("Memory Counter", "memoryCounter", 3),
			new BoolOption("Version Display", "versionDisplay", 4)
		],
		[
			"Judgements",
			new JudgementMenuOption("Timings", 1),
			new StringSaveOption("Rating Mode", ["psych", "simple", "complex"], 2, "ratingType"),
			new BoolOption("Marvelous Ratings", "marvelousRatings", 3)
		],
		[
			"Input Options",
			new BoolOption("Ghost Tapping", "ghostTapping", 9),
			new BoolOption("Anti Mash", "antiMash", 4),
			new BoolOption("Shit gives Miss", "missOnShit", 5),
			new BoolOption("Gain Misses on Sustains", "missOnHeldNotes", 10),
			new StringSaveOption("Input Mode", ["standard", "rhythm"], 3, "inputSystem"),
		],
		[
			"Note Options",
			new UISkinSelectOption("UI Skin", 0),
			new NoteColorMenuOption("Note Colors", 1),
			new NoteBGAlphaMenuOption("Note Underlay Transparency", 2),
			new BoolOption("Player Note Splashes", "playerNoteSplashes", 3),
			new BoolOption("Opponent Note Splashes", "opponentNoteSplashes", 4),
			new BoolOption("Opponent Strum Glow", "enemyStrumsGlow", 5),
		],
		[
			"Mod Settings",
			new BoolOption("Mechanics", "mechanics", 1),
			new BoolOption("Modcharts", "modcharts", 2),
			new BoolOption("Shaders", "shaders", 3),
			new BloomMenuOption("Bloom Setting", 4),
			new BoolOption("Use Alt Punch Note Skin (Wiik 3)", "altPunchNotes", 5),
			//new LanguageOption("Language", ["English", "Español"], 6, "language", false),
		]
	];

	public var page:FlxTypedGroup<Option> = new FlxTypedGroup<Option>();
	public var lastPage:FlxTypedGroup<Option> = new FlxTypedGroup<Option>();

	public static var instance:OptionsMenu;

	public var pagesStack:Array<String> = [];

	public var pageTabsText:Alphabet;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var arrow_Group:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	var strumLineThing:FlxSprite;
	var strumLineThing2:FlxSprite;
	var uiSkin:UISkin;

	var punchNote:FlxSprite;
	var punchNoteAlt:FlxSprite;

	override function create()
	{		
		MusicBeatState.windowNameSuffix = "";
		
		instance = this;

		uiSkin = new UISkin("default");

		var menuBG:FlxSprite;

		//if(utilities.Options.getData("menuBGs"))
			menuBG = new FlxSprite().loadGraphic(Paths.image('freeplay/BG'));
		//else
			//menuBG = new FlxSprite().makeGraphic(1286, 730, FlxColor.fromString("#E1E1E1"), false, "optimizedMenuDesat");

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		super.create();

		hud = new GameHUD();
		hud.setCharacters('Wiik1BFRTX-icons', 'Wiik1VoiidMatt-icons', FlxColor.fromRGB(255, 175, 175), FlxColor.fromRGB(73,69,78));
		hud.visible = false;
		

		pageTabsText = new Alphabet(0, 50, "", true, false, 1);
		pageTabsText.alpha = 0.8;
		

		add(page);
		add(lastPage);

		leftArrow = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/white_arrow")); leftArrow.flipX = true;
		rightArrow = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/white_arrow"));
		add(leftArrow);
		add(rightArrow);

		

		var pageTabBG = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/thing"));
		pageTabBG.screenCenter();
		pageTabBG.y = 20;
		add(pageTabBG);
		add(pageTabsText);

		add(hud);

        create_Arrows();
        add(arrow_Group);
		var wid = Std.int(arrow_Group.members[arrow_Group.members.length-1].x+arrow_Group.members[arrow_Group.members.length-1].width-arrow_Group.members[0].x);
		strumLineThing = new FlxSprite(0, 0).makeGraphic(wid, 10);
		add(strumLineThing);
		strumLineThing2 = new FlxSprite(0, 0).makeGraphic(wid, 10);
		add(strumLineThing2);

		punchNote = new FlxSprite(1050, 150);
		punchNote.frames = Paths.getSparrowAtlas("ui skins/default/arrows/Wiik3Punch", 'shared');
		punchNote.animation.addByPrefix("note", "purple0");
		punchNote.animation.play("note");
		add(punchNote);

		punchNoteAlt = new FlxSprite(1050, 150);
		punchNoteAlt.frames = Paths.getSparrowAtlas("ui skins/default/arrows/Wiik3PunchAlt", 'shared');
		punchNoteAlt.animation.addByPrefix("note", "purple0");
		punchNoteAlt.animation.play("note");
		add(punchNoteAlt);
		punchNote.visible = punchNoteAlt.visible = false;


		LoadPage("Categories");

		if(FlxG.sound.music == null)
			FlxG.sound.playMusic(MusicUtilities.GetOptionsMenuMusic(), 0.7, true);
	}

	public static function LoadPage(Page_Name:String, goingBack:Bool = false)
	{
		inMenu = true;
		instance.curSelected = 0;
		instance.pagesStack.push(Page_Name);
		//create tab list
		var pageTabText = "";
		for (i in 0...instance.pagesStack.length)
		{
			pageTabText += instance.pagesStack[i];
			if (i < instance.pagesStack.length-1)
				pageTabText += " > ";
		}
		var scaleShit = (20 / pageTabText.length);
		if (pageTabText.length <= 20)
			scaleShit = 1;
		instance.pageTabsText.scaleMult = scaleShit;
		instance.pageTabsText.setText(pageTabText);
		//instance.pageTabsText.x = (FlxG.width/2)-(instance.pageTabsText.width/2)-30;
		instance.pageTabsText.screenCenter(X);
		instance.hud.visible = Page_Name == 'HUD'; //only show in hud menu
		

		var bruh = 0;

		var moveBackVal:Float = 1;
		if (goingBack)
			moveBackVal = -1;

		for (x in instance.page.members)
		{
			x.Alphabet_Text.targetY = bruh - instance.curSelected;
			x.Alphabet_Text.targetX = -1500 * moveBackVal; //move to the side
			x.enabled = false; //so you cant select it lol
			bruh++;
		}

		
		
		var nextPage = instance.lastPage;
		var lastPage = instance.page;

		nextPage.clear();

		var selectedPage:Array<Dynamic> = [];

		for(i in 0...instance.pages.length)
		{
			if(instance.pages[i][0] == Page_Name)
			{
				for(x in 0...instance.pages[i].length)
				{
					if(instance.pages[i][x] != Page_Name)
						selectedPage.push(instance.pages[i][x]);
				}
			}
		}

		instance.lastPage = lastPage;
		instance.page = nextPage; //swap the pages

		for(x in selectedPage)
		{
			nextPage.add(x);
		}
		for (x in instance.page.members)
		{
			x.Alphabet_Text.x = 1500 * moveBackVal; //new page starts from the side, should lerp back into position
			x.enabled = false;
		}
		instance.justSwitchedPage = true;
		inMenu = false;
	}
	public var justSwitchedPage:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!inMenu)
		{
			if(-1 * Math.floor(FlxG.mouse.wheel) != 0)
			{
				curSelected -= 1 * Math.floor(FlxG.mouse.wheel);
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}

			if (controls.UP_P)
			{
				curSelected -= 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}

			if (controls.DOWN_P)
			{
				curSelected += 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}
			#if mobile
			var vPress:Int = MobileControls.verticalPressOptions(page, curSelected);
			switch(vPress)
			{
				case -1: 
					curSelected -= 1;
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				case 1: 
					curSelected += 1;
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}
			#end

			if (controls.BACK)
			{
				if (pagesStack.length > 1)
				{
					pagesStack.pop();
					var pageToGoBackTo = pagesStack.pop();
					LoadPage(pageToGoBackTo, true);
				}
				else 
				{
					FlxG.switchState(new VoiidMainMenuState());
				}
			}
			if (getEnterPress())
			{
				hud.clearHUD();
				hud.createHUD("default");
				hud.updateScoreText(
					"Score: " + 0 + " | " +
					"Misses: " + 0 + " | " +
					"Accuracy: " + 100 + "% | " +
					"Perfect"
				);
				//stupid
				hud.updateScoreText(
					"Score: " + 0 + " | " +
					"Misses: " + 0 + " | " +
					"Accuracy: " + 100 + "% | " +
					"Perfect"
				);
				hud.updateRatingText(
					(utilities.Options.getData("marvelousRatings") == true ? "Crazy: " + 0 + "\n" : "") +
					"Sick: " + 0 + "\n" +
					"Good: " + 0 + "\n" +
					"Bad: " + 0 + "\n" +
					"Shit: " + 0 + "\n" +
					"Misses: " + 0 + "\n"
				);
				hud.updateHealthIconPosition();

				
			}
				
		}
		else
		{
			if(controls.BACK)
				inMenu = false;
		}

		var optionsEnabled = !justSwitchedPage; //stop from being able to select something as soon as you enter a page
		if (justSwitchedPage)
		{
			justSwitchedPage = false;
		}

		//pageTabsText.x = (FlxG.width-pageTabsText.alphabetWidth)/2;
		pageTabsText.screenCenter(X);

		if (curSelected < 0)
			curSelected = page.length - 1;

		if (curSelected >= page.length)
			curSelected = 0;

		switch(page.members[curSelected].Option_Name.toLowerCase())
		{
			case "use alt punch note skin (wiik 3)":
				punchNote.visible = !utilities.Options.getData("altPunchNotes");
				punchNoteAlt.visible = !punchNote.visible;
			case "downscroll" | "middlescroll":
				showArrows();
				strumLineThing2.visible = strumLineThing.visible = false;
			case "use custom scrollspeed" | "custom scroll speed":
				strumLineThing2.visible = strumLineThing.visible = true;
				showArrows();
			default: 
				punchNote.visible = punchNoteAlt.visible = false;
				strumLineThing2.visible = strumLineThing.visible = false;
				hideArrows();
		}

		if (getEnterPress())
		{
			switch(page.members[curSelected].Option_Name.toLowerCase())
			{
				case "downscroll" | "middlescroll": 
					var strumLineY = 100;
					if (utilities.Options.getData("downscroll"))
						strumLineY = FlxG.height - 100;
					for (a in arrow_Group)
					{
						a.doLerp = true;
						a.strumlineY = strumLineY;
						var curX = a.x; //store current x
						var curY = a.y;
						a.setupStrumPosition(utilities.Options.getData("middlescroll") ? 0.5 : 1.0);
						a.lerpX = a.x; //set lerp
						a.lerpY = a.y;
						a.x = curX;
						a.y = curY;
					}
			}
		}


		var speed = 3;
		if(utilities.Options.getData("useCustomScrollSpeed"))
			speed = utilities.Options.getData("customScrollSpeed");
		
			var strum = arrow_Group.members[0];
			var visualTime = (Conductor.songPosition%Conductor.crochet)-Conductor.crochet;
			var movement = (0.45 * (visualTime) * FlxMath.roundDecimal(speed, 2));
			strumLineThing.x = strum.x;
			
			if(utilities.Options.getData("downscroll"))
				strumLineThing.y = strum.y + movement;
			else 
				strumLineThing.y = strum.y - movement;

			visualTime = (Conductor.songPosition%Conductor.crochet);
			movement = (0.45 * (visualTime) * FlxMath.roundDecimal(speed, 2));
			strumLineThing2.x = strum.x;
			if(utilities.Options.getData("downscroll"))
				strumLineThing2.y = strum.y + movement;
			else 
				strumLineThing2.y = strum.y - movement;
			

		var bruh = 0;

		for (x in page.members)
		{
			x.Alphabet_Text.targetY = bruh - curSelected;
			x.Alphabet_Text.targetX = (FlxG.width-x.getAlphabetWidth())/2;
			x.enabled = optionsEnabled;
			bruh++;
		}

		for (x in page.members)
		{
			if(x.Alphabet_Text.targetY != 0)
			{
				for(item in x.members)
				{
					item.alpha = 0.6;
				}
			}
			else
			{
				for(item in x.members)
				{
					item.alpha = 1;
				}
				leftArrow.x = x.Alphabet_Text.x-leftArrow.width-5;
				rightArrow.x = x.Alphabet_Text.x+x.getAlphabetWidth()+5;
				leftArrow.y = x.Alphabet_Text.y + (x.Alphabet_Text.height*0.5) - (leftArrow.height*0.5);
				rightArrow.y = leftArrow.y;
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();
	}

	function create_Arrows()
	{
		arrow_Group.clear();

		var strumLineY = 100;
		if (utilities.Options.getData("downscroll"))
			strumLineY = FlxG.height - 100;

		for (i in 0...4)
		{
			var babyArrow:StrumNote = new StrumNote(0, strumLineY, i, uiSkin, 4);

			babyArrow.loadStrum();
			babyArrow.setupStrumPosition(1);

			//babyArrow.y -= 10;
			//babyArrow.alpha = 0;
			//FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			arrow_Group.add(babyArrow);
		}
	}
	public function hideArrows()
	{
		for (a in arrow_Group)
			a.visible = false;
		//strumLineThing.visible = strumLineThing2.visible = false;
	}
	public function showArrows()
	{
		for (a in arrow_Group)
			a.visible = true;
		//strumLineThing.visible = strumLineThing2.visible = true;
	}
}