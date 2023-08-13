package states;

#if desktop
import modding.FlxTransWindow;
#end
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import Popup.MessagePopup;
import states.VoiidAwardsState.AwardManager;
import game.GameHUD;
#if sys
import sys.FileSystem;
#end

#if BIT_64
import modding.FlxVideo;
#end

#if discord_rpc
import utilities.Discord.DiscordClient;
#end

#if polymod
import polymod.backends.PolymodAssets;
#end

import utilities.Options;
import flixel.util.FlxStringUtil;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxShader;
import flixel.addons.display.FlxShaderMaskCamera;
import substates.ResultsScreenSubstate;
import haxe.Json;
import game.Replay;
import lime.utils.Assets;
import game.StrumNote;
import game.Cutscene;
import game.NoteSplash;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.tweens.misc.VarTween;
import modding.ModchartUtilities;
import lime.app.Application;
import utilities.NoteVariables;
import flixel.input.FlxInput.FlxInputState;
import utilities.NoteHandler;
import flixel.group.FlxGroup;
import utilities.Ratings;
import debuggers.ChartingState;
import game.Section.SwagSection;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import game.Note;
import ui.HealthIcon;
import ui.DialogueBox;
import game.Character;
import game.Boyfriend;
import game.StageGroup;
import game.Conductor;
import game.Song;
import utilities.CoolUtil;
import substates.PauseSubState;
import substates.GameOverSubstate;
import game.Highscore;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef SpamSection = 
{
	var song:String;
	var start:Int;
	var end:Int;
	var ?inst:FlxSound;
	var ?vocals:FlxSound;
	var ?chart:SwagSong;
};

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;
	#if VIDEOS_ALLOWED
	public var luaVideo:FlxVideo = null;
	#end
	public var tweenManager:FlxTweenManager;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 1;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var storyDifficultyStr:String = "NORMAL";
	public static var diffLoadedInWith:String = "Voiid";

	public static var wiikDiscordDisplay:String = "Wiik 1";

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var unspawnNotesCopy:Array<Note> = [];
	public var shouldKillNotes:Bool = true;

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var stage:StageGroup;

	public static var strumLineNotes:FlxTypedGroup<StrumNote>;
	public static var playerStrums:FlxTypedGroup<StrumNote>;
	public static var enemyStrums:FlxTypedGroup<StrumNote>;
	private var splashes:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var healthShown:Float = 1;
	public var minHealth:Float = 0;
	public var maxHealth:Float = 2;
	public var combo:Int = 0;
	public var misses:Int = 0;
	public var mashes:Int = 0;
	public var accuracy:Float = 100.0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var camTransition:FlxCamera;

	public var gameHUD:GameHUD;

	public static var currentBeat = 0;

	public var gfVersion:String = 'gf';

	public var songScore:Int = 0;

	public static var campaignScore:Int = 0;

	private var totalNotes:Int = 0;
	private var hitNotes:Float = 0.0;

	public var foregroundSprites:FlxGroup = new FlxGroup();

	public var defaultCamZoom:Float = 1.05;
	public var defaultHudCamZoom:Float = 1.0;
	var altAnim:String = "";

	public static var stepsTexts:Array<String>;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	public static var groupWeek:String = "";

	#if discord_rpc
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var curPortrait:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var executeModchart:Bool = false;

	#if linc_luajit
	public static var luaModchart:ModchartUtilities = null;
	#end

	var songLength:Float = 0;

	var binds:Array<String>;
	var controllerBinds:Array<String>;

	#if (haxe >= "4.0.0")
	public var variables:Map<String, Dynamic> = new Map();
	#else
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end

	public function removeObject(object:FlxBasic) { remove(object); }

	var missSounds:Array<FlxSound> = [];

	public static var songMultiplier:Float = 1;
	public static var previousScrollSpeedLmao:Float = 0;
	var startSpeed:Float = 1;

	public var hasUsedBot:Bool = false;
	private var isCheating:Bool = false; //anti cheat lol
	public var playingFDGOD:Bool = false;
	public var hasMechAndModchartsEnabled:Bool = false;
		
	var didDie:Bool = false;

	var cutscene:Cutscene;

	var waitingForAccept:Bool = false;
	var mechanicsImage:FlxSprite = null;
	var continueText:FlxText = null;

	public static var fromPauseMenu:Bool = false;

	var time:Float = 0.0;

	public var ratings:Map<String, Int> = [
		"marvelous" => 0,
		"sick" => 0,
		"good" => 0,
		"bad" => 0,
		"shit" => 0
	];

	public var stopSong:Bool = false;

	public var replay:Replay;
	public var inputs:Array<Array<Dynamic>> = [];

	public static var playingReplay:Bool = false;

	var events:Array<Array<Dynamic>> = [];
	public var baseEvents:Array<Array<Dynamic>> = [];

	public var centerCamera:Bool = false;

	public var mobileControls:MobileControls;

	public function new(?_replay:Replay)
	{
		super();

		if(_replay != null)
		{
			replay = _replay;
			playingReplay = true;
		}
		else
			replay = new Replay();
	}

	public static var characterPlayingAs:Int = 0;

	var hitSoundString:String = utilities.Options.getData("hitsound");

	public var yoWaitThisIsCharter:Bool = false;

	public var bfMap:Map<String, Boyfriend> = [];
	public var gfMap:Map<String, Character> = [];
	public var dadMap:Map<String, Character> = [];

	var stageMap:Map<String, StageGroup> = [];

	public static var chartingMode:Bool = false;

	var funnyTimeBarStyle:String;

	public var ogPlayerKeyCount:Int = 4;
	public var ogKeyCount:Int = 4;

	public var cameraSpeed:Float = 1;
	public var cameraZoomSpeed:Float = 1;

	#if linc_luajit
	public var event_luas:Map<String, ModchartUtilities> = [];
	#end

	private var currentPlayerCharacter:Character;
	private var currentOpponentCharacter:Character;

	private var currentPlayerStrums:FlxTypedGroup<StrumNote>;
	private var currentOpponentStrums:FlxTypedGroup<StrumNote>;

	public var uiSkin:UISkin;
	public var storedUISkins:Map<String, UISkin> = new Map<String, UISkin>();
	private var uiSkinChanges:Array<Dynamic> = [];

	public var badChart:Bool = false;

	public var usedLuaCameras:Bool = false;

	public static var inMultiplayerSession:Bool = false;
	public var multiplayerSessionEndcheck:Bool = false;
	var fdgod2PlayerSide:Int = -1;

	public var songHasDodges:Bool = false;

	var playSpamSections:Bool = false;
	private var spamSectionData:Array<SpamSection> = [
		{song: "Light It Up", start: 28, end: 36},
		{song: "Ruckus", start: 140, end: 156},
		{song: "Target Practice", start: 144, end: 160},
		{song: "Burnout", start: 92, end: 105},
		{song: "Sporting", start: 96, end: 128},
		{song: "Boxing Match", start: 240, end: 272},
		{song: "Fisticuffs", start: 80, end: 96},
		{song: "Blastout", start: 48, end: 64},
		{song: "Immortal", start: 128, end: 144},
		{song: "King Hit", start: 216, end: 232},
		{song: "TKO", start: 92, end: 112},
		{song: "Rejected", start: 122, end: 155},
		//["Ruckus", 140, 156, null, null, null],
		//["Target Practice", 144, 160, null, null, null],
		//["Burnout", 92, 104, null, null, null],
		//["Sporting", 96, 128, null, null, null],
		//["Boxing Match", 240, 272, null, null, null],
		//["Fisticuffs", 240, 272],
		//["Blastout", 240, 272],
		//["Immortal", 240, 272],
		//["King Hit", 240, 272]
	];
	function clearNotes()
	{
		var i:Int = PlayState.instance.unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = PlayState.instance.unspawnNotes[i];
			daNote.active = false;
			daNote.visible = false;
			daNote.kill();
			unspawnNotes.remove(daNote);
			daNote.destroy();
			--i;
		}
		i = PlayState.instance.notes.length - 1;
		while (i >= 0) {
			var daNote:Note = PlayState.instance.notes.members[i];
			daNote.active = false;
			daNote.visible = false;
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
			--i;
		}
	}
	function loadSpamSectionStuff()
	{
		trace('loading voiid rush');
		clearNotes();
		for (i in spamSectionData)
		{
			i.inst = new FlxSound().loadEmbedded(Paths.inst(i.song, (SONG.specialAudioName == null ? storyDifficultyStr.toLowerCase() : SONG.specialAudioName)));
			FlxG.sound.list.add(i.inst);
			i.vocals = new FlxSound().loadEmbedded(Paths.voices(i.song, (SONG.specialAudioName == null ? storyDifficultyStr.toLowerCase() : SONG.specialAudioName)));
			FlxG.sound.list.add(i.vocals);
			i.chart = Song.loadFromJson(i.song + "-"+diffLoadedInWith, i.song);
			createNotes(i.chart.notes, [i.start, i.end]);
		}
		unspawnNotes.sort(sortByShit);
		//check chart after loading all notes
		if (!ChartChecker.checkChart(PlayState.SONG.song.toLowerCase(), storyDifficultyStr.toLowerCase(), unspawnNotes))
		{
			isCheating = true;
			if (hasMechAndModchartsEnabled) //turning off mechs would remove note types and flag the system so only do it theyre enabled
			{
				Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "Chart is invalid, score will not be saved."));
				badChart = true;
				inMultiplayerSession = false; //force dc if edited chart
			}
			trace('bad chart');
		}
		else 
			trace('good chart');

		clearNotes();
	}
	var currentSpamSection:Int = -1;
	function swtichSpamSong()
	{
		currentSpamSection++;
		FlxG.sound.music.fadeOut(1, 0);
		vocals.fadeOut(1, 0);
		Conductor.changeBPM(spamSectionData[currentSpamSection].chart.bpm);
		FlxG.sound.music = spamSectionData[currentSpamSection].inst;
		vocals = spamSectionData[currentSpamSection].vocals;
		Conductor.songPosition = ((Conductor.crochet*4)*spamSectionData[currentSpamSection].start)-1000;
		FlxG.sound.music.time = Conductor.songPosition;
		vocals.time = Conductor.songPosition;

		clearNotes();

		var oldKeyCount:Int = SONG.playerKeyCount;
		var oldPlayer1:String = SONG.player1;
		var oldPlayer2:String = SONG.player2;
		SONG = spamSectionData[currentSpamSection].chart;
		createNotes(spamSectionData[currentSpamSection].chart.notes, 
			[spamSectionData[currentSpamSection].start, spamSectionData[currentSpamSection].end]);
		unspawnNotes.sort(sortByShit);
		if (SONG.playerKeyCount != oldKeyCount) //mania change
		{
			playerStrums.clear();
			enemyStrums.clear();
			strumLineNotes.clear();
			if(utilities.Options.getData("middlescroll"))
			{
				if(characterPlayingAs == 0)
				{
					generateStaticArrows(50, false);
					generateStaticArrows(0.5, true);
				}
				else 
				{
					generateStaticArrows(0.5, false);
					generateStaticArrows(50, true);
				}
	
			}
			else
			{
				generateStaticArrows(0, false);
				generateStaticArrows(1, true);
			}
			#if linc_luajit
			for (i in 0...strumLineNotes.length)
			{
				var member = strumLineNotes.members[i];
	
				setLuaVar("defaultStrum" + i + "X", member.x);
				setLuaVar("defaultStrum" + i + "Y", member.y);
				setLuaVar("defaultStrum" + i + "Angle", member.angle);
			}
			#end
		}
		refreshBinds();

		SONG.song = "Voiid Rush";
		

		resyncVocals();
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.fadeIn(1, 0, 1);
		vocals.fadeIn(1, 0, 1);
		songLength = FlxG.sound.music.length;

		executeALuaState("switchSpamSong", [spamSectionData[currentSpamSection].song]);
	}

	public function refreshBinds()
	{
		binds = NoteHandler.getBinds(characterPlayingAs == 0 ? SONG.playerKeyCount : SONG.keyCount);
		controllerBinds = NoteHandler.getControllerBinds(characterPlayingAs == 0 ? SONG.playerKeyCount : SONG.keyCount);
	}

	public function reorderCameras(?newCam:FlxCamera = null)
	{
		var cameras = FlxG.cameras.list.copy();
		for (c in cameras)
		{
			FlxG.cameras.remove(c, false);
		}
		for (i in 0...cameras.length)
		{
			if (i == cameras.length-1 && newCam != null)
			{
				FlxG.cameras.add(newCam, false);
			}
			FlxG.cameras.add(cameras[i], false);
		}
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
	}

	override public function create()
	{
		#if linc_luajit
		ModchartUtilities.lua_Characters.clear();
		ModchartUtilities.lua_Sounds.clear();
		ModchartUtilities.lua_Sprites.clear();
		#end
		tweenManager = new FlxTweenManager();

		funnyTimeBarStyle = utilities.Options.getData("timeBarStyle");

		if(hitSoundString != "none")
			hitsound = FlxG.sound.load(Paths.sound("hitsounds/" + Std.string(hitSoundString).toLowerCase(), "shared"));

		/*switch(utilities.Options.getData("playAs"))
		{
			case "bf":
				characterPlayingAs = 0;
			case "opponent":
				characterPlayingAs = 1;
			case "both":
				characterPlayingAs = -1;
			default:
				characterPlayingAs = 0;
		}*/

		characterPlayingAs = 0;
		if (utilities.Options.getData("opponentPlay") && !inMultiplayerSession)
			characterPlayingAs = 1;

		//testing
		#if mobile
		//utilities.Options.setData(true, "noDeath");
		//utilities.Options.setData(false, "botplay");
		#end

		if (inMultiplayerSession)
		{
			utilities.Options.setData(false, "botplay");
			utilities.Options.setData(true, "mechanics");
			utilities.Options.setData(true, "modcharts");
			//cpuControlled = true;
			canPause = false;
			FlxG.autoPause = false;

			characterPlayingAs = (GameJoltStuff.ServerListSubstate.currentPlayer == 1 ? 0 : 1);

			multiplayerSessionEndcheck = true;

			if (SONG.song.toLowerCase().contains('final destination') && storyDifficultyStr.toLowerCase() == 'voiid god')
			{
				fdgod2PlayerSide = characterPlayingAs;
				characterPlayingAs = 0;
			}
		}

		if (SONG.song.toLowerCase() == 'revenge' && SONG.playerKeyCount == 7)
			playerManiaOffset = 1; //hardcoding it fuck you

		ogPlayerKeyCount = SONG.playerKeyCount;
		ogKeyCount = SONG.keyCount;

		/*if(characterPlayingAs == 1)
		{
			var oldRegKeyCount = SONG.keyCount;
			var oldPlrKeyCount = SONG.playerKeyCount;

			SONG.keyCount = oldPlrKeyCount;
			SONG.playerKeyCount = oldRegKeyCount;
		}*/

		instance = this;

		if(utilities.Options.getData("botplay"))
			hasUsedBot = true;

		//if(utilities.Options.getData("noDeath"))
			//hasUsedBot = true;

		//if(characterPlayingAs != 0)
			//hasUsedBot = true;

		if(playingReplay)
		{
			hasUsedBot = true;

			Conductor.offset = replay.offset;
			
			utilities.Options.setData(replay.judgementTimings, "judgementTimings");
			utilities.Options.setData(replay.ghostTapping, "ghostTapping");
			utilities.Options.setData(replay.antiMash, "antiMash");

			for(i in 0...replay.inputs.length)
			{
				var input = replay.inputs[i];

				if(input.length > 3)
					inputs.push([Std.int(input[0]), FlxMath.roundDecimal(input[1], 2), Std.int(input[2]), FlxMath.roundDecimal(input[3], 2)]);
				else
					inputs.push([Std.int(input[0]), FlxMath.roundDecimal(input[1], 2), Std.int(input[2])]);
			}
		}

		for(i in 0...2)
		{
			var sound = FlxG.sound.load(Paths.sound('missnote' + Std.string((i + 1))), 0.2);
			missSounds.push(sound);
		}

		if (SONG.song.toLowerCase() == 'voiid rush')
		{
			SONG.player1 = "Wiik1BFRTX";
			SONG.player2 = "Wiik2VoiidMatt";
			SONG.gf = 'Wiik1GFRTX';
			SONG.stage = "VoiidArena";
			SONG.modchartPath = "";
			playSpamSections = true;
		}
			



		refreshBinds();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camTransition = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.add(camTransition, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camTransition.bgColor.alpha = 0;

		playingFDGOD = SONG.song.toLowerCase().contains('final destination') && storyDifficultyStr.toLowerCase() == 'voiid god';
		hasMechAndModchartsEnabled = utilities.Options.getData("mechanics") && utilities.Options.getData("modcharts");
		Main.noGPU = false;
		if (SONG.song == 'Average Voiid Song')
		{
			shouldKillNotes = false;
			Main.noGPU = true;
		}
		if (utilities.Options.getData("forceDisableScripts"))
		{
			hasMechAndModchartsEnabled = false;
			isCheating = true;
		}

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		#if !sys
		songMultiplier = 1;
		#end

		if(songMultiplier < 0.25)
			songMultiplier = 0.25;

		Conductor.timeScale = SONG.timescale;

		Conductor.mapBPMChanges(SONG, songMultiplier);
		Conductor.changeBPM(SONG.bpm, songMultiplier);

		previousScrollSpeedLmao = SONG.speed;

		SONG.speed /= songMultiplier;

		if(SONG.speed < 0.1 && songMultiplier > 1)
			SONG.speed = 0.1;

		speed = SONG.speed;

		if(utilities.Options.getData("useCustomScrollSpeed"))
			speed = utilities.Options.getData("customScrollSpeed") / songMultiplier;

		startSpeed = speed;

		Conductor.recalculateStuff(songMultiplier);
		Conductor.safeZoneOffset *= songMultiplier;

		noteBG = new FlxSprite(0,0);
		noteBG.cameras = [camHUD];
		noteBG.makeGraphic(1,1000,FlxColor.BLACK);

		add(noteBG);

		if(SONG.stage == null)
		{
			switch(storyWeek)
			{
				case 0 | 1:
					SONG.stage = 'stage';
				case 2:
					SONG.stage = 'spooky';
				case 3:
					SONG.stage = 'philly';
				case 4:
					SONG.stage = 'limo';
				case 5:
					SONG.stage = 'mall';
				case 6:
					SONG.stage = 'school';
				default:
					SONG.stage = 'stage';
			}

			if(SONG.song.toLowerCase() == "winter horrorland")
				SONG.stage = 'evil-mall';

			if(SONG.song.toLowerCase() == "roses")
				SONG.stage = 'school-mad';

			if(SONG.song.toLowerCase() == "thorns")
				SONG.stage = 'evil-school';
		}

		if(Std.string(SONG.ui_Skin) == "null")
			SONG.ui_Skin = SONG.stage == "school" || SONG.stage == "school-mad" || SONG.stage == "evil-school" ? "pixel" : "default";

		// yo poggars
		if(SONG.ui_Skin == "default")
			SONG.ui_Skin = utilities.Options.getData("uiSkin");

		uiSkin = new UISkin(SONG.ui_Skin);
		storedUISkins.set(SONG.ui_Skin, uiSkin);
		uiSkinChanges.push([-FlxMath.MAX_VALUE_FLOAT, SONG.ui_Skin]);

		if(!yoWaitThisIsCharter)
		{
			if(SONG.gf == null)
			{
				switch(storyWeek)
				{
					case 4:
						SONG.gf = 'gf-car';
					case 5:
						SONG.gf = 'gf-christmas';
					case 6:
						SONG.gf = 'gf-pixel';
					default:
						SONG.gf = 'gf';
				}
			}

			/* character time :) */
			gfVersion = SONG.gf;

			if(!utilities.Options.getData("charsAndBGs"))
			{
				gf = new Character(400, 130, "");
				gf.scrollFactor.set(0.95, 0.95);
		
				dad = new Character(100, 100, "");
				boyfriend = new Boyfriend(770, 450, "");
			}
			else
			{
				gf = new Character(400, 130, gfVersion);
				gf.scrollFactor.set(0.95, 0.95);
		
				dad = new Character(100, 100, SONG.player2);
				boyfriend = new Boyfriend(770, 450, SONG.player1);

				bfMap.set(SONG.player1, boyfriend);
				dadMap.set(SONG.player2, dad);
				gfMap.set(gfVersion, gf);
			}

			
			/* end of character time */

			#if discord_rpc
			storyDifficultyText = storyDifficultyStr;
			iconRPC = dad.icon;

			// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
			if (isStoryMode)
				detailsText = "Story Mode: "+wiikDiscordDisplay;
			else
				detailsText = "Freeplay";

			if (inMultiplayerSession)
				detailsText = "Multiplayer";

			// String for when the game is paused
			detailsPausedText = "Paused - " + detailsText;
			
			// Updating Discord Rich Presence.
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, "logo");
			#end

			curStage = SONG.stage;

			if(!utilities.Options.getData("charsAndBGs"))
				stage = new StageGroup("");
			else
				stage = new StageGroup(curStage);

			stageMap.set(stage.stage, stage);

			add(stage);

			defaultCamZoom = stage.camZoom;

			var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

			if(dad.curCharacter.startsWith("gf"))
			{
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			}

			// REPOSITIONING PER STAGE
			if(utilities.Options.getData("charsAndBGs"))
				stage.setCharOffsets();

			if(gf.otherCharacters == null)
			{
				if(gf.coolTrail != null)
					add(gf.coolTrail);

				add(gf);
			}
			else
			{
				for(character in gf.otherCharacters)
				{
					if(character.coolTrail != null)
						add(character.coolTrail);
					
					add(character);
				}
			}

			if(!dad.curCharacter.startsWith("gf"))
				add(stage.infrontOfGFSprites);

			// fuck haxeflixel and their no z ordering or somnething AAAAAAAAAAAAA
			//if(curStage == 'limo' && utilities.Options.getData("charsAndBGs"))
			//	add(stage.limo);

			if(dad.otherCharacters == null)
			{
				if(dad.coolTrail != null)
					add(dad.coolTrail);

				add(dad);
			}
			else
			{
				for(character in dad.otherCharacters)
				{
					if(character.coolTrail != null)
						add(character.coolTrail);

					add(character);
				}
			}

			if(dad.curCharacter.startsWith("gf"))
				add(stage.infrontOfGFSprites);

			/* we do a little trolling */
			var midPos = dad.getMidpoint();
			
			camPos.set(midPos.x + 150 + dad.cameraOffset[0], midPos.y - 100 + dad.cameraOffset[1]);

			switch (dad.curCharacter)
			{
				case 'mom':
					camPos.y = midPos.y;
				case 'senpai':
					camPos.y = midPos.y - 430;
					camPos.x = midPos.x - 100;
				case 'senpai-angry':
					camPos.y = midPos.y - 430;
					camPos.x = midPos.x - 100;
			}

			if(boyfriend.otherCharacters == null)
			{
				if(boyfriend.coolTrail != null)
					add(boyfriend.coolTrail);
				
				add(boyfriend);
			}
			else
			{
				for(character in boyfriend.otherCharacters)
				{
					if(character.coolTrail != null)
						add(character.coolTrail);

					add(character);
				}
			}

			add(stage.foregroundSprites);

			Conductor.songPosition = -5000;

			strumLine = new FlxSprite(0, 100).makeGraphic(FlxG.width, 10);

			if (utilities.Options.getData("downscroll"))
				strumLine.y = FlxG.height - 100;

			strumLine.scrollFactor.set();

			strumLineNotes = new FlxTypedGroup<StrumNote>();

			playerStrums = new FlxTypedGroup<StrumNote>();
			enemyStrums = new FlxTypedGroup<StrumNote>();
			splashes = new FlxTypedGroup<NoteSplash>();

			generateEvents();
			generateSong(SONG.song);
			if (playSpamSections)
			{
				loadSpamSectionStuff();
			}

			camFollow = new FlxObject(0, 0, 1, 1);

			camFollow.setPosition(camPos.x, camPos.y);

			if (prevCamFollow != null)
			{
				camFollow = prevCamFollow;
				prevCamFollow = null;
			}

			if(utilities.Options.getData("charsAndBGs"))
			{
				FlxG.camera.follow(camFollow, LOCKON, 0.04 * (60 / Main.display.currentFPS));
				FlxG.camera.zoom = defaultCamZoom;
				FlxG.camera.focusOn(camFollow.getPosition());
			}

			FlxG.fixedTimestep = false;

			#if linc_luajit
			executeModchart = !(PlayState.SONG.modchartPath == '' || PlayState.SONG.modchartPath == null);

			if (utilities.Options.getData("forceDisableScripts"))
				executeModchart = false;
	
			if(executeModchart)
			{
				if(Assets.exists(Paths.lua("modcharts/" + PlayState.SONG.modchartPath)))
				{
					luaModchart = ModchartUtilities.createModchartUtilities();
					executeALuaState("create", [PlayState.SONG.song.toLowerCase()], MODCHART);
				}
			}



			stage.createLuaStuff();

			executeALuaState("create", [stage.stage], STAGE);
			#end
			#if (sys && linc_luajit)
			if(Assets.exists(Paths.file("globalScripts/")) && !utilities.Options.getData("forceDisableScripts"))
			{
				//trace('found globals folder');
				#if !mobile 
				var folder:String = PolymodAssets.getPath(Paths.file("globalScripts/"));
				#else 
				var folder:String = SUtil.getStorageDirectory() + "mods/Voiid Chronicles/globalScripts/";
				#end

				//trace(folder);

				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua'))
					{
						if(!event_luas.exists(file))
						{
							event_luas.set(file, ModchartUtilities.createModchartUtilities(folder + file));
							generatedSomeDumbEventLuas = true;
						}
					}
				}
			}

			#if mobile 
			if (!utilities.Options.getData("forceDisableScripts"))
			{
				var scriptList = CoolUtil.coolTextFile(Paths.txt('globalScriptList'));
				for (scriptName in scriptList)
				{
					if (!scriptName.startsWith("~"))
					{
						if(!event_luas.exists(scriptName))
						{
							event_luas.set(scriptName, ModchartUtilities.createModchartUtilities(SUtil.getStorageDirectory() + "mods/Voiid Chronicles/globalScripts/" + scriptName + ".lua"));
							generatedSomeDumbEventLuas = true;
						}
					}
				}
			}

			#end

			if((Assets.exists(Paths.file("data/song data/"+SONG.song+"/")) 
				#if mobile
				|| FileSystem.exists(SUtil.getStorageDirectory() + "mods/Voiid Chronicles/data/song data/"+SONG.song+"/") 
				#end
				) && !utilities.Options.getData("forceDisableScripts"))
			{
				//trace('found globals folder');
				#if !mobile 
				var folder:String = PolymodAssets.getPath(Paths.file("data/song data/"+SONG.song+"/"));
				#else 
				var folder:String = SUtil.getStorageDirectory() + "mods/Voiid Chronicles/data/song data/"+SONG.song+"/";
				#end
				

				//trace(folder);

				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua'))
					{
						if(!event_luas.exists(file))
						{
							event_luas.set(file, ModchartUtilities.createModchartUtilities(folder + file));
							generatedSomeDumbEventLuas = true;
						}
					}
				}
			}
			#end

			
			gameHUD = new GameHUD();
			add(gameHUD);
			gameHUD.cameras = [camHUD];
			gameHUD.setCharacters(boyfriend.icon, dad.icon, boyfriend.barColor, dad.barColor);
			gameHUD.createHUD(SONG.ui_Skin, SONG.healthBar_Skin);

			add(strumLineNotes);
			add(camFollow);

			add(notes);

			if (characterPlayingAs == 1)
			{
				currentPlayerCharacter = dad;
				currentPlayerStrums = enemyStrums;
				currentOpponentCharacter = boyfriend;
				currentOpponentStrums = playerStrums;
			}
			else 
			{
				currentPlayerCharacter = boyfriend;
				currentPlayerStrums = playerStrums;
				currentOpponentCharacter = dad;
				currentOpponentStrums = enemyStrums;
			}

			strumLineNotes.cameras = [camHUD];
			notes.cameras = [camHUD];
			//healthBar.cameras = [camHUD];
			//healthBarBG.cameras = [camHUD];
			//iconP1.cameras = [camHUD];
			//iconP2.cameras = [camHUD];
			//scoreTxt.cameras = [camHUD];

			//if(utilities.Options.getData("sideRatings") == true)
				//ratingText.cameras = [camHUD];

			if (utilities.Options.getData("breakTimer"))
			{
				var noteTimer:ui.NoteTimer = new ui.NoteTimer(this);
				noteTimer.cameras = [camHUD];
				add(noteTimer);
			}

			startingSong = true;

			var cutscenePlays = utilities.Options.getData("cutscenePlaysOn");

			playCutsceneLmao = (!playingReplay && ((isStoryMode && cutscenePlays == "story") || (!isStoryMode && cutscenePlays == "freeplay") || (cutscenePlays == "both")) && !fromPauseMenu);
			playCutsceneOnPauseLmao = !playingReplay && ((isStoryMode && cutscenePlays == "story") || (!isStoryMode && cutscenePlays == "freeplay") || (cutscenePlays == "both"));

			

			if (playCutsceneLmao && !inMultiplayerSession)
			{
				if(SONG.cutscene != null && SONG.cutscene != "")
				{
					cutscene = CutsceneUtil.loadFromJson(SONG.cutscene);
					if (cutscene != null)
					{
						switch(cutscene.type.toLowerCase())
						{
							case "video":
								startVideo(cutscene.videoPath, cutscene.videoExt, false);
							case "dialogue":
								var box:DialogueBox = new DialogueBox(cutscene);
								box.scrollFactor.set();
								box.finish_Function = function() { bruhDialogue(false); };
								box.cameras = [camHUD];
								inCutscene = true;
	
								startDialogue(box, false);
							case "image": 
								if (cutscene.image != null)
								{
									waitingForAccept = true;
									//paused = true;
									inCutscene = true;
	
									camOther.flash(FlxColor.BLACK, 1);
									mechanicsImage = new FlxSprite(0,0).loadGraphic(Paths.image(cutscene.image));
									mechanicsImage.setGraphicSize(1280,720);
									mechanicsImage.updateHitbox();
									mechanicsImage.screenCenter();
									mechanicsImage.cameras = [camOther];
									add(mechanicsImage);
								}
							default:
								startCountdown();
						}
					}
					else 
						startCountdown();

					
				}
				else
					startCountdown();
			}
			else
			{
				switch (curSong.toLowerCase())
				{
					default:
						if (inMultiplayerSession)
						{
							GameJoltStuff.ServerListSubstate.clients[GameJoltStuff.ServerListSubstate.currentPlayer].playerLoaded = true;
							GameJoltStuff.ServerListSubstate.updateServer();
						}
						else 
						{
							startCountdown();
						}
				}
			}

			// WINDOW TITLE POG
			MusicBeatState.windowNameSuffix = " - " + SONG.song + " " + (isStoryMode ? "(Story Mode)" : "(Freeplay)");

			fromPauseMenu = false;

			if(utilities.Options.getData("sideRatings") == true)
				updateRatingText();

			for (event in events) //needed to move it here because it would break some scripts
			{
				executeALuaState("onEventLoaded", [event[0], event[1], event[2], event[3]]);
			}

			if (!ChartChecker.checkEvents(PlayState.SONG.song.toLowerCase(), storyDifficultyStr.toLowerCase(), events))
			{
				isCheating = true;
				if (hasMechAndModchartsEnabled) //turning off mechs would remove note types and flag the system so only do it theyre enabled
				{
					Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "Events are invalid, score will not be saved."));
					badChart = true;
					inMultiplayerSession = false; //force dc if edited chart
				}
				trace('bad events');
			}

			var judgementTimings:Array<Float> = utilities.Options.getData("judgementTimings");

			//too high
			if (judgementTimings[0] > 25 || judgementTimings[1] > 50 || judgementTimings[2] > 90 || judgementTimings[3] > 135)
			{
				trace('judgements are too high!!');
				isCheating = true;
				Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "Judgements are too high, score will not be saved."));
				inMultiplayerSession = false; //force dc
			}
		}

		super.create();

		if (!inCutscene && !inMultiplayerSession)
			executeALuaState("createPost", []);

		#if desktop
		if (utilities.Options.getData("modcharts") && SONG.song.toLowerCase() == 'REDACTED')
			FlxTransWindow.setupTransparentWindow();
		#end

		calculateAccuracy();
	}

	private function generateEvents()
	{

		baseEvents = [];
		events = [];

		if(SONG.events.length > 0)
		{
			for(event in SONG.events)
			{
				baseEvents.push(event);
				events.push(event);
			}
		}

		if(Assets.exists(Paths.songEvents(SONG.song, diffLoadedInWith)) && !chartingMode)
		{
			trace(Paths.songEvents(SONG.song.toLowerCase(), storyDifficultyStr.toLowerCase()));

			var eventFunnies:Array<Array<Dynamic>> = Song.parseJSONshit(Assets.getText(Paths.songEvents(SONG.song, diffLoadedInWith))).events;

			for(event in eventFunnies)
			{
				baseEvents.push(event);
				events.push(event);
			}
		}
		if (events.length > 0)
		{
			events.sort(function(a, b){
				if (a[1] < b[1])
					return -1;
				else if (a[1] > b[1])
					return 1;
				else
					return 0;
			});
		}

		for(event in events)
		{
			var map:Map<String, Dynamic>;

			switch(event[2].toLowerCase())
			{
				case "dad" | "opponent" | "player2" | "1":
					map = dadMap;
				case "gf" | "girlfriend" | "player3" | "2":
					map = gfMap;
				default:
					map = bfMap;
			}

			

			// cache shit
			if(utilities.Options.getData("charsAndBGs"))
			{
				if(event[0].toLowerCase() == "change character" && !map.exists(event[3]))
				{
					var funnyCharacter:Character;

					if(map == bfMap)
						funnyCharacter = new Boyfriend(100, 100, event[3]);
					else
						funnyCharacter = new Character(100, 100, event[3]);

					funnyCharacter.alpha = 0.00001;
					add(funnyCharacter);

					map.set(event[3], funnyCharacter);

					if(funnyCharacter.otherCharacters != null)
					{
						for(character in funnyCharacter.otherCharacters)
						{
							character.alpha = 0.00001;
							add(character);
						}
					}

					trace(funnyCharacter.curCharacter);
					trace(event[3]);
				}

				if(event[0].toLowerCase() == "change stage" && !stageMap.exists(event[2]) && Options.getData("preloadChangeBGs"))
				{
					var funnyStage = new StageGroup(event[2]);
					funnyStage.visible = false;

					stageMap.set(event[2], funnyStage);

					trace(funnyStage.stage);
				}

				if (event[0].toLowerCase() == "change ui skin")
				{
					if (!storedUISkins.exists(event[2]))
					{
						var uiS:UISkin = new UISkin(event[2]);
						storedUISkins.set(event[2], uiS);
					}

					uiSkinChanges.push([event[1], event[2]]);
				}
				if (event[0].toLowerCase() == "punch" || event[0].toLowerCase() == "slash")
					songHasDodges = true;
			}

			if (!utilities.Options.getData("forceDisableScripts"))
			{
				#if linc_luajit
				if(!event_luas.exists(event[0].toLowerCase()) && (Assets.exists(Paths.lua("event data/" + event[0].toLowerCase())) 
					#if mobile
					|| FileSystem.exists(SUtil.getStorageDirectory() + Paths.lua("event data/" + event[0].toLowerCase()))
					#end
				) )
				{
					#if mobile 
					event_luas.set(event[0].toLowerCase(), ModchartUtilities.createModchartUtilities(SUtil.getStorageDirectory() + Paths.lua("event data/" + event[0].toLowerCase())));
					#else
					event_luas.set(event[0].toLowerCase(), ModchartUtilities.createModchartUtilities(PolymodAssets.getPath(Paths.lua("event data/" + event[0].toLowerCase()))));
					#end
					generatedSomeDumbEventLuas = true;
				}
				#end
			}

			//executeALuaState("onEventLoaded", [event[0], event[1], event[2], event[3]]);

			
		}
	}

	public static var playCutsceneLmao:Bool = false;
	public static var playCutsceneOnPauseLmao:Bool = false;

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function startDialogue(?dialogueBox:DialogueBox, ?endSongVar:Bool = false):Void
	{
		if(endSongVar)
		{
			paused = true;
			canPause = false;
			switchedStates = true;
			endingSong = true;
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			trace("Start Dialogue");

			if (dialogueBox != null)
				add(dialogueBox);
			else
			{
				if(cutscene.cutsceneAfter == null)
				{
					if(!endSongVar)
						startCountdown();
					else
						openSubState(new ResultsScreenSubstate());
				}
				else
				{
					var oldcutscene = cutscene;

					cutscene = CutsceneUtil.loadFromJson(oldcutscene.cutsceneAfter);

					switch(cutscene.type.toLowerCase())
					{
						case "video":
							startVideo(cutscene.videoPath, cutscene.videoExt, endSongVar);
	
						case "dialogue":
							var box:DialogueBox = new DialogueBox(cutscene);
							box.scrollFactor.set();
							box.finish_Function = function() { bruhDialogue(endSongVar); };
							box.cameras = [camHUD];
							inCutscene = true;
							startDialogue(box, endSongVar);
	
						default:
							if(!endSongVar)
								startCountdown();
							else
								openSubState(new ResultsScreenSubstate());
					}
				}
			}
		});
	}

	public function startVideo(name:String, ?ext:String, ?endSongVar:Bool = false):Void {
		#if BIT_64
		#if VIDEOS_ALLOWED
		if(endSongVar)
		{
			paused = true;
			canPause = false;
			switchedStates = true;
			endingSong = true;
		}
		
		var foundFile:Bool = false;
		var fileName:String = #if sys Sys.getCwd() + PolymodAssets.getPath(Paths.video(name, ext)) #else Paths.video(name, ext) #end;

		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);

			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);

				if(endingSong) {
					openSubState(new ResultsScreenSubstate());
				} else {
					if(cutscene.cutsceneAfter == null)
					{
						if(!endSongVar)
							startCountdown();
						else
							openSubState(new ResultsScreenSubstate());
					}
					else
					{
						var oldcutscene = cutscene;

						cutscene = CutsceneUtil.loadFromJson(oldcutscene.cutsceneAfter);

						switch(cutscene.type.toLowerCase())
						{
							case "video":
								startVideo(cutscene.videoPath, cutscene.videoExt, endSongVar);
		
							case "dialogue":
								var box:DialogueBox = new DialogueBox(cutscene);
								box.scrollFactor.set();
								box.finish_Function = function() { bruhDialogue(endSongVar); };
								box.cameras = [camHUD];
		
								startDialogue(box, endSongVar);
		
							default:
								if(!endSongVar)
									startCountdown();
								else
									openSubState(new ResultsScreenSubstate());
						}
					}
				}
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end

		if(endingSong) {
			openSubState(new ResultsScreenSubstate());
		} else { #end
			if(!endSongVar)
				startCountdown();
			else
				openSubState(new ResultsScreenSubstate());
		#if BIT_64
		}
		#end
	}

	function bruhDialogue(?endSongVar:Bool = false):Void
	{
		if(cutscene.cutsceneAfter == null)
		{
			if(!endSongVar)
				startCountdown(true);
			else
				openSubState(new ResultsScreenSubstate());
		}
		else
		{
			var oldcutscene = cutscene;

			cutscene = CutsceneUtil.loadFromJson(oldcutscene.cutsceneAfter);

			switch(cutscene.type.toLowerCase())
			{
				case "video":
					startVideo(cutscene.videoPath, cutscene.videoExt, endSongVar);

				case "dialogue":
					var box:DialogueBox = new DialogueBox(cutscene);
					box.scrollFactor.set();
					box.finish_Function = function() { bruhDialogue(endSongVar); };
					box.cameras = [camHUD];
					inCutscene = true;

					startDialogue(box, endSongVar);

				default:
					if(!endSongVar)
						startCountdown(true);
					else
						openSubState(new ResultsScreenSubstate());
			}
		}
	}

	var startTimer:FlxTimer;

	public var playCountdown:Bool = true;

	function startCountdown(fromCutscene:Bool = false):Void
	{
		inCutscene = false;
		paused = false;
		canPause = !inMultiplayerSession;

		if(utilities.Options.getData("middlescroll"))
		{
			if(characterPlayingAs == 0)
			{
				generateStaticArrows(50, false);
				generateStaticArrows(0.5, true);
			}
			else 
			{
				generateStaticArrows(0.5, false);
				generateStaticArrows(50, true);
			}

		}
		else
		{
			//if(characterPlayingAs == 0)
			//{
				generateStaticArrows(0, false);
				generateStaticArrows(1, true);
			//}
			//else
			//{
			//	generateStaticArrows(1, false);
			//	generateStaticArrows(0, true);
			//}
		}
		#if mobile
		mobileControls = new MobileControls();
		mobileControls.generateButtons(characterPlayingAs == 0 ? SONG.playerKeyCount : SONG.keyCount, songHasDodges);
		mobileControls.cameras = [camTransition];
		add(mobileControls);
		#end


		startedCountdown = true;
		Conductor.songPosition = 0;
		if (playCountdown)
			Conductor.songPosition -= Conductor.crochet * 5;
		else
			Conductor.songPosition -= 1000;

		var swagCounter:Int = 0;

		#if linc_luajit
		if(executeModchart && luaModchart != null)
			luaModchart.setupTheShitCuzPullRequestsSuck();

		if(stage.stageScript != null)
			stage.stageScript.setupTheShitCuzPullRequestsSuck();

		for(i in 0...strumLineNotes.length)
		{
			var member = strumLineNotes.members[i];

			setLuaVar("defaultStrum" + i + "X", member.x);
			setLuaVar("defaultStrum" + i + "Y", member.y);
			setLuaVar("defaultStrum" + i + "Angle", member.angle);
		}

		executeALuaState("start", [SONG.song.toLowerCase()], BOTH, [stage.stage]);
		#end

		if (fromCutscene || inMultiplayerSession)
			executeALuaState("createPost", []);

		if (playCountdown)
		{
			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
				{
					dad.dance(altAnim);
					gf.dance();
					boyfriend.dance();
		
					var introAssets:Array<String> = [
						"ui skins/" + SONG.ui_Skin + "/countdown/ready",
						"ui skins/" + SONG.ui_Skin + "/countdown/set",
						"ui skins/" + SONG.ui_Skin + "/countdown/go"
					];
		
					var altSuffix = SONG.ui_Skin == 'pixel' ? "-pixel" : "";
		
					switch (swagCounter)
					{
						case 0:
							FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
						case 1:
							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAssets[0], 'shared'));
							ready.scrollFactor.set();
							ready.updateHitbox();
		
							ready.setGraphicSize(Std.int(ready.width * Std.parseFloat(uiSkin.ui_Settings.get("globalScale")) * Std.parseFloat(uiSkin.ui_Settings.get("countdownScale"))));
							ready.updateHitbox();
		
							ready.screenCenter();
							add(ready);
							FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									ready.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
						case 2:
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAssets[1], 'shared'));
							set.scrollFactor.set();
							set.updateHitbox();
		
							set.setGraphicSize(Std.int(set.width * Std.parseFloat(uiSkin.ui_Settings.get("globalScale")) * Std.parseFloat(uiSkin.ui_Settings.get("countdownScale"))));
							set.updateHitbox();
		
							set.screenCenter();
							add(set);
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									set.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
						case 3:
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAssets[2], 'shared'));
							go.scrollFactor.set();
							go.updateHitbox();
		
							go.setGraphicSize(Std.int(go.width * Std.parseFloat(uiSkin.ui_Settings.get("globalScale")) * Std.parseFloat(uiSkin.ui_Settings.get("countdownScale"))));
							go.updateHitbox();
		
							go.screenCenter();
							add(go);
							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
						case 4:
					}
		
					swagCounter += 1;
					// generateSong('fresh');
				}, 5);
		}
		else 
		{
			dad.dance(altAnim);
			gf.dance();
			boyfriend.dance();
			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				//stop crashing
			});
		}


	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	var invincible:Bool = false;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.music.play();

		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		#if desktop
		Conductor.recalculateStuff(songMultiplier);
		
		switch (curSong)
		{
			case "Light It Up" | "Ruckus" | "Target Practice":
				curPortrait = "wiik1";
			case "Burnout" | "Sporting" | "Boxing Match" | "Sport Swinging" | "Boxing Gladiators":
				curPortrait = "wiik2";
			case "Flaming Glove" | "Punch And Gun" | "Venom":
				curPortrait = "fg";
			case "Fisticuffs" | "Blastout" | "Immortal" | "King Hit" | "King Hit Wawa":
				curPortrait = "wiik3";
			case "TKO" | "TKO VIP":
				curPortrait = "tko";
			case "Recovery" | "Ignition" | "Last Combat" | "Champion":
				curPortrait = "wiik4";
			case "Sweet Dreams":
				curPortrait = "sweetdreams";
			case "Mat" | "Banger" | "Edgy":
				curPortrait = "wiik100";
			case "Alter Ego" | "Alter Ego VIP":
				curPortrait = "alterego";
			case "Rejected":
				curPortrait = "rejected";
			case "1CORE KILLER":
				curPortrait = "1corekiller";
			case "Average Voiid Song":
			    curPortrait = "averagelordvoiidsong";
			default: 
				curPortrait = "logo";
		}

		// Updating Discord Rich Presence (with Time Left)
		#if discord_rpc
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength / songMultiplier, curPortrait);
		#end
		#end

		if (mechanicsImage != null)
		{
			remove(mechanicsImage);
			mechanicsImage.kill();
			mechanicsImage = null;
		}

		executeALuaState("songStart", []);

		

		if (playSpamSections)
			swtichSpamSong();
		else
			resyncVocals();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm, songMultiplier);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, (SONG.specialAudioName == null ? storyDifficultyStr.toLowerCase() : SONG.specialAudioName)));
		else
			vocals = new FlxSound();

		// LOADING MUSIC FOR CUSTOM SONGS
		if(FlxG.sound.music != null)
			if(FlxG.sound.music.active)
				FlxG.sound.music.stop();

		FlxG.sound.music = new FlxSound().loadEmbedded(Paths.inst(SONG.song, (SONG.specialAudioName == null ? storyDifficultyStr.toLowerCase() : SONG.specialAudioName)));
		FlxG.sound.music.persist = true;

		vocals.persist = false;
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();

		if(Options.getData("invisibleNotes")) // this was really simple lmfao
			notes.visible = false;

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;


		createNotes(noteData);


		if (!playSpamSections)
		{
			if (!ChartChecker.checkChart(PlayState.SONG.song.toLowerCase(), storyDifficultyStr.toLowerCase(), unspawnNotes))
			{
				isCheating = true;
				if (hasMechAndModchartsEnabled) //turning off mechs would remove note types and flag the system so only do it theyre enabled
				{
					Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "Chart is invalid, score will not be saved."));
					badChart = true;
					inMultiplayerSession = false; //force dc if edited chart
				}
				trace('bad chart');


			}
			else 
			{
				if (inMultiplayerSession)
				{
					var p1NoteCount = ChartChecker.getTotalNotes(unspawnNotes, true);
					var p2NoteCount = ChartChecker.getTotalNotes(unspawnNotes, false);

					var totalP1Score:Int = 0;
					var totalP2Score:Int = 0;
					for (i in 0...p1NoteCount)
					{
						var scoreMult:Int = Math.ceil((i+1)/10);
						totalP1Score += Math.floor(400*scoreMult);
					}
					for (i in 0...p2NoteCount)
					{
						var scoreMult:Int = Math.ceil((i+1)/10);
						totalP2Score += Math.floor(400*scoreMult);
					}

					if (characterPlayingAs == 0)
						multiplayerScoreMult = totalP2Score/totalP1Score;

					//trace("total player count " + p1NoteCount);
					//trace("total opponent count " + p2NoteCount);

					//trace("P1 Score Multiplier " + multiplayerScoreMult);

					//trace("total player score " + Math.floor(totalP1Score*multiplayerScoreMult));
					//trace("total opponent score " + totalP2Score);
				}
				trace('good chart');
			}
				
		}

			


		unspawnNotes.sort(sortByShit);
		unspawnNotesCopy = unspawnNotes.copy();

		generatedMusic = true;

		uiSkin = storedUISkins.get(SONG.ui_Skin); //set back to default
	}

	function createNotes(noteData:Array<SwagSection>, allowedSections:Array<Int> = null)
	{
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var doSection:Bool = true;
			if (allowedSections != null)
			{
				if (daBeats < allowedSections[0] || daBeats >= allowedSections[1])
					doSection = false;
			}

			if (doSection)
			{
				Conductor.recalculateStuff(songMultiplier);

				for (songNotes in section.sectionNotes)
				{
					var daStrumTime:Float = songNotes[0] + Conductor.offset + SONG.chartOffset;
	
					for (uiChange in uiSkinChanges)
					{
						if (daStrumTime >= uiChange[0])
						{
							if (storedUISkins.exists(uiChange[1]))
								uiSkin = storedUISkins.get(uiChange[1]); //set correct skin for strumtime
						}
					}
	
					var gottaHitNote:Bool = section.mustHitSection;
	
					if(songNotes[1] >= (!gottaHitNote ? SONG.keyCount : SONG.playerKeyCount))
						gottaHitNote = !section.mustHitSection;
	
					//if(characterPlayingAs == 1)
						//gottaHitNote = !gottaHitNote;
	
					//if(characterPlayingAs == -1)
						//gottaHitNote = true;
	
					var daNoteData:Int = Std.int(songNotes[1] % (SONG.keyCount + SONG.playerKeyCount));
					if (section.mustHitSection && daNoteData >= SONG.playerKeyCount)
					{
						daNoteData -= SONG.playerKeyCount;
						daNoteData %= SONG.keyCount;
					}
					else if (!section.mustHitSection && daNoteData >= SONG.keyCount)
					{
						daNoteData -= SONG.keyCount;
						daNoteData %= SONG.playerKeyCount;
					}
	
					var oldNote:Note;
	
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;
					
					if(!Std.isOfType(songNotes[0], Float) && !Std.isOfType(songNotes[0], Int))
						songNotes[0] = 0;
	
					if(!Std.isOfType(songNotes[1], Int))
						songNotes[1] = 0;
	
					if(!Std.isOfType(songNotes[2], Int) && !Std.isOfType(songNotes[2], Float))
						songNotes[2] = 0;
	
					if(!Std.isOfType(songNotes[3], Int) && !Std.isOfType(songNotes[3], Array))
					{
						if(Std.string(songNotes[3]).toLowerCase() == "hurt note")
							songNotes[4] = "hurt";
						
						songNotes[3] = 0;
					}
	
					if(!Std.isOfType(songNotes[4], String))
						songNotes[4] = "default";
	
					var noteType:String = songNotes[4];
	
					var char:Dynamic = songNotes[3];
	
					var chars:Array<Int> = [];
	
					if(Std.isOfType(char, Array))
					{
						chars = char;
						char = chars[0];
					}
					var badNotes = ["REJECTED_NOTES", 'ParryNote', 'death', 'hurt'];
					var mustHitNotes = ["BoxingMatchPunch", "Wiik3Punch", "Wiik4Sword", "caution", "VoiidBullet"];
					if (!utilities.Options.getData("mechanics"))
					{
						if (mustHitNotes.contains(noteType))
							noteType = "default";
					}
	
					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, char, noteType, null, chars, gottaHitNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);
	
					var susLength:Float = swagNote.sustainLength;
	
					susLength = susLength / Std.int(Conductor.stepCrochet);
					var doPush = true;
	
					if (FlxG.sound.music != null)
					{
						//trace(FlxG.sound.music.length);
						if (daStrumTime > FlxG.sound.music.length+5000) //if a small gap just in case
							doPush = false; //should prevent people from editing audio to end the song early to cheat on leaderboard
					}
					else 
						doPush = false;
	
					
	
					if (!utilities.Options.getData("mechanics"))
					{
						if (badNotes.contains(noteType))
							doPush = false;
					}
					if (doPush)
						unspawnNotes.push(swagNote);
	
					var sustainGroup:Array<Note> = [];
	
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
	
						var sustainNote:Note = new Note(daStrumTime + (Std.int(Conductor.stepCrochet) * susNote) + (Std.int(Conductor.stepCrochet) / FlxMath.roundDecimal(speed, 2)), daNoteData, oldNote, true, char, songNotes[4], null, chars, gottaHitNote);
						sustainNote.scrollFactor.set();
						if (doPush)
							unspawnNotes.push(sustainNote);
	
						sustainNote.mustPress = gottaHitNote;
	
						if (sustainNote.mustPress)
							sustainNote.x += FlxG.width / 2; // general offset
	
						if (doPush)
						{
							sustainGroup.push(sustainNote);
							sustainNote.sustains = sustainGroup;
						}
					}
					if (doPush)
						swagNote.sustains = sustainGroup;
	
					swagNote.mustPress = gottaHitNote;
	
					if (swagNote.mustPress)
						swagNote.x += FlxG.width / 2; // general offset
				}
			}

			

			daBeats += 1;
		}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var noteBG:FlxSprite;
	public var showKeyPopups:Bool = true;
	public var playerManiaOffset:Int = 0;
	private function generateStaticArrows(player:Float, ?isPlayer:Bool = false):Void
	{
		var usedKeyCount = SONG.keyCount;

		if(isPlayer)
			usedKeyCount = SONG.playerKeyCount;

		for (i in 0...usedKeyCount)
		{
			var babyArrow:StrumNote = new StrumNote(0, strumLine.y, i, uiSkin, usedKeyCount, isPlayer);
			babyArrow.loadStrum();
			babyArrow.setupStrumPosition(player);

			/*babyArrow.antialiasing = ui_Settings[3] == "true";

			babyArrow.setGraphicSize(Std.int((babyArrow.width * Std.parseFloat(ui_Settings[0])) * (Std.parseFloat(ui_Settings[2]) - (Std.parseFloat(mania_size[usedKeyCount-1- (isPlayer ? playerManiaOffset : 0)])))));
			babyArrow.updateHitbox();
			
			var animation_Base_Name = NoteVariables.Note_Count_Directions[usedKeyCount - 1][Std.int(Math.abs(i))].toLowerCase();

			babyArrow.animation.addByPrefix('static', animation_Base_Name + " static");
			babyArrow.animation.addByPrefix('pressed', NoteVariables.Other_Note_Anim_Stuff[usedKeyCount - 1][i] + ' press', 24, false);
			babyArrow.animation.addByPrefix('confirm', NoteVariables.Other_Note_Anim_Stuff[usedKeyCount - 1][i] + ' confirm', 24, false);

			babyArrow.scrollFactor.set();
			
			babyArrow.playAnim('static');*/



			/*if (isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}*/

			

			if (isPlayer)
				playerStrums.add(babyArrow);
			else
				enemyStrums.add(babyArrow);

			strumLineNotes.add(babyArrow);

			if(usedKeyCount != 4 && ((isPlayer && characterPlayingAs == 0) || (!isPlayer && characterPlayingAs == 1)) && utilities.Options.getData("extraKeyReminders") && showKeyPopups)
			{
				var doPopup:Bool = true;
				/*if (fdgod2PlayerSide >= 0)
				{
					if ((i < 5 && fdgod2PlayerSide == 0) || (fdgod2PlayerSide == 1 && i >= 5))
					{
						doPopup = false;
						babyArrow.color = 0xFF777777;
					}
				}*/
				//if (playerManiaOffset == 1 && i == Math.floor(usedKeyCount/2))
				//{

				//}
				//else 
				//{
					//var coolWidth = Std.int(40 - ((key_Count - 5) * 2) + (key_Count == 10 ? 30 : 0));
					// funny 4 key math i guess, full num is 2.836842105263158 (width / previous key width thingy which was 38)

				if (doPopup)
				{
					var coolWidth = Math.ceil(babyArrow.width / 2.83684);

					var keyStr = binds[i];
					if (MusicBeatState.usingController)
						keyStr = NoteHandler.formatControllerBind(controllerBinds[i]);

					var keyThingLolShadow = new FlxText((babyArrow.x + (babyArrow.width / 2)) - (coolWidth / 2), babyArrow.y - (coolWidth / 2), coolWidth, keyStr, coolWidth);
					keyThingLolShadow.cameras = [camHUD];
					keyThingLolShadow.color = FlxColor.BLACK;
					keyThingLolShadow.scrollFactor.set();
					add(keyThingLolShadow);
	
					var keyThingLol = new FlxText(keyThingLolShadow.x - 6, keyThingLolShadow.y - 6, coolWidth, keyStr, coolWidth);
					keyThingLol.cameras = [camHUD];
					keyThingLol.scrollFactor.set();
					add(keyThingLol);
	
					FlxTween.tween(keyThingLolShadow, {y: keyThingLolShadow.y + 10, alpha: 0}, 3, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i), onComplete: function(_){
						remove(keyThingLolShadow);
						keyThingLolShadow.kill();
						keyThingLolShadow.destroy();
					}});
	
					FlxTween.tween(keyThingLol, {y: keyThingLol.y + 10, alpha: 0}, 3, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i), onComplete: function(_){
						remove(keyThingLol);
						keyThingLol.kill();
						keyThingLol.destroy();
					}});
				}

				//}

			}
		}

		if(isPlayer && utilities.Options.getData("noteBGAlpha") != 0)
		{
			updateNoteBGPos();
			noteBG.alpha = utilities.Options.getData("noteBGAlpha");
		}
	}

	function updateNoteBGPos()
	{
		if(startedCountdown)
		{
			var bruhVal:Float = 0.0;

			for(note in currentPlayerStrums)
			{
				bruhVal += note.swagWidth + (2 + Std.parseFloat(uiSkin.mania_gap[SONG.playerKeyCount - 1]));
			}

			
	
			noteBG.setGraphicSize(Std.int(currentPlayerStrums.members[currentPlayerStrums.members.length-1].x+currentPlayerStrums.members[currentPlayerStrums.members.length-1].width-currentPlayerStrums.members[0].x), FlxG.height * 2);
			noteBG.updateHitbox();
	
			noteBG.x = currentPlayerStrums.members[0].x;
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * SONG.timescale[0] / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.pause();

			if(vocals != null)
				vocals.pause();

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;

			paused = false;

			#if discord_rpc
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, ((songLength - Conductor.songPosition) / songMultiplier >= 1 ? (songLength - Conductor.songPosition) / songMultiplier : 1), curPortrait);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, curPortrait);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if discord_rpc
		if (health > minHealth && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, ((songLength - Conductor.songPosition) / songMultiplier >= 1 ? (songLength - Conductor.songPosition) / songMultiplier : 1), curPortrait);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, curPortrait);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if discord_rpc
		if (health > minHealth && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, curPortrait);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(!switchedStates)
		{
			if(!(Conductor.songPosition > 20 && FlxG.sound.music.time < 20))
			{
				//trace("SONG POS: " + Conductor.songPosition + " | Musice: " + FlxG.sound.music.time + " / " + FlxG.sound.music.length);

				vocals.pause();
				FlxG.sound.music.pause();
		
				if(FlxG.sound.music.time >= FlxG.sound.music.length)
					Conductor.songPosition = FlxG.sound.music.length;
				else
					Conductor.songPosition = FlxG.sound.music.time;

				vocals.time = Conductor.songPosition;
				
				FlxG.sound.music.play();
				vocals.play();
		
				#if cpp
				@:privateAccess
				{
					lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		
					if (vocals.playing)
						lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
				}
				#end
			}
			else
			{
				while(Conductor.songPosition > 20 && FlxG.sound.music.time < 20)
				{
					trace("SONG POS: " + Conductor.songPosition + " | Musice: " + FlxG.sound.music.time + " / " + FlxG.sound.music.length);

					FlxG.sound.music.time = Conductor.songPosition;
					vocals.time = Conductor.songPosition;
		
					FlxG.sound.music.play();
					vocals.play();
			
					#if cpp
					@:privateAccess
					{
						lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			
						if (vocals.playing)
							lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
					}
					#end
				}
			}
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	public var canFullscreen:Bool = true;
	var switchedStates:Bool = false;

	// give: [noteDataThingy, noteType]
	// get : [xOffsetToUse]
	public var prevPlayerXVals:Map<String, Float> = [];
	public var prevEnemyXVals:Map<String, Float> = [];

	var speed:Float = 1.0;

	#if linc_luajit
	public var generatedSomeDumbEventLuas:Bool = false;
	#end

	public var ratingStr:String = "";

	/**
		Update that runs every 120 frames (for health icon bounce and shit :D)
	**/
	public function fixedUpdate()
	{
		var icon_Zoom_Lerp = 0.045;
		var camera_Zoom_Lerp = 0.025*cameraZoomSpeed;

		if(Main.display.currentFPS < 120)
		{
			icon_Zoom_Lerp = 0.09 / (Main.display.currentFPS / 60);
			camera_Zoom_Lerp = 0.05 / (Main.display.currentFPS / 60)*cameraZoomSpeed;
		}

		gameHUD.updateHealthIconScale(icon_Zoom_Lerp, songMultiplier);
		gameHUD.updateHealthIconPosition();

		if(utilities.Options.getData("cameraZooms") && camZooming && !switchedStates)
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, camera_Zoom_Lerp);
			camHUD.zoom = FlxMath.lerp(camHUD.zoom, defaultHudCamZoom, camera_Zoom_Lerp);
		}
		else if(!utilities.Options.getData("cameraZooms"))
		{
			FlxG.camera.zoom = defaultCamZoom;
			camHUD.zoom = 1;
		}

		#if linc_luajit
		setLuaVar("songPos", Conductor.songPosition);
		setLuaVar("bot", utilities.Options.getData("botplay"));
		setLuaVar("hudZoom", camHUD.zoom);
		setLuaVar("curBeat", currentBeat);
		setLuaVar("cameraZoom", FlxG.camera.zoom);

		executeALuaState("fixedUpdate", [1 / 120]);
		#end
	}

	public var fixedUpdateTimer:Float = 0.0;

	var multiplayerEnding:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (waitingForAccept)
		{
			if (controls.ACCEPT || FlxG.mouse.justPressed)
			{
				waitingForAccept = false;
				if (mechanicsImage != null)
					FlxTween.tween(mechanicsImage, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});
				bruhDialogue(false);
			}
			return;
		}

		if (!startedCountdown && inMultiplayerSession)
		{
			FlxG.autoPause = false;
			gameHUD.updateScoreText(
				"Waiting for other player..."
			);
			GameJoltStuff.ServerListSubstate.clients[GameJoltStuff.ServerListSubstate.currentPlayer].playerLoaded = true; //in case it didnt send properly??
			GameJoltStuff.ServerListSubstate.clients[GameJoltStuff.ServerListSubstate.currentPlayer].song = SONG.song.toLowerCase();
			GameJoltStuff.ServerListSubstate.clients[GameJoltStuff.ServerListSubstate.currentPlayer].diff = storyDifficultyStr;
			if (GameJoltStuff.ServerListSubstate.player1Client.playerLoaded && GameJoltStuff.ServerListSubstate.player2Client.playerLoaded)
				startCountdown();
		}

		
		if (!inMultiplayerSession && multiplayerSessionEndcheck && !multiplayerEnding)
		{
			trace('dc');
			Main.popupManager.addPopup(new MessagePopup(6, 300, 100, "Disconnected from Server"));
			GameJoltStuff.ServerListSubstate.endServer();
			if (startingSong)
			{

			}
			else 
			{
				//endSong();

			}

			#if linc_luajit
			if(executeModchart && luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end


			if (FlxG.sound.music != null)
				FlxG.sound.music.volume = 0;
			if (vocals != null)
				vocals.volume = 0;

			switchedStates = true;
			persistentDraw = true;
			persistentUpdate = false;
			FlxG.switchState(new FreeplayState());
		}

		if (inMultiplayerSession && multiplayerEnded)
		{
			var clientsExist = (GameJoltStuff.ServerListSubstate.player1Client != null && GameJoltStuff.ServerListSubstate.player2Client != null);

			if (clientsExist)
			{
				GameJoltStuff.ServerListSubstate.clients[GameJoltStuff.ServerListSubstate.currentPlayer].playerFinishedSong = true;
				if (GameJoltStuff.ServerListSubstate.player1Client.playerFinishedSong && GameJoltStuff.ServerListSubstate.player2Client.playerFinishedSong)
				{
					if (!multiplayerEnding)
					{
						trace('start timer');
						//the timer should give enough time for both clients to update
						new FlxTimer().start(2, function(timer:FlxTimer)
						{
							trace('timer');
							var p1Win = GameJoltStuff.ServerListSubstate.player1Client.playerScore > GameJoltStuff.ServerListSubstate.player2Client.playerScore;
							var draw = GameJoltStuff.ServerListSubstate.player1Client.playerScore == GameJoltStuff.ServerListSubstate.player2Client.playerScore;
		
							if (!draw)
							{
								if (FlxG.save.data.wins == null)
									FlxG.save.data.wins = 0;
								if (FlxG.save.data.winStreak == null)
									FlxG.save.data.winStreak = 0;
								if (FlxG.save.data.matchesPlayed == null)
									FlxG.save.data.matchesPlayed = 0;
						
								FlxG.save.data.matchesPlayed++;
								if ((p1Win && GameJoltStuff.ServerListSubstate.currentPlayer == 1) || (!p1Win && GameJoltStuff.ServerListSubstate.currentPlayer == 0))
								{
									//you won
									FlxG.save.data.wins++;
									FlxG.save.data.winStreak++;
								}
								else
								{
									//opponent won
									FlxG.save.data.winStreak = 0;
								}
		
								if (p1Win)
								{
									Main.popupManager.addPopup(new MessagePopup(6, 300, 100, GameJoltStuff.ServerListSubstate.player1Client.playerName+" wins!"));
								}
								else 
								{
									Main.popupManager.addPopup(new MessagePopup(6, 300, 100, GameJoltStuff.ServerListSubstate.player2Client.playerName+" wins!"));
								}
								
							}
							else 
							{
								Main.popupManager.addPopup(new MessagePopup(6, 300, 100, "Draw!"));
		
								if (FlxG.save.data.matchesPlayed == null)
									FlxG.save.data.matchesPlayed = 0;
								FlxG.save.data.matchesPlayed++;
							}
							FlxG.save.flush();
		
							GameJoltStuff.ServerListSubstate.endServer();
							endSong();
						});
					}
					multiplayerEnding = true;


					
				}
			}
			else 
			{
				GameJoltStuff.ServerListSubstate.endServer();
				endSong();
			}

			return;
		}
		
		fixedUpdateTimer += elapsed;

		if(fixedUpdateTimer >= 1 / 120)
		{
			fixedUpdate();
			fixedUpdateTimer = 0;
		}

		updateSongInfoText();

		if(stopSong && !switchedStates)
		{
			PlayState.instance.paused = true;

			FlxG.sound.music.volume = 0;
			PlayState.instance.vocals.volume = 0;

			FlxG.sound.music.time = 0;
			PlayState.instance.vocals.time = 0;
			Conductor.songPosition = 0;
		}

		if(!switchedStates)
		{
			if (SONG.notes[Math.floor(curStep / Conductor.stepsPerSection)] != null)
			{
				if (SONG.notes[Math.floor(curStep / Conductor.stepsPerSection)].altAnim)
					altAnim = '-alt';
				else
					altAnim = "";
			}
		}

		if (generatedMusic)
		{
			if (startedCountdown && ((canPause && !inMultiplayerSession) || inMultiplayerSession) && !endingSong && !switchedStates)
			{
				// Song ends abruptly on slow rate even with second condition being deleted, 
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				if (FlxG.sound.music.length - Conductor.songPosition <= 20)
				{
					if (SONG.song != 'Average Voiid Song')
					{
						time = FlxG.sound.music.length;
						endSong();
					}
					else 
					{
						unspawnNotes = unspawnNotesCopy.copy();
						for (n in unspawnNotes)
						{
							n.wasGoodHit = false;
							n.noteWasHit = false;
							n.tooLate = false;
							n.clipRect = null;
							n.alpha = 1;
						}
							
						FlxG.sound.music.time = 0;
						Conductor.songPosition = 0;
						
						songMultiplier *= 1.05;
						Conductor.recalculateStuff(songMultiplier);
						Conductor.safeZoneOffset *= songMultiplier;
					}

				}
				
			}
		}

		#if linc_luajit
		if(((stage.stageScript != null || (luaModchart != null && executeModchart)) || generatedSomeDumbEventLuas) && generatedMusic && !switchedStates && startedCountdown)
		{
			var shaderThing = modding.ModchartUtilities.lua_Shaders;

			for(shaderKey in shaderThing.keys())
			{
				if(shaderThing.exists(shaderKey))
					shaderThing.get(shaderKey).update(elapsed);
			}

			setLuaVar("songPos", Conductor.songPosition);
			setLuaVar("bot", utilities.Options.getData("botplay"));
			setLuaVar("hudZoom", camHUD.zoom);
			setLuaVar("curBeat", currentBeat);
			setLuaVar("cameraZoom", FlxG.camera.zoom);
			executeALuaState("update", [elapsed]);

			if(getLuaVar("showOnlyStrums", "bool"))
			{
				gameHUD.visible = false;
			}
			else
			{
				gameHUD.visible = true;
			}

			var p1 = getLuaVar("strumLine1Visible", "bool");
			var p2 = getLuaVar("strumLine2Visible", "bool");

			for(i in 0...SONG.keyCount)
			{
				strumLineNotes.members[i].visible = p1;
			}

			for(i in 0...SONG.playerKeyCount)
			{
				if (i <= playerStrums.length)
				{
					if (playerStrums.members[i] != null)
						playerStrums.members[i].visible = p2;
				}
			}

			if(!canFullscreen && FlxG.fullscreen)
				FlxG.fullscreen = false;
		}
		#end

		tweenManager.update(elapsed);

		if(!endingSong)
			time = FlxG.sound.music.time;
		else
			time = FlxG.sound.music.length;

		gameHUD.time = time;

		FlxG.camera.followLerp = 0.04 * (60 / Main.display.currentFPS)*cameraSpeed;

		if (startedCountdown && inMultiplayerSession)
		{
			var yourClient = GameJoltStuff.ServerListSubstate.clients[GameJoltStuff.ServerListSubstate.currentPlayer];
			yourClient.playerScore = songScore;
			yourClient.playerMisses = misses;
			yourClient.playerAccuracy = accuracy;
			yourClient.playerHealth = health;
			yourClient.playerCombo = combo;
			yourClient.playerDied = didDie;

			
			
			var strumAnims:Array<String> = []; 
			if (currentPlayerStrums != null)
				for (i in 0...currentPlayerStrums.length)
					if (currentPlayerStrums.members[i].animation.curAnim != null)
						strumAnims.push(currentPlayerStrums.members[i].animation.curAnim.name);
					else 
						strumAnims.push("static");

			yourClient.strumAnims = strumAnims;

			

			var opponentPlayer = 1;
			if (GameJoltStuff.ServerListSubstate.currentPlayer == 1)
				opponentPlayer = 0;
			var opponentClient = GameJoltStuff.ServerListSubstate.clients[opponentPlayer];


			if (currentOpponentStrums != null && fdgod2PlayerSide == -1)
			{
				for (i in 0...currentOpponentStrums.length)
				{
					currentOpponentStrums.members[i].resetAnim = 0;
					if (currentOpponentStrums.members[i].animation.curAnim != null)
					{
						if (currentOpponentStrums.members[i].animation.curAnim.name != opponentClient.strumAnims[i])
							currentOpponentStrums.members[i].playAnim(opponentClient.strumAnims[i], true);
					}
				}
			}
			//trace(opponentClient);

			var player1 = GameJoltStuff.ServerListSubstate.player1Client;
			var player2 = GameJoltStuff.ServerListSubstate.player2Client;

			gameHUD.updateScoreText(
				player1.playerName + (GameJoltStuff.ServerListSubstate.currentPlayer == 1 ? "(YOU)" : "") +
				(player1.playerDied ? " (DIED)" : "") + "\n" +
				"Score: " + player1.playerScore + "\n" +
				"Combo Breaks: " + player1.playerMisses + "\n" +
				"Accuracy: " + player1.playerAccuracy + "%\n" +
				"Combo: " + player1.playerCombo + "\n" +
				Ratings.getRank(player1.playerAccuracy, player1.playerMisses) + "\n"
			);

			gameHUD.updateScoreTextP2(
				player2.playerName + (GameJoltStuff.ServerListSubstate.currentPlayer == 0 ? "(YOU)" : "") +
				(player2.playerDied ? " (DIED)" : "") + "\n" +
				"Score: " + player2.playerScore + "\n" +
				"Combo Breaks: " + player2.playerMisses + "\n" +
				"Accuracy: " + player2.playerAccuracy + "%\n" +
				"Combo: " + player2.playerCombo + "\n" +
				Ratings.getRank(player2.playerAccuracy, player2.playerMisses) + "\n"
			);

			var multiplayerHealth:Float = 0;

			if (GameJoltStuff.ServerListSubstate.currentPlayer == 0)
				multiplayerHealth = opponentClient.playerHealth-health;
			else 
				multiplayerHealth = health-opponentClient.playerHealth;
			multiplayerHealth = (multiplayerHealth+2)*0.5;

			gameHUD.visualHealth = multiplayerHealth;
		}

		if (!multiplayerSessionEndcheck)
		{
			gameHUD.updateScoreText(
				"Score: " + songScore + " | " +
				"Combo Breaks: " + misses + " | " +
				"Accuracy: " + accuracy + "% | " +
				ratingStr
			);
		}


		if (health > maxHealth)
			health = maxHealth;

		if (!multiplayerSessionEndcheck)
		{
			if (characterPlayingAs == 1)
				healthShown = maxHealth - health;
			else
				healthShown = health;
	
			gameHUD.visualHealth = healthShown;
		}

		gameHUD.updateHealthIconAnimation();

		if(!switchedStates)
		{
			if (startingSong)
			{
				if (startedCountdown)
				{
					Conductor.songPosition += (FlxG.elapsed * 1000);
	
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
			else
				Conductor.songPosition += (FlxG.elapsed * 1000) * songMultiplier;
		}

		if(generatedMusic && PlayState.SONG.notes[Std.int(curStep / Conductor.stepsPerSection)] != null && !switchedStates && startedCountdown)
		{
			//offsetX = luaModchart.getVar("followXOffset", "float");
			//offsetY = luaModchart.getVar("followYOffset", "float");

			setLuaVar("mustHit", PlayState.SONG.notes[Std.int(curStep / Conductor.stepsPerSection)].mustHitSection);
			
			if(!PlayState.SONG.notes[Std.int(curStep / Conductor.stepsPerSection)].mustHitSection)
			{
				var midPos = dad.getMainCharacter().getMidpoint();

				if(utilities.Options.getData("cameraTracksDirections") && dad.animation.curAnim != null)
				{
					switch(dad.animation.curAnim.name.toLowerCase())
					{
						case "singleft":
							midPos.x -= 50;
						case "singright":
							midPos.x += 50;
						case "singup":
							midPos.y -= 50;
						case "singdown":
							midPos.y += 50;
					}
				}

				midPos.x += stage.p2_Cam_Offset.x;
				midPos.y += stage.p2_Cam_Offset.y;

				//if(camFollow.x != midPos.x + 150 + dad.cameraOffset[0] || camFollow.y != midPos.y + - 100 + dad.cameraOffset[1])
				//{
					camFollow.setPosition(midPos.x + 150 + dad.getMainCharacter().cameraOffset[0], midPos.y - 100 + dad.getMainCharacter().cameraOffset[1]);
	
					switch (dad.curCharacter)
					{
						case 'mom':
							camFollow.y = midPos.y;
						case 'senpai':
							camFollow.y = midPos.y - 430;
							camFollow.x = midPos.x - 100;
						case 'senpai-angry':
							camFollow.y = midPos.y - 430;
							camFollow.x = midPos.x - 100;
					}

					executeALuaState("playerTwoTurn", []);
				//}
			}

			if(PlayState.SONG.notes[Std.int(curStep / Conductor.stepsPerSection)].mustHitSection)
			{
				var midPos = boyfriend.getMainCharacter().getMidpoint();

				if(utilities.Options.getData("cameraTracksDirections") && boyfriend.animation.curAnim != null)
				{
					switch(boyfriend.animation.curAnim.name)
					{
						case "singLEFT":
							midPos.x -= 50;
						case "singRIGHT":
							midPos.x += 50;
						case "singUP":
							midPos.y -= 50;
						case "singDOWN":
							midPos.y += 50;
					}
				}

				midPos.x += stage.p1_Cam_Offset.x;
				midPos.y += stage.p1_Cam_Offset.y;

				//if(camFollow.x != midPos.x - 100 + boyfriend.cameraOffset[0] || camFollow.y != midPos.y - 100 + boyfriend.cameraOffset[1])
				//{
					camFollow.setPosition(midPos.x - 100 + boyfriend.getMainCharacter().cameraOffset[0], midPos.y - 100 + boyfriend.getMainCharacter().cameraOffset[1]);
	
					switch (curStage)
					{
						case 'limo':
							camFollow.x = midPos.x - 300;
						case 'mall':
							camFollow.y = midPos.y - 200;
							/*
						case 'school':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'evil-school':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;*/
					}

					executeALuaState("playerOneTurn", []);
				//}
			}

			if (centerCamera)
			{
				var midPos = boyfriend.getMainCharacter().getMidpoint();
				midPos.x += stage.p1_Cam_Offset.x;
				midPos.y += stage.p1_Cam_Offset.y;
				camFollow.setPosition(midPos.x - 100 + boyfriend.getMainCharacter().cameraOffset[0], midPos.y - 100 + boyfriend.getMainCharacter().cameraOffset[1]);
				midPos = dad.getMainCharacter().getMidpoint();
				midPos.x += stage.p2_Cam_Offset.x;
				midPos.y += stage.p2_Cam_Offset.y;
				camFollow.x += midPos.x + 150 + dad.getMainCharacter().cameraOffset[0];
				camFollow.y += midPos.y - 100 + dad.getMainCharacter().cameraOffset[1];
				camFollow.x *= 0.5;
				camFollow.y *= 0.5;
				if(PlayState.SONG.notes[Std.int(curStep / Conductor.stepsPerSection)].mustHitSection)
				{
					if(utilities.Options.getData("cameraTracksDirections") && boyfriend.getMainCharacter().animation.curAnim != null)
					{
						switch(boyfriend.getMainCharacter().animation.curAnim.name)
						{
							case "singLEFT" | "blockLEFT":
								camFollow.x -= 50;
							case "singRIGHT" | "blockRIGHT":
								camFollow.x += 50;
							case "singUP" | "blockUP":
								camFollow.y -= 50;
							case "singDOWN" | "blockDOWN":
								camFollow.y += 50;
						}
					}
				}
				else 
				{
					if(utilities.Options.getData("cameraTracksDirections") && dad.getMainCharacter().animation.curAnim != null)
					{
						switch(dad.getMainCharacter().animation.curAnim.name.toLowerCase())
						{
							case "singleft" | "blockleft" | "parryleft":
								camFollow.x -= 50;
							case "singright" | "blockright" | "parryright":
								camFollow.x += 50;
							case "singup" | "blockup" | "parryup":
								camFollow.y -= 50;
							case "singdown" | "blockdown" | "parrydown":
								camFollow.y += 50;
						}
					}
				}
			}
		}

		// RESET = Quick Game Over Screen
		if (utilities.Options.getData("resetButton") && !switchedStates)
		{
			if (controls.RESET)
				health = minHealth;
		}
			
		if (utilities.Options.getData("noHit") && misses > 0)
			health = minHealth;

		if (health <= minHealth && !switchedStates && !invincible && !utilities.Options.getData("noDeath") && !inMultiplayerSession)
		{
			

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			if(boyfriend.otherCharacters == null)
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, multiplayerSessionEndcheck));
			else
				openSubState(new GameOverSubstate(boyfriend.otherCharacters[0].getScreenPosition().x, boyfriend.otherCharacters[0].getScreenPosition().y, multiplayerSessionEndcheck));
			
			#if discord_rpc
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, curPortrait);
			#end

			executeALuaState("onDeath", [Conductor.songPosition]);
			boyfriend.stunned = true;
		}
		else if (health <= minHealth && !switchedStates)
		{
			hasUsedBot = true;
			didDie = true;
		}

		if(health < minHealth)
			health = minHealth;

		if (unspawnNotes[0] != null && !switchedStates)
		{
			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < (1500 * songMultiplier))
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		//var startStepCrochet:Float = ((60 / SONG.bpm) * 1000)*0.25;

		if(generatedMusic && !switchedStates && startedCountdown)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				var coolStrum = (daNote.mustPress ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))] : enemyStrums.members[Math.floor(Math.abs(daNote.noteData))]);
				var strumY = coolStrum.y;

				//if ((daNote.y > FlxG.height || daNote.y < daNote.height) || (daNote.x > FlxG.width || daNote.x < daNote.width))
				//{
					//daNote.active = false;
					//daNote.visible = false;
				//}
				//else
				//{
					daNote.visible = true;
					daNote.active = true;
				//}

				if (daNote.isSustainNote)
				{
					daNote.scale.y = daNote.sustainScaleY * (speed/startSpeed); //make sustain scaleY match speed on scroll speed changes
				}

				var swagWidth = daNote.halfWidth;
				var center:Float = strumY + swagWidth;

				if(utilities.Options.getData("downscroll"))
				{
					var visualTime = daNote.strumTime;
					if (daNote.isSustainNote && daNote.animation.curAnim.name.endsWith('end'))
					{
						//if (daNote.prevNoteIsSustainNote)
							visualTime = daNote.prevNoteStrumtime;
						//else 
						//	visualTime -= startStepCrochet;
					}
						

					daNote.y = strumY + (0.45 * (Conductor.songPosition - visualTime) * FlxMath.roundDecimal(speed, 2));
					

					if(daNote.isSustainNote)
					{
						if (SONG.ui_Skin != 'pixel')
						{
							daNote.height = Math.abs(daNote.scale.y) * daNote.frameHeight; //half update hitbox on the scale y (to fix clipping)
							daNote.offset.y = -0.5 * (daNote.height - daNote.frameHeight);
						}

					
						if(daNote.animation.curAnim.name.endsWith('end'))
						{
							daNote.y -= daNote.height-2;
							if (!daNote.prevNoteIsSustainNote) //only for really short sustains that only have an end and no regular parts
							{
								daNote.y += daNote.height*0.25; //move back down slightly into the note
							}
						}
							
						//else
							//daNote.y += daNote.height / speed;

						if(((daNote.wasGoodHit || daNote.prevNote.wasGoodHit) && daNote.shouldHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							// Clip to strumline
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					daNote.y = strumY - (0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(speed, 2));

					if(daNote.isSustainNote)
					{
						if (SONG.ui_Skin != 'pixel')
						{
							daNote.height = Math.abs(daNote.scale.y) * daNote.frameHeight;
							daNote.offset.y = -0.5 * (daNote.height - daNote.frameHeight);
						}
	
						//daNote.y -= daNote.height / 2;

						if(((daNote.wasGoodHit || daNote.prevNote.wasGoodHit) && daNote.shouldHit) && daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							// Clip to strumline
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				daNote.y -= daNote.yOffset;

				daNote.calculateCanBeHit();
				if (fdgod2PlayerSide >= 0)
				{
					if (daNote.character != fdgod2PlayerSide)
					{
						daNote.canBeHit = false;
					}
				}

				if (!daNote.checkPlayerMustPress() && daNote.strumTime <= Conductor.songPosition && daNote.shouldHit && !daNote.noteWasHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					daNote.noteWasHit = true;

					
					var singAnim:String = NoteVariables.Character_Animation_Arrays[getCorrectKeyCount(false) - 1][Std.int(Math.abs(daNote.noteData))] + (characterPlayingAs == 0 ? altAnim : "") + daNote.singAnimSuffix;
					if (daNote.singAnimPrefix != 'sing')
					{
						singAnim = singAnim.replace('sing', daNote.singAnimPrefix);
					}


					if(currentOpponentCharacter.otherCharacters == null || currentOpponentCharacter.otherCharacters.length - 1 < daNote.character)
						currentOpponentCharacter.playAnim(singAnim, true, false, 0, daNote.strumTime);
					else
					{
						if(daNote.characters.length <= 1)
						{
							if(daNote.isSustainNote)
								executeALuaState(getSingLuaFuncName(false)+'SingHeld'+daNote.character, [Math.abs(daNote.noteData), Conductor.songPosition, daNote.arrow_Type, daNote.strumTime]);
							else
								executeALuaState(getSingLuaFuncName(false)+'Sing'+daNote.character, [Math.abs(daNote.noteData), Conductor.songPosition, daNote.arrow_Type, daNote.strumTime]);
							currentOpponentCharacter.otherCharacters[daNote.character].playAnim(singAnim, true, false, 0, daNote.strumTime);
						}
						else
						{
							for(character in daNote.characters)
							{
								if(currentOpponentCharacter.otherCharacters.length - 1 >= character)
									currentOpponentCharacter.otherCharacters[character].playAnim(singAnim, true, false, 0, daNote.strumTime);
							}
						}
					}

					if(daNote.isSustainNote)
						executeALuaState(getSingLuaFuncName(false)+'SingHeld', [Math.abs(daNote.noteData), Conductor.songPosition, daNote.arrow_Type, daNote.strumTime]);
					else
						executeALuaState(getSingLuaFuncName(false)+'Sing', [Math.abs(daNote.noteData), Conductor.songPosition, daNote.arrow_Type, daNote.strumTime]);

					executeALuaState(getSingLuaFuncName(false)+'SingExtra', [Math.abs(daNote.noteData), notes.members.indexOf(daNote), daNote.arrow_Type, daNote.isSustainNote]);

					if (utilities.Options.getData("enemyStrumsGlow"))
					{
						currentOpponentStrums.forEach(function(spr:StrumNote)
						{
							if (inMultiplayerSession && fdgod2PlayerSide == -1)
								return;
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.playAnim('confirm', true);
								spr.resetAnim = 0;

								if(!daNote.isSustainNote && utilities.Options.getData("opponentNoteSplashes"))
								{
									var splash:NoteSplash = new NoteSplash(spr.x - (spr.width / 2), spr.y - (spr.height / 2), spr.ID, spr, false);
									splash.cameras = [camHUD];
									add(splash);
								}
								
								spr.animation.finishCallback = function(_)
								{
									spr.playAnim("static");
								}

							}
						});
					}

					if(currentOpponentCharacter.otherCharacters == null || currentOpponentCharacter.otherCharacters.length - 1 < daNote.character)
						currentOpponentCharacter.holdTimer = 0;
					else
					{
						if(daNote.characters.length <= 1)
							currentOpponentCharacter.otherCharacters[daNote.character].holdTimer = 0;
						else
						{
							for(char in daNote.characters)
							{
								if(currentOpponentCharacter.otherCharacters.length - 1 >= char)
									currentOpponentCharacter.otherCharacters[char].holdTimer = 0;
							}
						}
					}


					if (SONG.needsVoices)
						vocals.volume = 1;

					if (!daNote.isSustainNote)
					{
						daNote.active = false;
						daNote.visible = false;
						if (shouldKillNotes)
							daNote.kill();
						notes.remove(daNote, true);
						if (shouldKillNotes)
							daNote.destroy();
					}

				}

				if(daNote != null)
				{
					if (daNote.mustPress && !daNote.modifiedByLua)
					{
						var coolStrum = playerStrums.members[Math.floor(Math.abs(daNote.noteData))];
						var arrayVal = Std.string([daNote.noteData, daNote.arrow_Type, daNote.isSustainNote]);
						
						daNote.visible = coolStrum.visible;

						if(!prevPlayerXVals.exists(arrayVal))
						{
							var tempShit:Float = 0.0;
	
							daNote.x = coolStrum.x;

							while(Std.int(daNote.x + (daNote.width / 2)) != Std.int(coolStrum.x + (coolStrum.width / 2)))
							{
								daNote.x += (daNote.x + daNote.width > coolStrum.x + coolStrum.width ? -0.1 : 0.1);
								tempShit += (daNote.x + daNote.width > coolStrum.x + coolStrum.width ? -0.1 : 0.1);
							}

							prevPlayerXVals.set(arrayVal, tempShit);
						}
						else
							daNote.x = coolStrum.x + prevPlayerXVals.get(arrayVal) - daNote.xOffset;
	
						if (!daNote.isSustainNote)
							daNote.modAngle = coolStrum.angle;
						
						if(coolStrum.alpha != 1)
							daNote.alpha = coolStrum.alpha;
	
						if (!daNote.isSustainNote)
							daNote.modAngle = coolStrum.angle;
						daNote.flipX = coolStrum.flipX;

						if (!daNote.isSustainNote)
							daNote.flipY = coolStrum.flipY;

						daNote.color = coolStrum.color;
						if (fdgod2PlayerSide >= 0)
						{
							if (daNote.character != fdgod2PlayerSide)
							{
								daNote.color = 0x66666666;
							}
						}
					}
					else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
					{
						var coolStrum = enemyStrums.members[Math.floor(Math.abs(daNote.noteData))];
						var arrayVal = Std.string([daNote.noteData, daNote.arrow_Type, daNote.isSustainNote]);

						daNote.visible = coolStrum.visible;

						if(!prevEnemyXVals.exists(arrayVal))
						{
							var tempShit:Float = 0.0;
	
							daNote.x = coolStrum.x;

							while(Std.int(daNote.x + (daNote.width / 2)) != Std.int(coolStrum.x + (coolStrum.width / 2)))
							{
								daNote.x += (daNote.x + daNote.width > coolStrum.x + coolStrum.width ? -0.1 : 0.1);
								tempShit += (daNote.x + daNote.width > coolStrum.x + coolStrum.width ? -0.1 : 0.1);
							}

							prevEnemyXVals.set(arrayVal, tempShit);
						}
						else
							daNote.x = coolStrum.x + prevEnemyXVals.get(arrayVal) - daNote.xOffset;
	
						if (!daNote.isSustainNote)
							daNote.modAngle = coolStrum.angle;
						
						if(coolStrum.alpha != 1)
							daNote.alpha = coolStrum.alpha;
	
						if (!daNote.isSustainNote)
							daNote.modAngle = coolStrum.angle;
						daNote.flipX = coolStrum.flipX;

						if (!daNote.isSustainNote)
							daNote.flipY = coolStrum.flipY;

						daNote.color = coolStrum.color;
						if (fdgod2PlayerSide >= 0)
							{
								if (daNote.character != fdgod2PlayerSide)
									daNote.color = 0x66666666;
							}
					}
				}

				if(Conductor.songPosition - Conductor.safeZoneOffset > daNote.strumTime)
				{
					if(daNote.checkPlayerMustPress() && daNote.playMissOnMiss && !(daNote.isSustainNote && daNote.animation.curAnim.name == "holdend") && !daNote.wasGoodHit)
					{
						vocals.volume = 0;
						noteMiss(daNote.noteData, daNote);
					}

					//make sure the note clips before removing
					if ((daNote.isSustainNote && Conductor.songPosition - ((Conductor.safeZoneOffset*4)/speed) > daNote.strumTime) || !daNote.isSustainNote || daNote.wasMissed)
					{
						daNote.active = false;
						daNote.visible = false;
	
						if (shouldKillNotes)
							daNote.kill();
						notes.remove(daNote, true);
						if (shouldKillNotes)
							daNote.destroy();
					}

				}
			});

			if(utilities.Options.getData("noteBGAlpha") != 0 && !switchedStates)
				updateNoteBGPos();
		}

		if (!inCutscene && !switchedStates)
			keyShit();

		currentBeat = curBeat;

		var pause:Bool = FlxG.keys.checkStatus(FlxKey.fromString(utilities.Options.getData("pauseBind", "binds")), FlxInputState.JUST_PRESSED);
		if (MusicBeatState.usingController)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
			if (gamepad != null)
			{
				if (gamepad.checkStatus(FlxGamepadInputID.BACK, JUST_PRESSED))
					pause = true;
			}
		}
		#if mobile 
		if(controls.BACK)
			pause = true;

		mobileControls.visible = !MusicBeatState.usingController;
		#end
		if(pause && startedCountdown && canPause && !switchedStates)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if discord_rpc
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, curPortrait);
			#end
		}

		if(!utilities.Options.getData("disableDebugMenus") && !inMultiplayerSession)
		{
			if (FlxG.keys.justPressed.SEVEN && !switchedStates && !inCutscene)
			{
				#if linc_luajit
				if(executeModchart && luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end
				
				switchedStates = true;
	
				vocals.stop();
	
				SONG.keyCount = ogKeyCount;
				SONG.playerKeyCount = ogPlayerKeyCount;
	
				FlxG.switchState(new ChartingState());
	
				#if discord_rpc
				DiscordClient.changePresence("Chart Editor - " + SONG.song + " (" + storyDifficultyText + ")", null, null, true, curPortrait);
				#end
			}
	
			#if debug
			if (FlxG.keys.justPressed.EIGHT && !switchedStates && !inCutscene)
			{
				#if linc_luajit
				if(executeModchart && luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end
				
				switchedStates = true;
	
				vocals.stop();
	
				SONG.keyCount = ogKeyCount;
				SONG.playerKeyCount = ogPlayerKeyCount;
	
				FlxG.switchState(new debuggers.ChartingStateDev());
	
				#if discord_rpc
				DiscordClient.changePresence("Chart Editor Development", null, null, true);
				#end 
			}
			#end
		}
		if(!switchedStates)
		{
			for(event in events)
			{
				if(event[1] + Conductor.offset <= Conductor.songPosition) // activate funni lol
				{
					processEvent(event);

					events.remove(event);
				}
			}
		}

		executeALuaState("updatePost", [elapsed]);
	}

	override function destroy()
	{
		#if linc_luajit
		ModchartUtilities.killShaders();
		ModchartUtilities.haxeInterp = null;
		#end
		#if desktop 
		FlxTransWindow.restoreWindow();
		#end
		cleanupUISkins();
		super.destroy();
	}

	var multiplayerEnded:Bool = false;

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if (inMultiplayerSession && !multiplayerEnded)
		{
			//persistentUpdate = false;
			//persistentDraw = true;
			paused = true;

			multiplayerEnded = true;
			return;
		}
			

		// lol dude when a song ended in freeplay it legit reloaded the page and i was like:  o_o ok
		if(FlxG.state == instance)
		{
			#if linc_luajit
			if (executeModchart && luaModchart != null)
			{
				for(sound in ModchartUtilities.lua_Sounds)
				{
					sound.stop();
					sound.kill();
					sound.destroy();
				}

				luaModchart.die();
				luaModchart = null;
			}
			ModchartUtilities.killShaders();
			#end

			
			

			if (SONG.validScore)
			{
				#if !switch
				if(!hasUsedBot && songMultiplier >= 1 && !didDie && !isCheating && !multiplayerSessionEndcheck)
				{
					Highscore.saveScore(SONG.song, songScore, storyDifficultyStr);
					Highscore.saveRank(SONG.song, Ratings.getRank(accuracy, misses), storyDifficultyStr, accuracy);
					if (!hasUsedBot && !didDie && !isCheating && 
						hasMechAndModchartsEnabled && songMultiplier >= 1)
					{
						GameJoltStuff.addHighScore(SONG.song.toLowerCase(), storyDifficultyStr.toLowerCase(), songMultiplier, characterPlayingAs == 1, accuracy, songScore, misses);
					}
				}
				#end
			}

			if (playingFDGOD)
			{
				trace('played fd god');
				if (!hasUsedBot && !didDie && !isCheating && 
					hasMechAndModchartsEnabled && songMultiplier >= 1 && !multiplayerSessionEndcheck)
				{
					trace('actually beat it!?!?!?');
					if (SONG.song.toLowerCase() == 'final destination')
						Options.setData(true, "beatFDGOD", "progress");
					else if (SONG.song.toLowerCase() == 'final destination old')
						Options.setData(true, "beatFDGODold", "progress");
				}
				else 
				{
					trace('not a valid run lol');
				}
			}

			var end = function()
			{
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				openSubState(new ResultsScreenSubstate());
			}
	
			if(playCutsceneOnPauseLmao)
			{
				if(SONG.endCutscene != null && SONG.endCutscene != "")
				{
					cutscene = CutsceneUtil.loadFromJson(SONG.endCutscene);

					if (cutscene != null)
					{
						switch(cutscene.type.toLowerCase())
						{
							case "video":
								startVideo(cutscene.videoPath, cutscene.videoExt, true);
		
							case "dialogue":
								var box:DialogueBox = new DialogueBox(cutscene);
								box.scrollFactor.set();
								box.finish_Function = function() { bruhDialogue(true); };
								box.cameras = [camHUD];
		
								startDialogue(box, true);
		
							default:
								end();
						}
					}
					else 
					{
						end();
					}
	

				}
				else
				{
					end();
				}
			}
			else
			{
				end();
			}
			
		}
	}

	var ogJudgementTimings:Array<Float> = utilities.Options.getData("judgementTimings");
	var ogGhostTapping:Bool = utilities.Options.getData("ghostTapping");
	var ogAntiMash:Bool = utilities.Options.getData("antiMash");
	var ogMech:Bool = utilities.Options.getData("mechanics");
	var ogMod:Bool = utilities.Options.getData("modcharts");

	public function saveReplay()
	{
		if(!playingReplay && !savedReplay)
		{
			savedReplay = true;

			var time = Date.now().getTime();
			var json:String = Json.stringify(replay.convertToSwag());

			#if sys
			sys.io.File.saveContent("assets/replays/replay-" + SONG.song.toLowerCase() + "-" + storyDifficultyStr.toLowerCase() + "-" + time + ".json", json);
			#end
		}
	}

	var savedReplay:Bool = false;

	public function fixSettings()
	{
		Conductor.offset = utilities.Options.getData("songOffset");

		utilities.Options.setData(ogJudgementTimings, "judgementTimings");
		utilities.Options.setData(ogGhostTapping, "ghostTapping");
		utilities.Options.setData(ogAntiMash, "antiMash");
		utilities.Options.setData(ogMech, "mechanics");
		utilities.Options.setData(ogMod, "modcharts");
	}

	public function finishSongStuffs()
	{
		fixSettings();

		if (!multiplayerSessionEndcheck)
			AwardManager.onBeatSong(this);

		if(isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				AwardManager.onBeatWiik(this);
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				switchedStates = true;
				vocals.stop();

				SONG.keyCount = ogKeyCount;
				SONG.playerKeyCount = ogPlayerKeyCount;

				FlxG.save.data.lastWeekPlaylist = null;
				FlxG.save.data.lastCampaignScore = null;
				FlxG.save.data.lastWeek = null;
				FlxG.save.flush();

				FlxG.switchState(new VoiidMainMenuState());

				//cleanupUISkins();

				if (SONG.validScore)
				{
					if(!hasUsedBot && songMultiplier >= 1)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficultyStr, (groupWeek != "" ? groupWeek + "Week" : "week"));
					}
				}
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficultyStr.toLowerCase() != "normal")
					difficulty = '-' + storyDifficultyStr.toLowerCase();

				var song:String = PlayState.storyPlaylist[0].toLowerCase();
				#if mobile
				song = PlayState.storyPlaylist[0];
				difficulty = "-"+diffLoadedInWith;
				#end

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				FlxG.save.data.lastWeekPlaylist = PlayState.storyPlaylist.copy();
				FlxG.save.data.lastCampaignScore = campaignScore;
				FlxG.save.data.lastWeek = PlayState.wiikDiscordDisplay;
				FlxG.save.flush();

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;


				
				

				PlayState.SONG = Song.loadFromJson(song + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				switchedStates = true;
				PlayState.chartingMode = false;
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else if(!playingReplay)
		{
			trace('WENT BACK TO FREEPLAY??');
			switchedStates = true;

			if(vocals.active)
				vocals.stop();

			SONG.keyCount = ogKeyCount;
			SONG.playerKeyCount = ogPlayerKeyCount;

			FlxG.switchState(new FreeplayState());

			//cleanupUISkins();
		}
		else
		{
			trace('WENT BACK TO REPLAY SELECTOR??');
			switchedStates = true;

			if(vocals.active)
				vocals.stop();

			SONG.keyCount = ogKeyCount;
			SONG.playerKeyCount = ogPlayerKeyCount;

			FlxG.switchState(new ReplaySelectorState());

			//cleanupUISkins();
		}

		playingReplay = false;
	}
	public function cleanupUISkins()
	{
		/*for (uiS in storedUISkins)
		{
			uiS.arrow_Type_Sprites = [];
			for (spr in uiS.arrow_Type_Cached_Sprites)
			{
				spr.destroy();
			}
			uiS.arrow_Type_Cached_Sprites = [];
		}*/
	}

	var endingSong:Bool = false;

	var rating:FlxSprite = new FlxSprite();
	var ratingTween:VarTween;

	var accuracyText:FlxText = new FlxText(0,0,0,"bruh",24);
	var accuracyTween:VarTween;

	var numbers:Array<FlxSprite> = [];
	var number_Tweens:Array<VarTween> = [];

	var multiplayerScoreMult:Float = 1.0;

	private function popUpScore(strumtime:Float, noteData:Int, ?setNoteDiff:Float):Void
	{
		var noteDiff:Float = (strumtime - Conductor.songPosition);

		if(utilities.Options.getData("botplay"))
			noteDiff = 0;

		if(setNoteDiff != null)
			noteDiff = setNoteDiff;

		if(!playingReplay)
			replay.recordKeyHit(noteData, strumtime, noteDiff);

		vocals.volume = 1;

		var daRating:String = Ratings.getRating(Math.abs(noteDiff));

		var scoreMult:Int = Math.ceil((combo+1)/10);

		var score:Int = Math.floor(Ratings.getScore(daRating)*scoreMult*multiplayerScoreMult);

		var hitNoteAmount:Float = 0;

		// health switch case
		switch(daRating)
		{
			case 'sick' | 'marvelous':
				health += 0.035;
			case 'good':
				health += 0.015;
			case 'bad':
				health += 0.005;
			case 'shit':
				if(utilities.Options.getData("antiMash"))
					health -= 0.075; // yes its more than a miss so that spamming with ghost tapping on is bad

				if(utilities.Options.getData("missOnShit"))
					misses += 1;

				combo = 0;
		}

		executeALuaState("popUpScore", [daRating, combo]);

		if(ratings.exists(daRating))
			ratings.set(daRating, ratings.get(daRating) + 1);

		if(utilities.Options.getData("sideRatings") == true)
			updateRatingText();

		if(daRating == "sick" || daRating == "marvelous")
			hitNoteAmount = 1;
		else if(daRating == "good")
			hitNoteAmount = 0.8;
		else if(daRating == "bad")
			hitNoteAmount = 0.3;

		hitNotes += hitNoteAmount;

		if ((daRating == "sick" || daRating == "marvelous") && utilities.Options.getData("playerNoteSplashes"))
		{
			currentPlayerStrums.forEachAlive(function(spr:FlxSprite) {
				if(spr.ID == Math.abs(noteData))
				{
					var splash:NoteSplash = new NoteSplash(spr.x - (spr.width / 2), spr.y - (spr.height / 2), noteData, spr, true);
					splash.cameras = [camHUD];
					add(splash);
				}
			});
		}

		songScore += score;
		var xOffset = (FlxG.width/2) - currentPlayerStrums.members[0].x + 100;
		if (characterPlayingAs != 0 && !utilities.Options.getData("middlescroll"))
			xOffset -= (FlxG.width/2);

		if (utilities.Options.getData("ratingPopup"))
		{
			rating.alpha = 1;
			rating.loadGraphic(gameHUD.uiMap.get(daRating), false, 0, 0, true, daRating);
			rating.screenCenter();
			rating.x -= xOffset;
			rating.y -= 60;
			rating.velocity.y = FlxG.random.int(30, 60);
			rating.velocity.x = FlxG.random.int(-10, 10);
			rating.cameras = [camHUD];
			insert(members.indexOf(strumLineNotes), rating);
			rating.setGraphicSize(Std.int(rating.width * Std.parseFloat(uiSkin.ui_Settings.get("globalScale")) * Std.parseFloat(uiSkin.ui_Settings.get("ratingScale"))));
			rating.antialiasing = uiSkin.ui_Settings.get("aa") == "true";
			rating.updateHitbox();
		}
		else
		{
			rating.screenCenter();
			rating.x -= xOffset;
			rating.y -= 60;
			rating.x -= 200;
			rating.y -= 150;
		}



		var noteMath:Float = 0.0;

		// math
		noteMath = noteDiff * Math.pow(10, 2);
		noteMath = Math.round(noteMath) / Math.pow(10, 2);

		if(utilities.Options.getData("displayMs"))
		{
			accuracyText.setPosition(rating.x, rating.y + 100);
			accuracyText.text = noteMath + " ms" + (utilities.Options.getData("botplay") ? " (BOT)" : "");

			accuracyText.cameras = [camHUD];

			if(Math.abs(noteMath) == noteMath)
				accuracyText.color = FlxColor.CYAN;
			else
				accuracyText.color = FlxColor.ORANGE;
			
			accuracyText.borderStyle = FlxTextBorderStyle.OUTLINE;
			accuracyText.borderSize = 1;
			accuracyText.font = Paths.font("vcr.ttf");

			add(accuracyText);
		}

		
		/*
		var comboSpr:FlxSprite = new FlxSprite()
		comboSpr.screenCenter();
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		comboSpr.cameras = [camHUD];
		//add(rating);
		

		comboSpr.setGraphicSize(Std.int(comboSpr.width * Std.parseFloat(uiSkin.ui_Settings.get("globalScale")) * Std.parseFloat(uiSkin.ui_Settings.get("ratingScale"))));

		
		comboSpr.antialiasing = uiSkin.ui_Settings.get("aa") == "true";

		comboSpr.updateHitbox();
		*/

		if(utilities.Options.getData("comboPopup"))
		{
			var seperatedScore:Array<Int> = [];

			for(i in 0...Std.string(combo).length)
			{
				seperatedScore.push(Std.parseInt(Std.string(combo).split("")[i]));
			}
	
			var daLoop:Int = 0;
	
			for (i in seperatedScore)
			{
				if(numbers.length - 1 < daLoop)
					numbers.push(new FlxSprite());
	
				var numScore = numbers[daLoop];
	
				numScore.alpha = 1;
	
				numScore.loadGraphic(gameHUD.uiMap.get(Std.string(i)), false, 0, 0, true, Std.string(i));
				
				numScore.screenCenter();
				//numScore.x -= (utilities.Options.getData("middlescroll") ? 350 : (characterPlayingAs == 0 ? 0 : -150));
				numScore.x -= xOffset;
				numScore.x += (43 * daLoop) - 90;
				numScore.y += 80;
	
				numScore.setGraphicSize(Std.int(numScore.width * Std.parseFloat(uiSkin.ui_Settings.get("comboScale"))));
				numScore.updateHitbox();
	
				numScore.antialiasing = uiSkin.ui_Settings.get("aa") == "true";
	
				numScore.velocity.y = FlxG.random.int(30, 60);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				numScore.cameras = [camHUD];
				//add(numScore);
				insert(members.indexOf(strumLineNotes), numScore);
	
				if(number_Tweens[daLoop] == null)
				{
					number_Tweens[daLoop] = FlxTween.tween(numScore, {alpha: 0}, 0.2, {
						startDelay: Conductor.crochet * 0.002
					});
				}
				else
				{
					numScore.alpha = 1;
	
					number_Tweens[daLoop].cancel();
	
					number_Tweens[daLoop] = FlxTween.tween(numScore, {alpha: 0}, 0.2, {
						startDelay: Conductor.crochet * 0.002
					});
				}
	
				daLoop++;
			}
		}
		

		if (utilities.Options.getData("ratingPopup"))
		{
			if(ratingTween == null)
			{
				ratingTween = FlxTween.tween(rating, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001
				});
			}
			else
			{
				ratingTween.cancel();
	
				rating.alpha = 1;
				ratingTween = FlxTween.tween(rating, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001
				});
			}
		}


		if(utilities.Options.getData("displayMs"))
		{
			if(accuracyTween == null)
			{
				accuracyTween = FlxTween.tween(accuracyText, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001
				});
			}
			else
			{
				accuracyTween.cancel();
	
				accuracyText.alpha = 1;

				accuracyTween = FlxTween.tween(accuracyText, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001
				});
			}
		}
		/*
		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
		*/

		curSection += 1;

		calculateAccuracy();
	}

	private function closerNote(note1:Note, note2:Note):Note
	{
		if(note1.canBeHit && !note2.canBeHit)
			return note1;
		if(!note1.canBeHit && note2.canBeHit)
			return note2;

		if(Math.abs(Conductor.songPosition - note1.strumTime) < Math.abs(Conductor.songPosition - note2.strumTime))
			return note1;

		return note2;
	}

	var justPressedArray:Array<Bool> = [];
	var releasedArray:Array<Bool> = [];
	var justReleasedArray:Array<Bool> = [];
	var heldArray:Array<Bool> = [];
	var previousReleased:Array<Bool> = [];

	private function keyShit()
	{
		if(generatedMusic && startedCountdown)
		{

			if (fdgod2PlayerSide >= 0)
			{
				//do botplay on notes you dont need to hit but also dont add score/combo
				notes.forEachAlive(function(note:Note) {
					if(note.shouldHit)
					{
						var doHit:Bool = false;
						if (note.character != fdgod2PlayerSide)
						{
							doHit = true;
						}
						note.calculateCanBeHit();
						if(note.checkPlayerMustPress() && note.strumTime <= Conductor.songPosition && doHit && !note.wasGoodHit)
						{
							if(currentPlayerCharacter.otherCharacters == null || currentPlayerCharacter.otherCharacters.length - 1 < note.character)
								currentPlayerCharacter.holdTimer = 0;
							else
								if(note.characters.length <= 1)
									currentPlayerCharacter.otherCharacters[note.character].holdTimer = 0;
								else
								{
									for(char in note.characters)
									{
										if(currentPlayerCharacter.otherCharacters.length - 1 >= char)
											currentPlayerCharacter.otherCharacters[char].holdTimer = 0;
									}
								}

							var singAnim:String = NoteVariables.Character_Animation_Arrays[getCorrectKeyCount(true) - 1][Std.int(Math.abs(note.noteData % getCorrectKeyCount(true)))];
							if (note.singAnimPrefix != 'sing')
							{
								singAnim = singAnim.replace('sing', note.singAnimPrefix);
							}

							if(currentPlayerCharacter.otherCharacters != null && !(currentPlayerCharacter.otherCharacters.length - 1 < note.character))
								if(note.characters.length <= 1)
								{
									currentPlayerCharacter.otherCharacters[note.character].playAnim(singAnim, true, false, 0, note.strumTime);
								}	
								else
								{
									for(character in note.characters)
									{
										if(currentPlayerCharacter.otherCharacters.length - 1 >= character)
											currentPlayerCharacter.otherCharacters[character].playAnim(singAnim, true, false, 0, note.strumTime);
									}
								}
							else
								currentPlayerCharacter.playAnim(singAnim, true, false, 0, note.strumTime);

							note.wasGoodHit = true;
							vocals.volume = 1;
							if (!note.isSustainNote)
							{
								if (shouldKillNotes)
									note.kill();
								notes.remove(note, true);
								if (shouldKillNotes)
									note.destroy();
							}
						}
					}
				});
			}


			if(!utilities.Options.getData("botplay"))
			{
				var bruhBinds:Array<String> = ["LEFT","DOWN","UP","RIGHT"];
				var bruhBindsbut5k:Array<String> = ["LEFT","DOWN","NONE","UP","RIGHT"];

				justPressedArray = [];
				justReleasedArray = [];
		
				if(!playingReplay)
				{
					previousReleased = releasedArray;
	
					releasedArray = [];
					heldArray = [];

					#if mobile 
					mobileControls.updateInput();
					#end
	
					for(i in 0...binds.length)
					{
						#if mobile 
						if (mobileControls.hasDodges && i >= Math.floor(mobileControls.keyCount/2))
						{
							justPressedArray[i] = mobileControls.justPressed[i+1];
							releasedArray[i] = mobileControls.released[i+1];
							justReleasedArray[i] = mobileControls.justReleased[i+1];
							heldArray[i] = mobileControls.pressed[i+1];
						}
						else 
						{
							justPressedArray[i] = mobileControls.justPressed[i];
							releasedArray[i] = mobileControls.released[i];
							justReleasedArray[i] = mobileControls.justReleased[i];
							heldArray[i] = mobileControls.pressed[i];
						}
		
						#else
						justPressedArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.JUST_PRESSED);
						releasedArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.RELEASED);
						justReleasedArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.JUST_RELEASED);
						heldArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.PRESSED);
						#end
		
						if(releasedArray[i] == true)
						{
							#if !mobile 
							if (getCorrectKeyCount(true) == 4)
							{
								justPressedArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(bruhBinds[i]), FlxInputState.JUST_PRESSED);
								releasedArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(bruhBinds[i]), FlxInputState.RELEASED);
								justReleasedArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(bruhBinds[i]), FlxInputState.JUST_RELEASED);
								heldArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(bruhBinds[i]), FlxInputState.PRESSED);
							}
							else if (getCorrectKeyCount(true) == 5 && i != 2)
							{
								justPressedArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(bruhBindsbut5k[i]), FlxInputState.JUST_PRESSED);
								releasedArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(bruhBindsbut5k[i]), FlxInputState.RELEASED);
								justReleasedArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(bruhBindsbut5k[i]), FlxInputState.JUST_RELEASED);
								heldArray[i] = FlxG.keys.checkStatus(FlxKey.fromString(bruhBindsbut5k[i]), FlxInputState.PRESSED);
							}
							#end

							//controller support still works on mobile
							var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
							if (gamepad != null)
							{
								justPressedArray[i] = gamepad.checkStatus(FlxGamepadInputID.fromString(controllerBinds[i]), FlxInputState.JUST_PRESSED);
								releasedArray[i] = gamepad.checkStatus(FlxGamepadInputID.fromString(controllerBinds[i]), FlxInputState.RELEASED);
								justReleasedArray[i] = gamepad.checkStatus(FlxGamepadInputID.fromString(controllerBinds[i]), FlxInputState.JUST_RELEASED);
								heldArray[i] = gamepad.checkStatus(FlxGamepadInputID.fromString(controllerBinds[i]), FlxInputState.PRESSED);
							}
						}

						/*if (fdgod2PlayerSide >= 0)
						{
							if ((i < 5 && fdgod2PlayerSide == 0) || (fdgod2PlayerSide == 1 && i >= 5))
							{
								justPressedArray[i] = false;
								releasedArray[i] = false;
								justReleasedArray[i] = false;
								heldArray[i] = false;
							}
						}*/

					}

					for (i in 0...justPressedArray.length) {
						if (justPressedArray[i] == true) {
							replay.recordInput(i, "pressed");
						}
					};
				}
				else
				{
					for(inputIndex in 0...inputs.length)
					{
						var input = inputs[inputIndex];

						if(input != null)
						{
							if(input[2] != 2 && Conductor.songPosition >= input[1])
							{
								if(input[2] == 1)
								{
									justReleasedArray[input[0]] = true;
									releasedArray[input[0]] = true;

									justPressedArray[input[0]] = false;
									heldArray[input[0]] = false;

									currentPlayerStrums.members[input[0]].playAnim('static');
									currentPlayerStrums.members[input[0]].resetAnim = 0;
								}
								else if(input[2] == 0)
								{
									justPressedArray[input[0]] = true;
									heldArray[input[0]] = true;

									justReleasedArray[input[0]] = false;
									releasedArray[input[0]] = false;

									if(!utilities.Options.getData("ghostTapping"))
										noteMiss(input[0]);
								}
		
								inputs.remove(input);
							}
							else if(input[2] == 2 && Conductor.songPosition >= input[1] + input[3])
							{
								for(note in notes)
								{
									if(note.checkPlayerMustPress() && FlxMath.roundDecimal(note.strumTime, 2) == FlxMath.roundDecimal(input[1], 2) && note.noteData == input[0])
									{
										justPressedArray[input[0]] = true;
										heldArray[input[0]] = true;
	
										justReleasedArray[input[0]] = false;
										releasedArray[input[0]] = false;

										if(currentPlayerCharacter.otherCharacters == null || currentPlayerCharacter.otherCharacters.length - 1 < note.character)
											currentPlayerCharacter.holdTimer = 0;
										else
											if(note.characters.length <= 1)
												currentPlayerCharacter.otherCharacters[note.character].holdTimer = 0;
											else
											{
												for(char in note.characters)
												{
													if(currentPlayerCharacter.otherCharacters.length - 1 >= char)
														currentPlayerCharacter.otherCharacters[char].holdTimer = 0;
												}
											}

										goodNoteHit(note, input[3]);
									}
								}

								inputs.remove(input);
							}
						}
					}
				}

				for (i in 0...justPressedArray.length) {
					if (justPressedArray[i] == true)
						executeALuaState("keyPressed", [i]);
				};
				
				for (i in 0...releasedArray.length) {
					if (releasedArray[i] == true)
						executeALuaState("keyReleased", [i]);
				};
				
				if(justPressedArray.contains(true) && generatedMusic && !playingReplay)
				{
					// variables
					var possibleNotes:Array<Note> = [];
					var dontHit:Array<Note> = [];
					
					// notes you can hit lol
					notes.forEachAlive(function(note:Note) {
						note.calculateCanBeHit();
						if (fdgod2PlayerSide >= 0)
						{
							if (note.character != fdgod2PlayerSide)
							{
								note.canBeHit = false;
							}
						}

						if(note.canBeHit && note.checkPlayerMustPress() && !note.tooLate && !note.isSustainNote)
							possibleNotes.push(note);
					});
	
					if(utilities.Options.getData("inputSystem") == "rhythm")
						possibleNotes.sort((b, a) -> Std.int(Conductor.songPosition - a.strumTime));
					else
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	
					if(utilities.Options.getData("inputSystem") == "rhythm")
					{
						var coolNote:Note = null;
	
						for(note in possibleNotes) {
							if(coolNote != null)
							{
								if(note.strumTime > coolNote.strumTime && note.shouldHit)
									dontHit.push(note);
							}
							else if(note.shouldHit)
								coolNote = note;
						}
					}
		
					var noteDataPossibles:Array<Bool> = [];
					var rythmArray:Array<Bool> = [];
					var noteDataTimes:Array<Float> = [];
	
					for(i in 0...SONG.playerKeyCount)
					{
						noteDataPossibles.push(false);
						noteDataTimes.push(-1);
	
						rythmArray.push(false);
					}
		
					// if there is actual notes to hit
					if (possibleNotes.length > 0)
					{
						for(i in 0...possibleNotes.length)
						{	
							if(justPressedArray[possibleNotes[i].noteData] && !noteDataPossibles[possibleNotes[i].noteData])
							{
								noteDataPossibles[possibleNotes[i].noteData] = true;
								noteDataTimes[possibleNotes[i].noteData] = possibleNotes[i].strumTime;
	
								if(currentPlayerCharacter.otherCharacters == null || currentPlayerCharacter.otherCharacters.length - 1 < possibleNotes[i].character)
									currentPlayerCharacter.holdTimer = 0;
								else
									if(possibleNotes[i].characters.length <= 1)
										currentPlayerCharacter.otherCharacters[possibleNotes[i].character].holdTimer = 0;
									else
									{
										for(char in possibleNotes[i].characters)
										{
											if(currentPlayerCharacter.otherCharacters.length - 1 >= char)
												currentPlayerCharacter.otherCharacters[char].holdTimer = 0;
										}
									}
	
								goodNoteHit(possibleNotes[i]);
	
								if(dontHit.contains(possibleNotes[i])) // rythm mode only ?????
								{
									noteMiss(possibleNotes[i].noteData, possibleNotes[i]);
									rythmArray[i] = true;
								}
							}
						}
					}
	
					if(possibleNotes.length > 0)
					{
						for(i in 0...possibleNotes.length)
						{
							if(possibleNotes[i].strumTime == noteDataTimes[possibleNotes[i].noteData])
								goodNoteHit(possibleNotes[i]);
						}
					}
	
					if(!utilities.Options.getData("ghostTapping"))
					{
						for(i in 0...justPressedArray.length)
						{
							var stopMiss:Bool = false;
							if (i == 2 && songHasDodges && characterPlayingAs == 0 && SONG.playerKeyCount == 5)
							{
								stopMiss = true;
							}
							if(justPressedArray[i] && !noteDataPossibles[i] && !rythmArray[i] && !stopMiss)
								noteMiss(i);
						}
					}
				}
		
				if (heldArray.contains(true) && generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if(heldArray[daNote.noteData] && daNote.isSustainNote && daNote.checkPlayerMustPress())
						{
							// goodness this if statement is shit lmfao
							if(((daNote.strumTime <= Conductor.songPosition && daNote.shouldHit) || 
								(!daNote.shouldHit && (daNote.strumTime > (Conductor.songPosition - (Conductor.safeZoneOffset * 0.4))
								&& daNote.strumTime < (Conductor.songPosition + Conductor.safeZoneOffset * 0.2)))))
							{
								if(currentPlayerCharacter.otherCharacters == null || currentPlayerCharacter.otherCharacters.length - 1 < daNote.character)
									currentPlayerCharacter.holdTimer = 0;
								else
									if(daNote.characters.length <= 1)
										currentPlayerCharacter.otherCharacters[daNote.character].holdTimer = 0;
									else
									{
										for(char in daNote.characters)
										{
											if(currentPlayerCharacter.otherCharacters.length - 1 >= char)
												currentPlayerCharacter.otherCharacters[char].holdTimer = 0;
										}
									}
	
								goodNoteHit(daNote);
							}
						}
					});
				}
		
				if(currentPlayerCharacter.otherCharacters == null)
				{
					if(currentPlayerCharacter.animation.curAnim != null)
						if (currentPlayerCharacter.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !heldArray.contains(true))
							if (currentPlayerCharacter.animation.curAnim.name.startsWith('sing') && !currentPlayerCharacter.animation.curAnim.name.endsWith('miss'))
								currentPlayerCharacter.dance();
				}
				else
				{
					for(character in currentPlayerCharacter.otherCharacters)
					{
						if(character.animation.curAnim != null)
							if (character.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !heldArray.contains(true))
								if (character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
									character.dance();
					}
				}
		
				currentPlayerStrums.forEach(function(spr:StrumNote)
				{
					if (justPressedArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
					{
						spr.playAnim('pressed');
						spr.resetAnim = 0;
					}

					if (releasedArray[spr.ID])
					{
						if(spr.animation.curAnim.name != "static")
							replay.recordInput(spr.ID, "released");

						spr.playAnim('static');
						spr.resetAnim = 0;
					}
				});
			}
			else
			{
				notes.forEachAlive(function(note:Note) {
					if(note.shouldHit)
					{
						if(note.checkPlayerMustPress() && note.strumTime <= Conductor.songPosition)
						{
							if(currentPlayerCharacter.otherCharacters == null || currentPlayerCharacter.otherCharacters.length - 1 < note.character)
								currentPlayerCharacter.holdTimer = 0;
							else
								if(note.characters.length <= 1)
									currentPlayerCharacter.otherCharacters[note.character].holdTimer = 0;
								else
								{
									for(char in note.characters)
									{
										if(currentPlayerCharacter.otherCharacters.length - 1 >= char)
											currentPlayerCharacter.otherCharacters[char].holdTimer = 0;
									}
								}
		
							goodNoteHit(note);
						}
					}
				});
	
				currentPlayerStrums.forEach(function(spr:StrumNote)
				{
					if(spr.animation.finished)
					{
						spr.playAnim("static");
					}
				});
				if(currentPlayerCharacter.otherCharacters == null)
				{
					if(currentPlayerCharacter.animation.curAnim != null)
						if (currentPlayerCharacter.holdTimer > Conductor.stepCrochet * 4 * 0.001)
							if (currentPlayerCharacter.animation.curAnim.name.startsWith('sing') && !currentPlayerCharacter.animation.curAnim.name.endsWith('miss'))
								currentPlayerCharacter.dance();
				}
				else
				{
					for(character in currentPlayerCharacter.otherCharacters)
					{
						if(character.animation.curAnim != null)
							if (character.holdTimer > Conductor.stepCrochet * 4 * 0.001)
								if (character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
									character.dance();
					}
				}
			}
		}
	}

	function noteMiss(direction:Int = 1, ?note:Note):Void
	{
		var canMiss = false;

		if(note == null)
			canMiss = true;
		else
		{
			if(note.checkPlayerMustPress())
				canMiss = true;
			if (note.isSustainNote)
				note.wasMissed = true;

			if (fdgod2PlayerSide >= 0)
			{
				if (note.character != fdgod2PlayerSide)
				{
					//trace('fuck');
					vocals.volume = 1;
					canMiss = false;
					return;
				}
			}
		}

		if(canMiss && !invincible && !utilities.Options.getData("botplay"))
		{
			if(note != null)
			{
				if(!note.isSustainNote)
					health -= note.missDamage;
				else
					health -= note.heldMissDamage;
			}
			else
			{
				if (uiSkin.type_Configs.get("default").exists("missDamage"))
					health -= Std.parseFloat(uiSkin.type_Configs.get("default").get("missDamage"));
				else 
					health -= 0.07;
			}
				

			if (combo > 5 && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');

			combo = 0;

			var missValues = false;

			if(note != null)
			{
				if(!note.isSustainNote || (utilities.Options.getData("missOnHeldNotes") && !note.missesSustains))
					missValues = true;
			}
			else
				missValues = true;

			if(missValues)
			{
				if(note != null)
				{
					if(utilities.Options.getData("missOnHeldNotes") && !note.missesSustains)
					{
						note.missesSustains = true;
	
						for(sustain in note.sustains)
						{
							if(sustain != null)
								sustain.missesSustains = true;
						}
					}
				}

				misses++;

				if(utilities.Options.getData("sideRatings") == true)
					updateRatingText();
			}

			totalNotes++;

			missSounds[FlxG.random.int(0, missSounds.length - 1)].play(true);

			songScore -= 10;

			if(note != null)
			{

				if(currentPlayerCharacter.otherCharacters != null && !(currentPlayerCharacter.otherCharacters.length - 1 < note.character))
				{
					if(note.characters.length <= 1)
						currentPlayerCharacter.otherCharacters[note.character].playAnim(NoteVariables.Character_Animation_Arrays[getCorrectKeyCount(true) - 1][direction] + "miss", true);
					else
					{
						for(character in note.characters)
						{
							if(currentPlayerCharacter.otherCharacters.length - 1 >= character)
								currentPlayerCharacter.otherCharacters[character].playAnim(NoteVariables.Character_Animation_Arrays[getCorrectKeyCount(true) - 1][direction] + "miss", true);
						}
					}
				}
				else
					currentPlayerCharacter.playAnim(NoteVariables.Character_Animation_Arrays[getCorrectKeyCount(true) - 1][direction] + "miss", true);

				if (note.arrow_Type == 'Wiik3Punch')
				{
					if (!isCheating) trace('missed punch note');
					isCheating = true; //you should already be dead, this is just in case someone edits the txt file to not instakill
				}
			}
			else
			{
				currentPlayerCharacter.playAnim(NoteVariables.Character_Animation_Arrays[getCorrectKeyCount(true) - 1][direction] + "miss", true);
			}
			calculateAccuracy();

			executeALuaState("playerOneMiss", [direction, Conductor.songPosition, (note != null ? note.arrow_Type : "default"), (note != null ? note.isSustainNote : false)]);
		}
	}

	var hitsound:FlxSound;

	function goodNoteHit(note:Note, ?setNoteDiff:Float):Void
	{
		if (!note.wasGoodHit)
		{
			camZooming = true;
			if(note.shouldHit && !note.isSustainNote)
			{
				popUpScore(note.strumTime, note.noteData % getCorrectKeyCount(true), setNoteDiff);
				combo += 1;

				if(hitSoundString != "none")
					hitsound.play(true);
			}
			else if(!note.shouldHit)
			{
				health -= note.hitDamage;
				misses++;
				missSounds[FlxG.random.int(0, missSounds.length - 1)].play(true);

				if(!playingReplay)
					replay.recordKeyHit(note.noteData % getCorrectKeyCount(true), note.strumTime, (setNoteDiff != null ? setNoteDiff : note.strumTime - Conductor.songPosition));

				if(utilities.Options.getData("sideRatings") == true)
					updateRatingText();
			}

			if(note.shouldHit && note.isSustainNote)
				health += 0.02;

			if(!note.isSustainNote)
				totalNotes++;

			calculateAccuracy();

			var lua_Data:Array<Dynamic> = [note.noteData, Conductor.songPosition, note.arrow_Type, note.strumTime];

			var singAnim:String = NoteVariables.Character_Animation_Arrays[getCorrectKeyCount(true) - 1][Std.int(Math.abs(note.noteData % getCorrectKeyCount(true)))] + (characterPlayingAs == 1 ? altAnim : "") + note.singAnimSuffix;
			if (note.singAnimPrefix != 'sing')
			{
				singAnim = singAnim.replace('sing', note.singAnimPrefix);
			}

			if(currentPlayerCharacter.otherCharacters != null && !(currentPlayerCharacter.otherCharacters.length - 1 < note.character))
				if(note.characters.length <= 1)
				{
					if(note.isSustainNote)
						executeALuaState(getSingLuaFuncName(true)+"SingHeld"+note.character, lua_Data);
					else
						executeALuaState(getSingLuaFuncName(true)+"Sing"+note.character, lua_Data);
					
					currentPlayerCharacter.otherCharacters[note.character].playAnim(singAnim, true, false, 0, note.strumTime);
				}
					
				else
				{
					for(character in note.characters)
					{
						if(currentPlayerCharacter.otherCharacters.length - 1 >= character)
							currentPlayerCharacter.otherCharacters[character].playAnim(singAnim, true, false, 0, note.strumTime);
					}
				}
			else
				currentPlayerCharacter.playAnim(singAnim, true, false, 0, note.strumTime);
		
			if(note.isSustainNote)
				executeALuaState(getSingLuaFuncName(true)+"SingHeld", lua_Data);
			else
				executeALuaState(getSingLuaFuncName(true)+"Sing", lua_Data);

			executeALuaState(getSingLuaFuncName(false)+'SingExtra', [Math.abs(note.noteData), notes.members.indexOf(note), note.arrow_Type, note.isSustainNote]);

			if(startedCountdown)
			{
				currentPlayerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (note.arrow_Type == 'REJECTED_NOTES')
			{
				if (!isCheating) trace('hit death note');
				isCheating = true; //you should already be dead, this is just in case someone edits the txt file to not instakill
			}
			

			if (!note.isSustainNote)
			{
				if (shouldKillNotes)
					note.kill();
				notes.remove(note, true);
				if (shouldKillNotes)
					note.destroy();
			}

		}
	}

	override function stepHit()
	{
		super.stepHit();

		var gamerValue = 20 * songMultiplier;
		
		if (FlxG.sound.music.time > Conductor.songPosition + gamerValue || FlxG.sound.music.time < Conductor.songPosition - gamerValue || FlxG.sound.music.time < 500 && (FlxG.sound.music.time > Conductor.songPosition + 5 || FlxG.sound.music.time < Conductor.songPosition - 5))
			resyncVocals();

		setLuaVar("curStep", curStep);
		executeALuaState("stepHit", [curStep]);
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic && startedCountdown)
			notes.sort(FlxSort.byY, (utilities.Options.getData("downscroll") ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		if (SONG.notes[Math.floor(curStep / Conductor.stepsPerSection)] != null)
		{
			if (SONG.notes[Math.floor(curStep / Conductor.stepsPerSection)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / Conductor.stepsPerSection)].bpm, songMultiplier);
				FlxG.log.add('CHANGED BPM!');
			}

			// Dad doesnt interupt his own notes
			if(currentOpponentCharacter.otherCharacters == null)
			{
				if(currentOpponentCharacter.animation.curAnim != null)
					if ((currentOpponentCharacter.animation.curAnim.name.startsWith("sing") && currentOpponentCharacter.animation.curAnim.finished || !currentOpponentCharacter.animation.curAnim.name.startsWith("sing")) && !currentOpponentCharacter.curCharacter.startsWith('gf'))
						currentOpponentCharacter.dance((characterPlayingAs == 0 ? altAnim : ""));
			}
			else
			{
				for(character in currentOpponentCharacter.otherCharacters)
				{
					if(character.animation.curAnim != null)
						if ((character.animation.curAnim.name.startsWith("sing") && character.animation.curAnim.finished || !character.animation.curAnim.name.startsWith("sing")) && !character.curCharacter.startsWith('gf'))
							character.dance((characterPlayingAs == 0 ? altAnim : ""));
				}
			}
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % Conductor.timeScale[0] == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		gameHUD.iconBump(songMultiplier);

		if(gfSpeed < 1)
			gfSpeed = 1;

		if (curBeat % gfSpeed == 0 && !dad.curCharacter.startsWith('gf'))
			gf.dance();
		
		if(dad.animation.curAnim != null)
			if (curBeat % gfSpeed == 0 && dad.curCharacter.startsWith('gf') && (dad.animation.curAnim.name.startsWith("sing") && dad.animation.curAnim.finished || !dad.animation.curAnim.name.startsWith("sing")))
				dad.dance();

		if (currentPlayerCharacter.otherCharacters == null)
		{
			if(currentPlayerCharacter.animation.curAnim != null)
				if(!currentPlayerCharacter.animation.curAnim.name.startsWith("sing"))
					currentPlayerCharacter.dance((characterPlayingAs == 1 ? altAnim : ""));
		}
		else
		{
			for(character in currentPlayerCharacter.otherCharacters)
			{
				if(character.animation.curAnim != null)
					if(!character.animation.curAnim.name.startsWith("sing"))
						character.dance((characterPlayingAs == 1 ? altAnim : ""));
			}
		}

		if (curBeat % 8 == 7 && SONG.song.toLowerCase() == 'bopeebo' && boyfriend.otherCharacters == null)
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song.toLowerCase() == 'tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}
		else if(curBeat % 16 == 15 && SONG.song.toLowerCase() == 'tutorial' && dad.curCharacter != 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			gf.playAnim('cheer', true);
		}

		if (playSpamSections)
		{
			if (currentSpamSection > -1)
			{
				var sec = Math.floor(curStep / Conductor.stepsPerSection);
				if (sec >= spamSectionData[currentSpamSection].end)
				{
					if (currentSpamSection >= spamSectionData.length - 1)
					{
						endSong();
					}
					else
						swtichSpamSong();
				}
			}

			
		}
			

		stage.beatHit();

		executeALuaState("beatHit", [curBeat]);
	}

	function updateRatingText()
	{
		if(utilities.Options.getData("sideRatings") == true)
		{
			gameHUD.updateRatingText(returnStupidRatingText());
		}
	}

	public function returnStupidRatingText():String
	{
		var ratingArray = [
			ratings.get("marvelous"),
			ratings.get("sick"),
			ratings.get("good"),
			ratings.get("bad"),
			ratings.get("shit")
		];

		var MA = ratingArray[1] + ratingArray[2] + ratingArray[3] + ratingArray[4];
		var PA = ratingArray[2] + ratingArray[3] + ratingArray[4];

		return (
			(utilities.Options.getData("marvelousRatings") == true ? "Krazy: " + Std.string(ratingArray[0]) + "\n" : "") +
			"Sick: " + Std.string(ratingArray[1]) + "\n" +
			"Good: " + Std.string(ratingArray[2]) + "\n" +
			"Guh: " + Std.string(ratingArray[3]) + "\n" +
			"Mid: " + Std.string(ratingArray[4]) + "\n" +
			"Combo Breaks: " + Std.string(misses) + "\n" +
			(utilities.Options.getData("marvelousRatings") == true && ratingArray[0] > 0 && MA > 0 ? "MA: " + Std.string(FlxMath.roundDecimal(ratingArray[0] / MA, 2)) + "\n" : "") +
			(ratingArray[1] > 0 && PA > 0 ? "PA: " + Std.string(FlxMath.roundDecimal((ratingArray[1] + ratingArray[0]) / PA, 2)) + "\n" : "")
		);
	}

	var curLight:Int = 0;

	public static function getCharFromEvent(eventVal:String):Character
	{
		switch(eventVal.toLowerCase())
		{
			case "girlfriend" | "gf" | "player3" | "2":
				return PlayState.gf;
			case "dad" | "opponent" | "player2" | "1":
				return PlayState.dad;
			case "bf" | "boyfriend" | "player" | "player1" | "0":
				return PlayState.boyfriend;
		}

		return PlayState.boyfriend;
	}

	function removeBgStuff()
	{
		remove(stage);
		remove(stage.foregroundSprites);
		remove(stage.infrontOfGFSprites);

		if(gf.otherCharacters == null)
		{
			if(gf.coolTrail != null)
				remove(gf.coolTrail);

			remove(gf);
		}
		else
		{
			for(character in gf.otherCharacters)
			{
				if(character.coolTrail != null)
					remove(character.coolTrail);
				
				remove(character);
			}
		}

		if(dad.otherCharacters == null)
		{
			if(dad.coolTrail != null)
				remove(dad.coolTrail);

			remove(dad);
		}
		else
		{
			for(character in dad.otherCharacters)
			{
				if(character.coolTrail != null)
					remove(character.coolTrail);
				
				remove(character);
			}
		}

		if(boyfriend.otherCharacters == null)
		{
			if(boyfriend.coolTrail != null)
				remove(boyfriend.coolTrail);

			remove(boyfriend);
		}
		else
		{
			for(character in boyfriend.otherCharacters)
			{
				if(character.coolTrail != null)
					remove(character.coolTrail);
				
				remove(character);
			}
		}
	}

	function addBgStuff()
	{
		stage.setCharOffsets();

		add(stage);

		if(dad.curCharacter.startsWith("gf"))
		{
			dad.setPosition(gf.x, gf.y);
			gf.visible = false;
		}
		else if(gf.visible == false && gf.curCharacter != "")
			gf.visible = true;

		if(gf.otherCharacters == null)
		{
			if(gf.coolTrail != null)
			{
				remove(gf.coolTrail);
				add(gf.coolTrail);
			}

			remove(gf);
			add(gf);
		}
		else
		{
			for(character in gf.otherCharacters)
			{
				if(character.coolTrail != null)
				{
					remove(character.coolTrail);
					add(character.coolTrail);
				}
				
				remove(character);
				add(character);
			}
		}

		if(!dad.curCharacter.startsWith("gf"))
			add(stage.infrontOfGFSprites);

		if(dad.otherCharacters == null)
		{
			if(dad.coolTrail != null)
			{
				remove(dad.coolTrail);
				add(dad.coolTrail);
			}

			remove(dad);
			add(dad);
		}
		else
		{
			for(character in dad.otherCharacters)
			{
				if(character.coolTrail != null)
				{
					remove(character.coolTrail);
					add(character.coolTrail);
				}
				
				remove(character);
				add(character);
			}
		}

		if(dad.curCharacter.startsWith("gf"))
			add(stage.infrontOfGFSprites);

		if(boyfriend.otherCharacters == null)
		{
			if(boyfriend.coolTrail != null)
			{
				remove(boyfriend.coolTrail);
				add(boyfriend.coolTrail);
			}
			
			remove(boyfriend);
			add(boyfriend);
		}
		else
		{
			for(character in boyfriend.otherCharacters)
			{
				if(character.coolTrail != null)
				{
					remove(character.coolTrail);
					add(character.coolTrail);
				}
				
				remove(character);
				add(character);
			}
		}

		add(stage.foregroundSprites);
	}

	function eventCharacterShit(event:Array<Dynamic>)
	{
		removeBgStuff();
		
		if(gfMap.exists(event[3]) || bfMap.exists(event[3]) || dadMap.exists(event[3])) // prevent game crash
		{
			switch(event[2].toLowerCase())
			{
				case "girlfriend" | "gf" | "2":
					var oldGf = gf;
					oldGf.alpha = 0.00001;
					
					if(oldGf.otherCharacters != null)
					{
						for(character in oldGf.otherCharacters)
						{
							character.alpha = 0.00001;
						}
					}
					
					var newGf = gfMap.get(event[3]);
					newGf.alpha = 1;
					gf = newGf;
	
					if(newGf.otherCharacters != null)
					{
						for(character in newGf.otherCharacters)
						{
							character.alpha = 1;
						}
					}
	
					#if linc_luajit
					if(executeModchart && luaModchart != null)
						luaModchart.setupTheShitCuzPullRequestsSuck();
	
					if(stage.stageScript != null)
						stage.stageScript.setupTheShitCuzPullRequestsSuck();

					if(generatedSomeDumbEventLuas)
					{
						for(event in event_luas.keys())
						{
							if(event_luas.exists(event))
								event_luas.get(event).setupTheShitCuzPullRequestsSuck();
						}
					}
					#end
				case "dad" | "opponent" | "1":
					var oldDad = dad;
					oldDad.alpha = 0.00001;
	
					if(oldDad.otherCharacters != null)
					{
						for(character in oldDad.otherCharacters)
						{
							character.alpha = 0.00001;
						}
					}
					
					var newDad = dadMap.get(event[3]);
					newDad.alpha = 1;
					dad = newDad;
	
					if(newDad.otherCharacters != null)
					{
						for(character in newDad.otherCharacters)
						{
							character.alpha = 1;
						}
					}
	
					#if linc_luajit
					if(executeModchart && luaModchart != null)
						luaModchart.setupTheShitCuzPullRequestsSuck();
	
					if(stage.stageScript != null)
						stage.stageScript.setupTheShitCuzPullRequestsSuck();

					if(generatedSomeDumbEventLuas)
					{
						for(event in event_luas.keys())
						{
							if(event_luas.exists(event))
								event_luas.get(event).setupTheShitCuzPullRequestsSuck();
						}
					}
					#end
	
					gameHUD.changeOpponentIcon(dad.icon);
					gameHUD.changeHealthBarColors(boyfriend.barColor, dad.barColor);
				case "bf" | "boyfriend" | "player" | "0":
					var oldBF = boyfriend;
					oldBF.alpha = 0.00001;
	
					if(oldBF.otherCharacters != null)
					{
						for(character in oldBF.otherCharacters)
						{
							character.alpha = 0.00001;
						}
					}
					
					var newBF = bfMap.get(event[3]);
					newBF.alpha = 1;
					boyfriend = newBF;
	
					if(newBF.otherCharacters != null)
					{
						for(character in newBF.otherCharacters)
						{
							character.alpha = 1;
						}
					}
	
					#if linc_luajit
					if(executeModchart && luaModchart != null)
						luaModchart.setupTheShitCuzPullRequestsSuck();
	
					if(stage.stageScript != null)
						stage.stageScript.setupTheShitCuzPullRequestsSuck();

					if(generatedSomeDumbEventLuas)
					{
						for(event in event_luas.keys())
						{
							if(event_luas.exists(event))
								event_luas.get(event).setupTheShitCuzPullRequestsSuck();
						}
					}
					#end
	
					gameHUD.changePlayerIcon(boyfriend.icon);
					gameHUD.changeHealthBarColors(boyfriend.barColor, dad.barColor);
			}
		}
		else
			Application.current.window.alert("The character " + event[3] + " isn't in any character cache!\nHow did this happen? ¯|_(ツ)_|¯",
					"Leather Engine's No Crash, We Help Fix Stuff Tool");

		if (characterPlayingAs == 1)
		{
			currentPlayerCharacter = dad;
			currentOpponentCharacter = boyfriend;
		}
		else 
		{
			currentPlayerCharacter = boyfriend;
			currentOpponentCharacter = dad;
		}

		addBgStuff();
	}

	public function updateSongInfoText()
	{
		var songThingy = songLength - FlxG.sound.music.time;

		var seconds = Math.floor(songThingy / 1000);
		seconds = Std.int(seconds / songMultiplier);
		if(seconds < 0) seconds = 0;

		var text:String = '';
		switch(funnyTimeBarStyle.toLowerCase())
		{
			default: // includes 'leather engine'
				text = SONG.song + " - " + storyDifficultyStr + ' (${FlxStringUtil.formatTime(seconds, false)})';
			case "psych engine":
				text = '${FlxStringUtil.formatTime(seconds, false)}';
			case "old kade engine":
				text = SONG.song;
		}
		text += (utilities.Options.getData("botplay") ? " (BOT)" : "");
		text += (utilities.Options.getData("noDeath") ? " (NO DEATH)" : ""); 
		text += (didDie ? " (DIED)" : ""); 
		text += (utilities.Options.getData("mechanics") ? "" : " (NO MECHANICS)");
		text += (playingReplay ? " (REPLAY)" : "");
		gameHUD.updateSongInfoText(text);
	}

	function executeALuaState(name:String, arguments:Array<Dynamic>, ?execute_on:Execute_On = BOTH, ?stage_arguments:Array<Dynamic>)
	{
		if (utilities.Options.getData("forceDisableScripts"))
			return;

		if (boyfriend != null && boyfriend.stunned)
			return;

		if(stage_arguments == null)
			stage_arguments = arguments;

		#if linc_luajit
		if(executeModchart && luaModchart != null && execute_on != STAGE)
			luaModchart.executeState(name, arguments);

		if(stage.stageScript != null && execute_on != MODCHART)
			stage.stageScript.executeState(name, stage_arguments);

		if(execute_on != STAGE)
		{
			for(script in event_luas.keys())
			{
				if(event_luas.exists(script))
					event_luas.get(script).executeState(name, arguments);	
			}
		}
		#end
	}

	function setLuaVar(name:String, data:Dynamic, ?execute_on:Execute_On = BOTH, ?stage_data:Dynamic)
	{
		if (utilities.Options.getData("forceDisableScripts"))
			return;
		if(stage_data == null)
			stage_data = data;

		#if linc_luajit
		if(executeModchart && luaModchart != null && execute_on != STAGE)
			luaModchart.setVar(name, data);

		if(stage.stageScript != null && execute_on != MODCHART)
			stage.stageScript.setVar(name, stage_data);

		if(execute_on != STAGE)
		{
			for(script in event_luas.keys())
			{
				if(event_luas.exists(script))
					event_luas.get(script).setVar(name, data);	
			}
		}
		#end
	}

	function getLuaVar(name:String, type:String):Dynamic
	{
		#if linc_luajit
		var luaVar:Dynamic = null;

		// we prioritize modchart cuz frick you
		
		if(stage.stageScript != null)
		{
			var newLuaVar = stage.stageScript.getVar(name, type);

			if(newLuaVar != null)
				luaVar = newLuaVar;
		}

		for(script in event_luas.keys())
		{
			if(event_luas.exists(script))
			{
				var newLuaVar = event_luas.get(script).getVar(name, type);

				if(newLuaVar != null)
					luaVar = newLuaVar;
			}
		}

		if(executeModchart && luaModchart != null)
		{
			var newLuaVar = luaModchart.getVar(name, type);

			if(newLuaVar != null)
				luaVar = newLuaVar;
		}

		if(luaVar != null)
			return luaVar;
		#end

		return null;
	}

	public function processEvent(event:Array<Dynamic>)
	{
		switch(event[0].toLowerCase())
		{
			#if html5
			case "hey!":
				var charString = event[2].toLowerCase();

				var char:Int = 0;

				if(charString == "bf" || charString == "boyfriend" || charString == "player" || charString == "player1")
					char = 1;

				if(charString == "gf" || charString == "girlfriend" || charString == "player3")
					char = 2;

				switch(char)
				{
					case 0:
						boyfriend.playAnim("hey", true);
						gf.playAnim("cheer", true);
					case 1:
						boyfriend.playAnim("hey", true);
					case 2:
						gf.playAnim("cheer", true);
				}
			case "set gf speed":
				if(Std.parseInt(event[2]) != null)
					gfSpeed = Std.parseInt(event[2]);
			case "character will idle":
				var char = getCharFromEvent(event[2]);

				var funny = Std.string(event[3]).toLowerCase() == "true";

				char.shouldDance = funny;
			case "set camera zoom":
				var defaultCamZoomThing:Float = Std.parseFloat(event[2]);
				var hudCamZoomThing:Float = Std.parseFloat(event[3]);

				if(Math.isNaN(defaultCamZoomThing))
					defaultCamZoomThing = defaultCamZoom;

				if(Math.isNaN(hudCamZoomThing))
					hudCamZoomThing = 1;

				defaultCamZoom = defaultCamZoomThing;
				defaultHudCamZoom = hudCamZoomThing;
			case "change character alpha":
				var char = getCharFromEvent(event[2]);

				var alphaVal:Float = Std.parseFloat(event[3]);

				if(Math.isNaN(alphaVal))
					alphaVal = 0.5;

				char.alpha = alphaVal;
			case "play character animation":
				var character:Character = getCharFromEvent(event[2]);

				var anim:String = "idle";

				if(event[3] != "")
					anim = event[3];

				character.playAnim(anim, true);
			case "camera flash":
				var time = Std.parseFloat(event[3]);

				if(Math.isNaN(time))
					time = 1;

				if(utilities.Options.getData("flashingLights"))
					camGame.flash(FlxColor.fromString(event[2].toLowerCase()), time);
			#end
			case "add camera zoom":
				if(utilities.Options.getData("cameraZooms") && ((FlxG.camera.zoom < 1.35 && camZooming) || !camZooming))
				{
					var addGame:Float = Std.parseFloat(event[2]);
					var addHUD:Float = Std.parseFloat(event[3]);

					if(Math.isNaN(addGame))
						addGame = 0.015;

					if(Math.isNaN(addHUD))
						addHUD = 0.03;

					FlxG.camera.zoom += addGame;
					camHUD.zoom += addHUD;
				}
			case "screen shake":
				if(Options.getData("screenShakes"))
				{
					var valuesArray:Array<String> = [event[2], event[3]];
					var targetsArray:Array<FlxCamera> = [camGame, camHUD];
	
					for (i in 0...targetsArray.length)
					{
						var split:Array<String> = valuesArray[i].split(',');
						var duration:Float = 0;
						var intensity:Float = 0;
	
						if(split[0] != null) duration = Std.parseFloat(split[0].trim());
						if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
						if(Math.isNaN(duration)) duration = 0;
						if(Math.isNaN(intensity)) intensity = 0;
	
						if(duration > 0 && intensity != 0)
							targetsArray[i].shake(intensity, duration);
					}
				}
			case "change scroll speed":
				var duration:Float = Std.parseFloat(event[3]);

				if(duration == Math.NaN)
					duration = 0;

				var funnySpeed = Std.parseFloat(event[2]);

				//turn into a multiplier to work for custom scroll speeds
				//i use a slower scroll speed fuckj you
				var multFromOGSpeed = funnySpeed/SONG.speed;

				if(!Math.isNaN(funnySpeed))
				{
					if(duration > 0)
						FlxTween.tween(this, {speed: (startSpeed*multFromOGSpeed)/songMultiplier}, duration);
					else
						speed = (startSpeed*multFromOGSpeed)/songMultiplier;
				}
			case "change camera speed":
				var speed:Float = Std.parseFloat(event[2]);
				if(Math.isNaN(speed))
					speed = 1;
				cameraSpeed = speed;
			case "change camera zoom speed":
				var speed:Float = Std.parseFloat(event[2]);
				if(Math.isNaN(speed))
					speed = 1;
				cameraZoomSpeed = speed;
			case "character will idle?":
				var char = getCharFromEvent(event[2]);

				var funny = Std.string(event[3]).toLowerCase() == "true";

				char.shouldDance = funny;
			case "change character":
				if(utilities.Options.getData("charsAndBGs"))
					eventCharacterShit(event);
			case "change ui skin":
				gameHUD.clearHUD();
				gameHUD.createHUD(event[2], event[3]);
				if (storedUISkins.exists(event[2]))
				{
					uiSkin = storedUISkins.get(event[2]);
					for (strum in strumLineNotes.members)
					{
						strum.changeUISkin(uiSkin);
					}
				}
			case "change stage":
				if(utilities.Options.getData("charsAndBGs"))
				{
					removeBgStuff();
					
					if(!Options.getData("preloadChangeBGs"))
					{
						stage.kill();
						stage.foregroundSprites.kill();
						stage.infrontOfGFSprites.kill();
	
						stage.foregroundSprites.destroy();
						stage.infrontOfGFSprites.destroy();
						stage.destroy();
					}
					else
					{
						stage.active = false;

						stage.visible = false;
						stage.foregroundSprites.visible = false;
						stage.infrontOfGFSprites.visible = false;
					}

					if(!Options.getData("preloadChangeBGs"))
						stage = new StageGroup(event[2]);
					else
						stage = stageMap.get(event[2]);

					stage.visible = true;
					stage.foregroundSprites.visible = true;
					stage.infrontOfGFSprites.visible = true;
					stage.active = true;

					defaultCamZoom = stage.camZoom;

					#if linc_luajit
					stage.createLuaStuff();

					executeALuaState("create", [stage.stage], STAGE);
			
					if(stage.stageScript != null)
						stage.stageScript.setupTheShitCuzPullRequestsSuck();
			
					for(i in 0...strumLineNotes.length)
					{
						var member = strumLineNotes.members[i];
			
						setLuaVar("defaultStrum" + i + "X", member.x);
						setLuaVar("defaultStrum" + i + "Y", member.y);
						setLuaVar("defaultStrum" + i + "Angle", member.angle);
					}
			
					executeALuaState("start", [stage.stage], STAGE);
					setLuaVar("curStage", stage.stage);
					#end

					addBgStuff();
				}
		}

		if (!utilities.Options.getData("forceDisableScripts"))
		{
			#if linc_luajit
			if(!event_luas.exists(event[0].toLowerCase()) && Assets.exists(Paths.lua("event data/" + event[0].toLowerCase())))
			{
				#if mobile 
				event_luas.set(event[0].toLowerCase(), ModchartUtilities.createModchartUtilities(SUtil.getStorageDirectory() + Paths.lua("event data/" + event[0].toLowerCase())));
				#else
				event_luas.set(event[0].toLowerCase(), ModchartUtilities.createModchartUtilities(PolymodAssets.getPath(Paths.lua("event data/" + event[0].toLowerCase()))));
				#end
				generatedSomeDumbEventLuas = true;
			}
			#end
		}


		//                            name       pos      param 1   param 2
		executeALuaState("onEvent", [event[0], event[1], event[2], event[3]]);
	}

	public function setupNoteTypeScript(noteType:String)
	{
		if (!utilities.Options.getData("forceDisableScripts"))
		{
			#if linc_luajit
			if(!event_luas.exists(noteType.toLowerCase()) && Assets.exists(Paths.lua("arrow types/" + noteType)))
			{
				#if mobile 
				event_luas.set(noteType.toLowerCase(), ModchartUtilities.createModchartUtilities(SUtil.getStorageDirectory() + Paths.lua("arrow types/" + noteType)));		
				#else
				event_luas.set(noteType.toLowerCase(), ModchartUtilities.createModchartUtilities(PolymodAssets.getPath(Paths.lua("arrow types/" + noteType))));			
				#end
				generatedSomeDumbEventLuas = true;
			}
			#end
		}

	}

	public function calculateAccuracy()
	{
		if(totalNotes != 0 && !switchedStates)
		{
			accuracy = 100 / (totalNotes / hitNotes);
			accuracy = FlxMath.roundDecimal(accuracy, 2);
		}

		updateRating();
	}

	public function updateRating()
	{
		ratingStr = Ratings.getRank(accuracy, misses);
	}

	function getSingLuaFuncName(player:Bool)
	{
		var name = "playerTwo";
		if ((player && characterPlayingAs == 0) || (characterPlayingAs == 1 && !player))
		{
			name = "playerOne";
		}
		return name;
	}
	function getCorrectKeyCount(player:Bool)
	{
		var kc = SONG.keyCount;
		if ((player && characterPlayingAs == 0) || (characterPlayingAs == 1 && !player))
		{
			kc = SONG.playerKeyCount;
		}
		return kc;
	}
}

enum Execute_On
{
	BOTH;
	MODCHART;
	STAGE;
}
