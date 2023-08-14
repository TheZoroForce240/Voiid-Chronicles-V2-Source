package states;

import online.LeaderboardSubstate;
import online.GameJolt;
import online.Multiplayer;
import online.Leaderboards;
import online.ServerCreateSubstate.SimpleButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import states.VoiidAwardsState.AwardManager;
import utilities.Options;
import flixel.addons.ui.FlxButtonPlus;
import flixel.ui.FlxButton;
import online.ServerCreateSubstate;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import shaders.Shaders.BetterBlurEffect;
import openfl.filters.ShaderFilter;
import shaders.Shaders.BlurEffect;
import flixel.FlxCamera;
import flixel.FlxStrip;
import shaders.Shaders.ColorFillEffect;
import flixel.util.FlxTimer;
import substates.ResetScoreSubstate;
#if discord_rpc
import utilities.Discord.DiscordClient;
#end

import flixel.system.FlxSound;
import lime.app.Application;
import flixel.tweens.FlxTween;
import game.Song;
import game.Highscore;
import utilities.CoolUtil;
import ui.HealthIcon;
import ui.Alphabet;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.tweens.FlxEase; 

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	static var curSelected:Int = 0;
	static var curDifficulty:Int = 1;
	static var curSpeed:Float = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	//var speedText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var songsReady:Bool = false;

	public static var coolColors:Array<Int> = [0xFF7F1833, 0xFF7C689E, -14535868, 0xFFA8E060, 0xFFFF87FF, 0xFF8EE8FF, 0xFFFF8CCD, 0xFFFF9900];
	private var bg:FlxSprite;
	private var gradient:FlxSprite;
	private var selectedColor:Int = 0xFF7F1833;
	private var scoreBG:FlxSprite;
	private var scoreBGTriangle:FlxStrip;

	private var curRank:String = "N/A";

	private var curDiffString:String = "normal";
	private var curDiffArray:Array<String> = ["easy", "normal", "hard"];

	var vocals:FlxSound = new FlxSound();

	var canEnterSong:Bool = true;

	var whiteShader:ColorFillEffect;

	// thx psych engine devs
	var colorTween:FlxTween;

	var up:FlxSprite;
	var down:FlxSprite;

	var ports:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	var songPortMap:Map<String, String> = new Map<String, String>();

	var selectedSong:Bool = false;
	
	var camGame:FlxCamera;
	var camHUD:FlxCamera;
	var cameraBlur:BetterBlurEffect = new BetterBlurEffect();

	var blurTween:FlxTween;
	var hudTween:FlxTween;

	var difficultyImage:FlxSprite;
	var songNameThing:Alphabet;
	var songIcon:HealthIcon;

	var leftDiffArr:FlxSprite;
	var rightDiffArr:FlxSprite;
	var leftSpeedArr:FlxSprite;
	var rightSpeedArr:FlxSprite;

	var songSpeedText:FlxText;
	var diffBGThing:FlxSprite;

	var leaderboardTitleText:FlxText;
	var leaderboardText:FlxText;
	var leaderboardBG:FlxSprite;
	var leaderboardBGTriangle:FlxStrip;

	var diffImageMap:Map<String, String> = [
		"VOIID" => "Voiid",
		"VOIID CANON" => "Canon",
		"VOIID GOD" => "God",
		"VOIID MANIA" => "4KMania"
	];

	//which song needed to unlock a freeplay only song
	var songUnlockRequirements:Map<String, String> = [
		//for example, to unlock tko, need to beat king hit
		"tko" => "King Hit",
		"king hit wawa" => "King Hit",
		"alter ego" => "Boxing Match",
		"flaming glove" => "Boxing Match",
		"rejected" => "King Hit",
		"sport swinging" => "Boxing Match",
		"boxing gladiators" => "Sport Swinging",
	];

	function isSongBeaten(s:String)
	{
		var saveStr = "beat_" + s.toLowerCase();
		if (Options.getData(saveStr, "progress") != null)
		{
			return true;
		}
		return false;
	}

	var unlockText:FlxText;

	var disconnectButton:SimpleButton;

	function getEnterPress() //temp
	{

		#if mobile
		if (!selectedSong)
		{
			if (MobileControls.verticalPressAlphabet(grpSongs, curSelected) == 0)
				return true;
		}
		else
		{
			if (MobileControls.justPressedAny())
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

		return FlxG.keys.justPressed.ENTER;
	}

	override function create()
	{
		MusicBeatState.windowNameSuffix = " Freeplay";
		Main.display.visible = false;
		
		var black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		#if !mobile
		if (utilities.Options.getData("shaders"))
			camGame.setFilters([new ShaderFilter(cameraBlur.shader)]);
		#end

		camHUD.bgColor.alpha = 0;
		camHUD.alpha = 0.0;

		#if !mobile
		whiteShader = new ColorFillEffect();
		whiteShader.red = 255;
		whiteShader.green = 255;
		whiteShader.blue = 255;
		#end

		#if NO_PRELOAD_ALL
		if(!songsReady)
		{
			Assets.loadLibrary("songs").onComplete(function (_) {
				FlxTween.tween(black, {alpha: 0}, 0.5, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						remove(black);
						black.kill();
						black.destroy();
					}
				});
	
				songsReady = true;
			});
		}
		#else
		songsReady = true;
		#end

		if(FlxG.sound.music == null || !FlxG.sound.music.playing)
			TitleState.playTitleMusic();

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Freeplay", null, "empty", "logo");
		#end

		// Loops through all songs in freeplaySonglist.txt
		for (i in 0...initSonglist.length)
		{
			// Creates an array of their strings
			var listArray = initSonglist[i].split(":");

			// Variables I like yes mmmm tasty
			var week = Std.parseInt(listArray[2]);
			var icon = listArray[1];
			var song = listArray[0];
			
			var diffsStr = listArray[3];
			var diffs = ["easy", "normal", "hard"];

			var color = listArray[4];
			var actualColor:Null<FlxColor> = null;

			if(color != null)
				actualColor = FlxColor.fromString(color);

			if(diffsStr != null)
				diffs = diffsStr.split(",");

			if (listArray[5] != null)
			{
				songPortMap.set(song, listArray[5]);
			}

			var locked:Bool = true;
			if (isSongBeaten(song))
			{
				locked = false;
			}
			else
			{
				var songLower = song.toLowerCase();
				if (songUnlockRequirements.exists(songLower))
				{
					//trace(songLower + " - " + songUnlockRequirements.get(songLower));
					if (isSongBeaten(songUnlockRequirements.get(songLower)))
						locked = false;
				}

				if (!ChartChecker.exists(songLower)) //auto unlock for custom songs
					locked = false;

				
			}

			switch(song.toLowerCase())
			{
				case "tutorial": 
					//die
				case "voiid rush": 
					if (VoiidMainMenuState.devBuild || AwardManager.isAllUnlocked())
						songs.push(new SongMetadata(song, week, icon, diffs, actualColor, false));
				default:
					songs.push(new SongMetadata(song, week, icon, diffs, actualColor, locked));
			}
		}
		//trace(songPortMap);


		//if(utilities.Options.getData("menuBGs"))
		bg = new FlxSprite().loadGraphic(Paths.image('freeplay/BG'));
		add(bg);

		var dots:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("freeplay/dots"));
		dots.cameras = [camHUD];
		add(dots);

		gradient = new FlxSprite().loadGraphic(Paths.image('freeplay/Gradient'));
		gradient.blend = flash.display.BlendMode.SCREEN;
		up = new FlxSprite().loadGraphic(Paths.image('freeplay/Up_Arrow')); add(up);
		down = new FlxSprite().loadGraphic(Paths.image('freeplay/Down_Arrow')); add(down);
		var splashes = new FlxSprite().loadGraphic(Paths.image('freeplay/Splashes')); add(splashes);
		//else
			//bg = new FlxSprite().makeGraphic(1286, 730, FlxColor.fromString("#E1E1E1"), false, "optimizedMenuDesat");
		


		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		scoreText = new FlxText(0, FlxG.height-26-72+5, 0, "", 32);
		
		
		scoreBG = new FlxSprite(scoreText.x + 6, FlxG.height-26-72).makeGraphic(1, 1, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);
		scoreBG.cameras = [camHUD];

		scoreBGTriangle = new FlxStrip(scoreBG.x+scoreBG.width, scoreBG.y);
		scoreBGTriangle.makeGraphic(1, 1, 0xFF000000);
		scoreBGTriangle.alpha = 0.6;
		scoreBGTriangle.antialiasing = true;
				//    1      2       3
				//   x  y  x   y   x   y
		var verts = [0, 0, 0, 72, 50, 72];
		for (vert in verts)
		{
			scoreBGTriangle.uvtData.push(0); //should only be black so whatever
			scoreBGTriangle.vertices.push(vert);
		}
		scoreBGTriangle.indices.push(0);
		scoreBGTriangle.indices.push(1);
		scoreBGTriangle.indices.push(2);
		//#if !mobile
		add(scoreBGTriangle);
		scoreBGTriangle.cameras = [camHUD];
		//#end

		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		add(scoreText);
		scoreText.cameras = [camHUD];

		leaderboardBG = new FlxSprite(0, FlxG.height-26-72).makeGraphic(1, 1, 0xFF000000);
		leaderboardBG.alpha = 0.6;
		add(leaderboardBG);
		leaderboardBG.cameras = [camHUD];

		leaderboardBGTriangle = new FlxStrip(0,0);
		leaderboardBGTriangle.makeGraphic(1, 1, 0xFF000000);
		leaderboardBGTriangle.alpha = 0.6;
		leaderboardBGTriangle.antialiasing = true;

		for (vert in verts)
		{
			leaderboardBGTriangle.uvtData.push(0); //should only be black so whatever
			leaderboardBGTriangle.vertices.push(vert);
		}
		leaderboardBGTriangle.indices.push(0);
		leaderboardBGTriangle.indices.push(1);
		leaderboardBGTriangle.indices.push(2);
		//#if !mobile
		add(leaderboardBGTriangle);
		leaderboardBGTriangle.cameras = [camHUD];
		//#end
		leaderboardTitleText = new FlxText(0, 200, 0, "LEADERBOARDS", 32);
		leaderboardTitleText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		add(leaderboardTitleText);
		leaderboardTitleText.cameras = [camHUD];

		leaderboardText = new FlxText(0, 200, 0, "", 32);
		leaderboardText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		add(leaderboardText);
		leaderboardText.cameras = [camHUD];

		diffText = new FlxText(0, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.alignment = LEFT;
		add(diffText);
		diffText.cameras = [camHUD];



		//speedText = new FlxText(0, diffText.y + 36, 0, "", 24);
		//speedText.font = scoreText.font;
		//speedText.alignment = LEFT;
		//add(speedText);

		//var portList = ['Alter_Ego', 'Rejected', 'Wiik_4'];


		for (i in 0...songs.length)
		{
			addSongToFreeplayList(songs[i]);
		}
		var portList = CoolUtil.coolTextFile(Paths.file('images/freeplay/ports/data.txt'));
		for (portName in portList)
		{
			if (utilities.Options.getData("charsAndBGs"))
			{
				var port = new FlxSprite().loadGraphic(Paths.image('freeplay/ports/'+portName));
				port.alpha = 0;
				add(port);
				ports.set(portName, port);
			}
	
		}

			
		unlockText = new FlxText(0,0,0, "");
		unlockText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(unlockText);

		add(gradient);

		songNameThing = new Alphabet(0, 0, "a", true, false, 1);
		songNameThing.y = 100;
		songNameThing.cameras = [camHUD];

		changeSelection();
		changeDiff();

		selector = new FlxText();

		selector.size = 40;
		selector.text = "<";

		if(!songsReady)
		{
			add(black);
		} else {
			remove(black);
			black.kill();
			black.destroy();

			songsReady = false;

			new FlxTimer().start(1, function(_){songsReady = true;});
		}

		if (songs.length > 0)
			selectedColor = songs[curSelected].color;
		bg.color = selectedColor;


		disconnectButton = new SimpleButton(FlxG.width*0.8, 100, function()
		{
			if (disconnectButton.visible)
				Multiplayer.endServer();
		});
		disconnectButton.loadGraphic(Paths.image("online/Disconnect"));
		add(disconnectButton);
		//disconnectButton.textNormal.setFormat(Paths.font("Contb___.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        //disconnectButton.textHighlight.setFormat(Paths.font("Contb___.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		disconnectButton.visible = false;
		
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press RESET to reset song score and rank | Press SPACE to play Song Audio";
		#else
		var leText:String = "Press RESET to reset song score";
		#end

		var text:FlxText = new FlxText(textBG.x - 1, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);



		var bottomTextBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomTextBG.alpha = 0.6;
		add(bottomTextBG);

		var bottomText:FlxText = new FlxText(bottomTextBG.x - 1, bottomTextBG.y + 4, FlxG.width, "Press ENTER to PLAY!", 18);
		bottomText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		bottomText.bold = true;
		bottomText.scrollFactor.set();
		add(bottomText);

		var topTextBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 26, 0xFF000000);
		topTextBG.alpha = 0.6;
		add(topTextBG);

		var topText:FlxText = new FlxText(topTextBG.x+1, topTextBG.y + 4, FlxG.width, "LEFT and RIGHT to change difficulty | Shift + LEFT and RIGHT to change song speed | TAB to open full leaderboard", 18);
		topText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		topText.bold = true;
		topText.scrollFactor.set();
		add(topText);

		diffBGThing = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/thing"));
		diffBGThing.screenCenter();
		diffBGThing.y = 200;
		add(diffBGThing);

		var songSpeedBG = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/thing"));
		songSpeedBG.screenCenter();
		songSpeedBG.y = 400;
		add(songSpeedBG);

		var songSpeedThing = new Alphabet(0,0, "Song Speed", true, false, 0.8);
		songSpeedThing.screenCenter();
		songSpeedThing.y = 335;
		add(songSpeedThing);

		diffBGThing.cameras = [camHUD];
		songSpeedBG.cameras = [camHUD];
		songSpeedThing.cameras = [camHUD];

		bottomTextBG.cameras = [camHUD];
		bottomText.cameras = [camHUD];
		topTextBG.cameras = [camHUD];
		topText.cameras = [camHUD];

		

		difficultyImage = new FlxSprite(0,0).loadGraphic(Paths.image("campaign menu/difficulties/Voiid/"+curDiffString));
		difficultyImage.y = diffBGThing.y+(diffBGThing.height*0.5)-(difficultyImage.height*0.5);
		difficultyImage.screenCenter(X);
		add(difficultyImage);

		leftDiffArr = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/white_arrow"));
		leftDiffArr.y = diffBGThing.y+(diffBGThing.height*0.5)-(leftDiffArr.height*0.5);
		add(leftDiffArr);

		rightDiffArr = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/white_arrow"));
		rightDiffArr.y = diffBGThing.y+(diffBGThing.height*0.5)-(rightDiffArr.height*0.5);
		rightDiffArr.flipX = true;
		add(rightDiffArr);

		leftDiffArr.cameras = [camHUD];
		rightDiffArr.cameras = [camHUD];
		difficultyImage.cameras = [camHUD];

		songSpeedText = new FlxText(0, 0, 0, ""+curSpeed);
		songSpeedText.font = scoreText.font;
		songSpeedText.alignment = CENTER;
		songSpeedText.size = 64;
		songSpeedText.y = songSpeedBG.y+(songSpeedBG.height*0.5)-(songSpeedText.height*0.5);
		songSpeedText.screenCenter(X);
		add(songSpeedText);

		leftSpeedArr = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/white_arrow"));
		leftSpeedArr.y = songSpeedBG.y+(songSpeedBG.height*0.5)-(leftSpeedArr.height*0.5);
		add(leftSpeedArr);

		rightSpeedArr = new FlxSprite(0,0).loadGraphic(Paths.image("freeplay/white_arrow"));
		rightSpeedArr.y = songSpeedBG.y+(songSpeedBG.height*0.5)-(rightSpeedArr.height*0.5);
		rightSpeedArr.flipX = true;
		add(rightSpeedArr);

		leftSpeedArr.cameras = [camHUD];
		rightSpeedArr.cameras = [camHUD];
		songSpeedText.cameras = [camHUD];

		updateArrows();

		add(songNameThing);
		

		super.create();
	}

	function updateDiffImage()
	{
		if (difficultyImage == null)
			return;
		if (diffImageMap.exists(curDiffString))
		{
			difficultyImage.loadGraphic(Paths.image("campaign menu/difficulties/Voiid/"+diffImageMap.get(curDiffString)));
			difficultyImage.y = diffBGThing.y+(diffBGThing.height*0.5)-(difficultyImage.height*0.5);
		}
	}

	function updateArrows()
	{
		if (difficultyImage == null)
			return;
		difficultyImage.screenCenter(X);
		leftDiffArr.x = difficultyImage.x-leftDiffArr.width;
		rightDiffArr.x = difficultyImage.x+difficultyImage.width;

		songSpeedText.screenCenter(X);
		leftSpeedArr.x = songSpeedText.x-leftSpeedArr.width-50;
		rightSpeedArr.x = songSpeedText.x+songSpeedText.width+50;
	}

	function updateLeaderboardText()
	{
		//#if mobile
		//return;
		//#end
		if (songs.length <= 0)
			return;
		//if (GameJoltStuff.ServerListSubstate.createdAClient)
		//{
			//leaderboardText.text = '\nLeaderboard disabled while connected to another player.\n';
			//updateLeaderboardTextPos();
			//return;
		//}
		leaderboardText.text = '\nFetching scores...\n';
		updateLeaderboardTextPos();
		//trace(songs[curSelected].songName.toLowerCase());
		//trace(curDiffString.toLowerCase());
		Leaderboards.getLeaderboard(songs[curSelected].songName.toLowerCase(), curDiffString.toLowerCase(), curSpeed, false, function(str:String)
		{
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
					var scoreList:SongLeaderboard;
					try
					{
						scoreList = Leaderboards.parseLeaderboardString(str); //unseralize from string to type
					}
					catch(e)
					{
						text += '\nError fetching scores.';
						leaderboardText.text = text+"\n";
						updateLeaderboardTextPos();
						return;
					}

					//trace(scoreList);
					
					var limit = scoreList.scores.length;
					if (limit > 3)
						limit = 3; //only show top 3 
					
					for (i in 0...limit)
					{
						var data = scoreList.scores[i];
						text += '\n'+(i+1)+'. ';
						text += ''+data.name;
						text += ' | Accuracy: '+data.acc+'%';
						text += ' | Score: '+data.score;
						text += ' | Misses: '+data.misses;
					}
					//leaderBoardText.text += '\n[Press ALT to view all scores]';
			}
			//leaderboardBG.setGraphicSize(Std.int(FlxG.width*0.5), Std.int(leaderBoardText.height) + 10);
			//leaderboardBG.updateHitbox();
			leaderboardText.text = text+"\n";
			updateLeaderboardTextPos();
		});
	}
	function updateLeaderboardTextPos()
	{

		var wid = leaderboardText.width;
		if (wid < leaderboardTitleText.width)
			wid = leaderboardTitleText.width;

		leaderboardBG.makeGraphic(Std.int(wid + 10), Std.int(leaderboardTitleText.height + leaderboardText.height + 6 - 30), FlxColor.BLACK);
		leaderboardBG.x = FlxG.width-leaderboardBG.width;
		leaderboardBG.y = FlxG.height-26-leaderboardBG.height;

		leaderboardTitleText.x = FlxG.width-leaderboardTitleText.width-5;
		leaderboardTitleText.y = leaderboardBG.y + 6;

		leaderboardText.x = FlxG.width-leaderboardText.width-5;
		leaderboardText.y = leaderboardBG.y + leaderboardTitleText.height;

		leaderboardBGTriangle.x = leaderboardBG.x-56;
		leaderboardBGTriangle.y = leaderboardBG.y;
		var verts = [56, 0, 0, leaderboardBG.height, 56, leaderboardBG.height];
		leaderboardBGTriangle.vertices = new DrawData(6, true, verts);
		leaderboardBGTriangle.cameras = [camHUD];
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addSongToFreeplayList(song:SongMetadata)
	{
		var i = grpSongs.members.length;
		var scaleShit = (9 / song.songName.length);
		if (song.songName.length <= 9)
			scaleShit = 1;
		var songText:Alphabet = new Alphabet(0, (70 * i) + 30, song.songName, true, false, scaleShit);
		songText.isMenuItem = true;
		songText.targetY = i;
		//songText.forceX = 90;
		grpSongs.add(songText);

		if(utilities.Options.getData("healthIcons"))
		{
			var icon:HealthIcon = new HealthIcon(song.songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;

		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var loadedMultiplayerSong:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		cameraBlur.update(elapsed);

		gradient.color = bg.color;
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		up.y = FlxMath.lerp(up.y, 0, elapsed*8);
		down.y = FlxMath.lerp(down.y, 0, elapsed*8);

		if (songs.length > 0)
		{
			for (portName => port in ports)
			{
				var alp = 0;
				if (songPortMap.exists(songs[curSelected].songName))
				{
					if (songPortMap.get(songs[curSelected].songName) == portName)
						alp = 1;
				}
				port.alpha = FlxMath.lerp(port.alpha, alp, elapsed*5);
			}

			unlockText.x = grpSongs.members[curSelected].x;
			unlockText.y = grpSongs.members[curSelected].y+75;
		}


		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		
		#if !mobile
		if (whiteShader.fade < 1.0)
			whiteShader.fade += elapsed*1.5;
		whiteShader.update(elapsed);
		#end

		var funnyObject:FlxText = scoreText;

		//if(speedText.width >= scoreText.width && speedText.width >= diffText.width)
			//funnyObject = speedText;

		if(diffText.width >= scoreText.width)
			funnyObject = diffText;

		scoreBG.x = funnyObject.x - 6;
		

		if(Std.int(scoreBG.width) != Std.int(funnyObject.width + 6))
			scoreBG.makeGraphic(Std.int(funnyObject.width + 6), 72, FlxColor.BLACK);

		scoreBGTriangle.x = scoreBG.x+scoreBG.width;
		scoreText.x = 6;
		scoreText.text = "PERSONAL BEST:" + lerpScore;

		diffText.x = 6;

		curSpeed = FlxMath.roundDecimal(curSpeed, 2);

		#if !sys
		curSpeed = 1;
		#end

		if(curSpeed < 0.25)
			curSpeed = 0.25;

		#if sys
		//speedText.text = "Speed: " + curSpeed + " (R+SHIFT)";
		#else
		//speedText.text = "";
		#end
		songSpeedText.text = curSpeed+"";
		updateArrows();

		//speedText.x = 6;

		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var shift = FlxG.keys.pressed.SHIFT;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;

		var disableControls = false; //disable entering and exiting when waiting in a server lol
		var preventBreakingShit = (Multiplayer.player1Client != null && Multiplayer.player2Client != null);
		if (preventBreakingShit)
			FlxG.autoPause = false;

		disconnectButton.visible = (Multiplayer.createdAClient);
		FlxG.mouse.visible = disconnectButton.visible;

		if (Multiplayer.createdAClient && Multiplayer.currentPlayer != 0 && songs.length > 0)
		{
			if (preventBreakingShit)
			{
				disableControls = true;

				if (Multiplayer.player1Client.song != '' && Multiplayer.player1Client.song != null)
				{
					if (!loadedMultiplayerSong)
					{
						loadedMultiplayerSong = true;
						persistentUpdate = false;

						var song:String = Multiplayer.player1Client.song;
						var diff:String = Multiplayer.player1Client.diff;
						curSpeed = Multiplayer.player1Client.songSpeed;

						var poop:String = Highscore.formatSong(song.toLowerCase(), diff);
	
						trace(poop);
		
						if(Assets.exists(Paths.json("song data/" + song.toLowerCase() + "/" + poop)))
						{
							PlayState.SONG = Song.loadFromJson(poop, song.toLowerCase());
							PlayState.isStoryMode = false;
							PlayState.storyDifficulty = curDifficulty;
							PlayState.songMultiplier = curSpeed;
							PlayState.storyDifficultyStr = diff.toUpperCase();
							PlayState.diffLoadedInWith = diff;

							PlayState.inMultiplayerSession = true;
				
							PlayState.storyWeek = songs[curSelected].week;
							trace('CUR WEEK' + PlayState.storyWeek);
		
							if(Assets.exists(Paths.inst(PlayState.SONG.song, PlayState.storyDifficultyStr)))
							{
								if(colorTween != null)
									colorTween.cancel();

								if(blurTween != null)
									blurTween.cancel();
		
								PlayState.chartingMode = false;
								LoadingState.loadAndSwitchState(new PlayState());
								Main.display.visible = true;

								camGame.fade(FlxColor.BLACK, 0.5);
								FlxTween.tween(camHUD, {alpha: 0.0}, 0.5, {ease:FlxEase.cubeOut});
		
								destroyFreeplayVocals();
							}
							else
							{
								if(Assets.exists(Paths.inst(song.toLowerCase(), curDiffString)))
									Application.current.window.alert(PlayState.SONG.song.toLowerCase() + " (JSON) != " + song.toLowerCase() + " (FREEPLAY)\nTry making them the same.",
								"Leather Engine's No Crash, We Help Fix Stuff Tool");
								else
									Application.current.window.alert("Something is wrong with your song names, I'm not sure what, but I'm sure you can figure it out.",
							"Leather Engine's No Crash, We Help Fix Stuff Tool");
							}
						}
						else
							Application.current.window.alert(song.toLowerCase() + " doesn't match with any song audio files!\nTry fixing it's name in freeplaySonglist.txt",
						"Leather Engine's No Crash, We Help Fix Stuff Tool");
					}
				}
			}
		}

		if(songsReady && !disableControls)
		{
			
			if (!selectedSong)
			{
				if(-1 * Math.floor(FlxG.mouse.wheel) != 0 && !shift)
					changeSelection(-1 * Math.floor(FlxG.mouse.wheel));
				else if(-1 * (Math.floor(FlxG.mouse.wheel) / 10) != 0 && shift)
				{
					curSpeed += -1 * (Math.floor(FlxG.mouse.wheel) / 10);
					//updateLeaderboardText();
	
					#if cpp
					@:privateAccess
					{
						if(FlxG.sound.music.active && FlxG.sound.music.playing)
							lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
			
						if (vocals.active && vocals.playing)
							lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
					}
					#end
				}
	
				if (upP)
					changeSelection(-1);
				if (downP)
					changeSelection(1);
			}

			//#if !mobile

			if (selectedSong)
			{

				#if mobile //mobile controls for diff/speed selection
				for (touch in FlxG.touches.list)
				{
					if (touch.justPressed)
					{
						if (MobileControls.checkTouchOverlap(touch, leftDiffArr.x, leftDiffArr.y, leftDiffArr.width, leftDiffArr.height, camHUD))
						{
							changeDiff(-1);
						}
						else if (MobileControls.checkTouchOverlap(touch, rightDiffArr.x, rightDiffArr.y, rightDiffArr.width, rightDiffArr.height, camHUD))
						{
							changeDiff(1);
						}
						else if (MobileControls.checkTouchOverlap(touch, leftSpeedArr.x, leftSpeedArr.y, leftSpeedArr.width, leftSpeedArr.height, camHUD))
						{
							curSpeed -= 0.05;
							updateArrows();
							updateLeaderboardText();
			
							#if cpp
							@:privateAccess
							{
								if(FlxG.sound.music.active && FlxG.sound.music.playing)
									lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
					
								if (vocals.active && vocals.playing)
									lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
							}
							#end
						}
						else if (MobileControls.checkTouchOverlap(touch, rightSpeedArr.x, rightSpeedArr.y, rightSpeedArr.width, rightSpeedArr.height, camHUD))
						{
							curSpeed += 0.05;
							updateArrows();
							updateLeaderboardText();
			
							#if cpp
							@:privateAccess
							{
								if(FlxG.sound.music.active && FlxG.sound.music.playing)
									lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
					
								if (vocals.active && vocals.playing)
									lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
							}
							#end
						}
					}

				}
				#end


				if (leftP && !shift)
					changeDiff(-1);
				else if (leftP && shift)
				{
					curSpeed -= 0.05;
					updateArrows();
					updateLeaderboardText();
	
					#if cpp
					@:privateAccess
					{
						if(FlxG.sound.music.active && FlxG.sound.music.playing)
							lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
			
						if (vocals.active && vocals.playing)
							lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
					}
					#end
				}
	
				if (rightP && !shift)
					changeDiff(1);
				else if (rightP && shift)
				{
					curSpeed += 0.05;
					updateArrows();
					updateLeaderboardText();
	
					#if cpp
					@:privateAccess
					{
						if(FlxG.sound.music.active && FlxG.sound.music.playing)
							lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
			
						if (vocals.active && vocals.playing)
							lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
					}
					#end
				}
				if(FlxG.keys.justPressed.R  && shift)
				{
					curSpeed = 1;
					updateLeaderboardText();
	
					#if cpp
					@:privateAccess
					{
						if(FlxG.sound.music.active && FlxG.sound.music.playing)
							lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
			
						if (vocals.active && vocals.playing)
							lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
					}
					#end
				}
			}
			//#end

			//#if !mobile
			leaderboardBGTriangle.alpha = camHUD.alpha*0.6;
			scoreBGTriangle.alpha = camHUD.alpha*0.6;
			//#end
	
			


	
			if (controls.BACK)
			{
				if (selectedSong)
				{
					selectedSong = false;

					if(blurTween != null)
						blurTween.cancel();
					if (hudTween != null)
						hudTween.cancel();
					blurTween = FlxTween.tween(cameraBlur, {strength: 0.0}, 0.5, {ease:FlxEase.cubeOut});
					hudTween = FlxTween.tween(camHUD, {alpha: 0.0}, 0.5, {ease:FlxEase.cubeOut});
					//#end
				}
				else 
				{
					if(colorTween != null)
						colorTween.cancel();

					if(blurTween != null)
						blurTween.cancel();

					if (hudTween != null)
						hudTween.cancel();
	
					#if cpp
					@:privateAccess
					{
						if(FlxG.sound.music.active && FlxG.sound.music.playing)
							lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, 1);
			
						if (vocals.active && vocals.playing)
							vocals.stop();
					}
					#end
	
					FlxG.switchState(new VoiidMainMenuState());
					Main.display.visible = true;
				}

			}

			#if PRELOAD_ALL
			if (FlxG.keys.justPressed.SPACE && songs.length > 0)
			{
				destroyFreeplayVocals();

				if(Assets.exists(Paths.voices(songs[curSelected].songName.toLowerCase(), curDiffString)))
					vocals = new FlxSound().loadEmbedded(Paths.voices(songs[curSelected].songName.toLowerCase(), curDiffString));
				else
					vocals = new FlxSound();

				FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName.toLowerCase(), curDiffString), 0.7);

				FlxG.sound.list.add(vocals);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
			}

			if(vocals != null && FlxG.sound.music != null && !FlxG.keys.justPressed.ENTER)
			{
				if(vocals.active && FlxG.sound.music.active)
				{
					if(vocals.time >= FlxG.sound.music.endTime)
						vocals.pause();
				}
	
				if(vocals.active && FlxG.sound.music.active)
				{
					if(vocals.time > FlxG.sound.music.time + 20)
					{
						vocals.pause();
						vocals.time = FlxG.sound.music.time;
						vocals.play();
					}
				}
			}
			

			#if (cpp)
			@:privateAccess
			{
				if(FlxG.sound.music.active && FlxG.sound.music.playing && !FlxG.keys.justPressed.ENTER)
					lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
	
				if(vocals.active && vocals.playing && !FlxG.keys.justPressed.ENTER)
					lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
			}
			#end
			#end

			if(controls.RESET && !shift && songs.length > 0)
			{
				openSubState(new ResetScoreSubstate(songs[curSelected].songName, curDiffString));
				changeSelection();
			}

			if (selectedSong && FlxG.keys.justPressed.TAB && !preventBreakingShit && GameJolt.connected && songs.length > 0)
			{
				var subState = new LeaderboardSubstate(songs[curSelected].songName, curDiffString, curSpeed);
				subState.cameras = [camHUD];
				openSubState(subState);
			}

			if(getEnterPress() && canEnterSong && (!songs[curSelected].locked || (VoiidMainMenuState.devBuild #if !mobile && FlxG.keys.pressed.SHIFT #end)) && songs.length > 0)
			{
				//#if mobile 
				//selectedSong = true;
				//#end
				if (selectedSong)
				{
					#if mobile
					var didPressSong:Bool = false;
					for (touch in FlxG.touches.list)
					{
						if (MobileControls.checkTouchOverlap(touch, songNameThing.x, songNameThing.y, songNameThing.width, songNameThing.height, camHUD))
						{
							didPressSong = true;
						}
					}
					if (!didPressSong)
						return;
					
					#end
					var diff:String = curDiffString;
					var song:String = songs[curSelected].songName.toLowerCase();
					var poop:String = Highscore.formatSong(song, diff);
					#if mobile 
					//on mobile the song names need to be exact, most stuff is already correctly formatted and not lowercase
					song = songs[curSelected].songName;
					diff = curDiffArray[curDifficulty];
					poop = song;
					if(diff.toLowerCase() != "normal")
						poop += "-" + diff;
					#end					
	
					trace(poop);
	
					if(Assets.exists(Paths.json("song data/" + song + "/" + poop)))
					{
						PlayState.SONG = Song.loadFromJson(poop, song);
						PlayState.isStoryMode = false;
						PlayState.storyDifficulty = curDifficulty;
						PlayState.songMultiplier = curSpeed;
						PlayState.storyDifficultyStr = curDiffString.toUpperCase();
						PlayState.diffLoadedInWith = curDiffArray[curDifficulty];

						PlayState.inMultiplayerSession = preventBreakingShit;
			
						PlayState.storyWeek = songs[curSelected].week;
						trace('CUR WEEK' + PlayState.storyWeek);
	
						if(Assets.exists(Paths.inst(PlayState.SONG.song, #if mobile diff #else PlayState.storyDifficultyStr #end)))
						{
							
							if(colorTween != null)
								colorTween.cancel();

							//#if !mobile
							if(blurTween != null)
								blurTween.cancel();
							//#end

							if (preventBreakingShit)
							{
								Multiplayer.clients[Multiplayer.currentPlayer].song = songs[curSelected].songName;
								Multiplayer.clients[Multiplayer.currentPlayer].diff = curDiffString;
								Multiplayer.clients[Multiplayer.currentPlayer].songSpeed = curSpeed;
								Multiplayer.updateServer();
							}
	
							PlayState.chartingMode = false;
							LoadingState.loadAndSwitchState(new PlayState());
							Main.display.visible = true;

							camGame.fade(FlxColor.BLACK, 0.5);
							FlxTween.tween(camHUD, {alpha: 0.0}, 0.5, {ease:FlxEase.cubeOut});
	
							destroyFreeplayVocals();
						}
						else
						{
							if(Assets.exists(Paths.inst(songs[curSelected].songName.toLowerCase(), curDiffString)))
								Application.current.window.alert(PlayState.SONG.song.toLowerCase() + " (JSON) != " + songs[curSelected].songName.toLowerCase() + " (FREEPLAY)\nTry making them the same.",
							"Leather Engine's No Crash, We Help Fix Stuff Tool");
							else
								Application.current.window.alert("Something is wrong with your song names, I'm not sure what, but I'm sure you can figure it out.",
						"Leather Engine's No Crash, We Help Fix Stuff Tool");
						}
					}
					else
						Application.current.window.alert(songs[curSelected].songName.toLowerCase() + " doesn't match with any song audio files!\nTry fixing it's name in freeplaySonglist.txt",
					"Leather Engine's No Crash, We Help Fix Stuff Tool");
				}
				else
				{
					
					selectedSong = true;
					//#if mobile
					//camHUD.alpha = 1.0;
					//#else 
					updateLeaderboardText();
					if(blurTween != null)
						blurTween.cancel();
					if(hudTween != null)
						hudTween.cancel();
					blurTween = FlxTween.tween(cameraBlur, {strength: 15}, 0.5, {ease:FlxEase.cubeOut});
					hudTween = FlxTween.tween(camHUD, {alpha: 1.0}, 0.5, {ease:FlxEase.cubeOut});
					//#end

				}


				
			}
			/*if (!selectedSong && FlxG.keys.justPressed.TAB && GameJoltStuff.loggedIn && GameJoltStuff.connectedToGame)
				{
					var subState = new ServerListSubstate();
					//subState.cameras = [camHUD];
					openSubState(subState);
				}*/

			if (!selectedSong)
			{
				#if mobile
				var vPress:Int = MobileControls.verticalPressAlphabet(grpSongs, curSelected);
				switch(vPress)
				{
					case -1: 
						changeSelection(-1);
					case 1: 
						changeSelection(1);
				}
				#end
			}
		}
	}

	override function closeSubState()
	{
		changeSelection();
		
		FlxG.mouse.visible = false;

		super.closeSubState();
	}
	
	function changeDiff(change:Int = 0)
	{
		if (songs.length <= 0)
			return;
		curDifficulty += change;
		

		if (curDifficulty < 0)
			curDifficulty = curDiffArray.length - 1;

		if (curDifficulty > curDiffArray.length - 1)
			curDifficulty = 0;

			

		curDiffString = curDiffArray[curDifficulty].toUpperCase();

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDiffString);
		curRank = Highscore.getSongRank(songs[curSelected].songName, curDiffString);
		#end

		diffText.text = "< " + curDiffString + " - " + curRank + " >";

		if (iconArray.length > 0)
		{
			if (songs[curSelected].songName.toLowerCase().contains("final destination"))
			{
				//trace('fd');
				if (curDiffString.contains("GOD"))
				{
					if (iconArray[curSelected].name != "VoiidGodShagXMatt")
					{
						var newIcon = new HealthIcon("VoiidGodShagXMatt", false);
						newIcon.sprTracker = iconArray[curSelected].sprTracker;
						remove(iconArray[curSelected]);
						iconArray[curSelected].kill();
						iconArray[curSelected] = newIcon;
						#if !mobile
						newIcon.shader = whiteShader.shader;
						#end
						add(newIcon);
						#if !mobile
						whiteShader.fade = 0.0;
						#end
						newIcon.update(0);
						FlxG.sound.play(Paths.sound('ssj_burst'), 0.6);
						updateColor();
					}
				}
				else 
				{
					if (iconArray[curSelected].name != "VoiidShagXMatt")
					{
						var newIcon = new HealthIcon("VoiidShagXMatt", false);
						newIcon.sprTracker = iconArray[curSelected].sprTracker;
						remove(iconArray[curSelected]);
						iconArray[curSelected].kill();
						iconArray[curSelected] = newIcon;
						add(newIcon);
						#if !mobile
						newIcon.shader = whiteShader.shader;
						#end
						newIcon.update(0);
						#if !mobile
						whiteShader.fade = 0.0;
						#end
						updateColor();
					}
				}
			}
			#if !mobile
			if (songIcon == null || iconArray[curSelected].name != songIcon.name)
			{
				if (songIcon != null)
				{
					remove(songIcon);
					songIcon.kill();
				}

				songIcon = new HealthIcon(iconArray[curSelected].name);
				
				songIcon.sprTracker = songNameThing;
				songIcon.shader = whiteShader.shader;
				songIcon.update(0);
				songIcon.cameras = [camHUD];
				songIcon.xOffset = -20 + (songIcon.width/2);
				songIcon.yOffset = -30;
				songIcon.direction = RIGHT;
				add(songIcon);
			}
			#end

		}
		updateDiffImage();
		updateArrows();

		//#if !mobile
		if (selectedSong)
			updateLeaderboardText();
		//#end

		var unlockT:String = "";
		if (songs[curSelected].locked)
		{
			var songLower = songs[curSelected].songName.toLowerCase();
			if (songUnlockRequirements.exists(songLower))
				unlockT = "Unlocked after beating "+songUnlockRequirements.get(songLower);
		}
		unlockText.text = unlockT;

	}
	var timesScrolledToBottom = 0;
	function changeSelection(change:Int = 0)
	{
		if (songs.length <= 0)
			return;
		if (iconArray.length > 0)
		{
			iconArray[curSelected].shader = null;
		}

		curSelected += change;

		if (curSelected < 0)
		{
			curSelected = songs.length - 1;
			timesScrolledToBottom--; //cant cheat
		}
		if (curSelected >= songs.length)
		{
			curSelected = 0;
			timesScrolledToBottom++;
			if (timesScrolledToBottom >= 4)
			{
				var songMeta = new SongMetadata("Average Voiid Song", 0, "Wiik1VoiidMatt", ["Voiid"], FlxColor.fromString('#282828'));
				songs.push(songMeta);
				addSongToFreeplayList(songMeta);
			}
		}
			

		if (change != 0)
		{
			if (change > 0)
				down.y += 20; //funni bopping thing
			else 
				up.y -= 20;
		}

		// Sounds

		// Scroll Sound
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		// Song Inst
		if(utilities.Options.getData("freeplayMusic"))
		{
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName, curDiffString.toLowerCase()), 0.7);

			if(vocals.active && vocals.playing)
				vocals.stop();

			#if cpp
			@:privateAccess
			{
				if(FlxG.sound.music.active && FlxG.sound.music.playing)
					lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
	
				if (vocals.active && vocals.playing)
					lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
			}
			#end
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDiffString);
		curRank = Highscore.getSongRank(songs[curSelected].songName, curDiffString);
		#end

		curDiffArray = songs[curSelected].difficulties;

		songNameThing.setText(songs[curSelected].songName);
		songNameThing.screenCenter(X);
		if (iconArray.length > 0)
			songNameThing.x -= 150;

		changeDiff();

		var bullShit:Int = 0;

		if(iconArray.length > 0)
		{
			for (i in 0...iconArray.length)
			{
				iconArray[i].alpha = 0.6;

				if(iconArray[i].animation.curAnim != null && !iconArray[i].animatedIcon)
					iconArray[i].animation.curAnim.curFrame = 0;
			}
	
			iconArray[curSelected].alpha = 1;

			if(iconArray[curSelected].animation.curAnim != null && !iconArray[curSelected].animatedIcon)
			{
				iconArray[curSelected].animation.curAnim.curFrame = 2;

				if(iconArray[curSelected].animation.curAnim.curFrame != 2)
					iconArray[curSelected].animation.curAnim.curFrame = 0;
			}
		}

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
			if (songs[grpSongs.members.indexOf(item)].locked)
			{
				item.alpha = 0.3;
			}
		}

		updateArrows();
		if(change != 0)
		{
			updateColor();
		}
		else
			bg.color = songs[curSelected].color;
	}

	function updateColor()
	{
		if (songs.length <= 0)
			return;
		var newColor:FlxColor = songs[curSelected].color;
		if (iconArray.length > 0)
		{
			if (iconArray[curSelected].name == "VoiidGodShagXMatt")
			{
				newColor = FlxColor.fromRGB(30, 30, 30);
			}
		}

		if(newColor != selectedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}

			selectedColor = newColor;

			colorTween = FlxTween.color(bg, 0.25, bg.color, selectedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}
	}

	
	public function destroyFreeplayVocals()
	{
		if(vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}

		vocals = null;
		
		if(FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			FlxG.sound.music.destroy();
		}

		FlxG.sound.music = null;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var difficulties:Array<String> = ["easy", "normal", "hard"];
	public var color:FlxColor = FlxColor.GREEN;
	public var locked:Bool = false;

	public function new(song:String, week:Int, songCharacter:String, ?difficulties:Array<String>, ?color:FlxColor, ?locked:Bool = false)
	{
		this.locked = locked;
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;

		if(difficulties != null)
			this.difficulties = difficulties;

		if(color != null)
			this.color = color;
		else
		{
			if(FreeplayState.coolColors.length - 1 >= this.week)
				this.color = FreeplayState.coolColors[this.week];
			else
				this.color = FreeplayState.coolColors[0];
		}
	}
}
