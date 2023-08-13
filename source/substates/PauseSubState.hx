package substates;

import Popup.MessagePopup;
import game.Note;
import states.VoiidMainMenuState;
import ui.Option;
import ui.Checkbox;
import game.Conductor;
import game.Replay;
import states.ReplaySelectorState;
import states.FreeplayState;
import states.StoryMenuState;
import states.PlayState;
import ui.Alphabet;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Option>;

	var curSelected:Int = 0;

	var menus:Map<String, Array<Option>> = [
		"default" => [
			new Option('Resume', "", 0), 
			new Option('Restart Song', "", 1), 
			new Option('Options', "", 2), 
			new Option('Edit Keybinds', "", 3), 
			new Option('Exit To Menu', "", 4)],
		"options" => [new Option('Back', "", 0), 
			new BoolOption("Bot", "botplay", 1), 
			new BoolOption("Mechanics", "mechanics", 1), 
			new BoolOption("Modcharts", "modcharts", 1), 
			//new BoolOption("Quick Restart", "quickRestart", 1), 
			new BoolOption("No Miss", "noHit", 1), 
			new BoolOption("Ghost Tapping", "ghostTapping", 1), 
			new BoolOption("No Death", "noDeath", 1), 
			new BoolOption("Opponent Play", "opponentPlay", 1), 
		],
		"restart" => [new Option('Back', "", 0), new Option('No Cutscenes', "", 1), new Option('With Cutscenes', "", 2)],
		"fdGodPractice" => [new Option('Back', "", 0), 
			new Option('Skip to First Duet', "", 1),
			new Option('Skip to Second Duet', "", 2),
			new Option('Skip to Third Duet', "", 3),
		],
	];

	var menu:String = "default";

	var pauseMusic:FlxSound;

	var scoreWarning:FlxText;
	var warningAmountLols:Int = 0;

	var showedRestartPopup:Bool = false;

	public function new(x:Float, y:Float)
	{
		/*var optionsArray = menus.get("options");

		switch(utilities.Options.getData("playAs"))
		{
			case "bf":
				optionsArray.push("Play As BF");
				menus.set("options", optionsArray);
			case "opponent":
				optionsArray.push("Play As Opponent");
				menus.set("options", optionsArray);
			case "both":
				optionsArray.push("Play As Both");
				menus.set("options", optionsArray);
			default:
				optionsArray.push("Play As BF");
				menus.set("options", optionsArray);
		}*/

		super();

		if (PlayState.instance.playingFDGOD)
		{
			menus.set("default", [new Option('Resume', "", 0), new Option('Restart Song', "", 1), new Option('Options', "", 2), new Option('FD God Practice Options', "", 3), new Option('Exit To Menu', "", 4)]);
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += PlayState.storyDifficultyStr.toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, RIGHT);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		scoreWarning = new FlxText(20, 15 + 64, 0, "Remember, changing options invalidates your score!", 32);
		scoreWarning.scrollFactor.set();
		scoreWarning.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreWarning.updateHitbox();
		scoreWarning.screenCenter(X);
		add(scoreWarning);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		scoreWarning.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(scoreWarning, {alpha: 1, y: scoreWarning.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		FlxTween.tween(scoreWarning, {alpha: 0, y: scoreWarning.y - 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 4});

		grpMenuShit = new FlxTypedGroup<Option>();
		add(grpMenuShit);

		updateAlphabets();

		cameras = [PlayState.instance.camTransition];
		if (PlayState.instance.usedLuaCameras)
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
	}

	var justPressedAcceptLol:Bool = true;

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		#if mobile
		var vPress:Int = MobileControls.verticalPressOptions(grpMenuShit, curSelected, PlayState.instance.camHUD);
		//if (vPress == 0) //im so confused
			//accepted = true;
		#end





		switch(warningAmountLols)
		{
			case 50:
				scoreWarning.text = "What are you doing?";
			case 69:
				scoreWarning.text = "Haha funny number.";
			case 100:
				scoreWarning.text = "abcdefghjklmnopqrstuvwxyz";
			case 420:
				scoreWarning.text = "br";
			case 1000:
				scoreWarning.text = "collect your cookie you've earned it\n for getting carpal tunnel!!!!!!!\n";
			default:
				scoreWarning.text = "Remember, changing options invalidates your score!";
		}

		if (-1 * Math.floor(FlxG.mouse.wheel) != 0)
			changeSelection(-1 * Math.floor(FlxG.mouse.wheel));
		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		
		#if mobile
		if(!accepted)
		{
			switch(vPress)
			{
				case -1:
					changeSelection(-1);
				case 1: 
					changeSelection(1);
				case 0: 
					accepted = true;
			}
		}
		#end

		if(!accepted)
			justPressedAcceptLol = false;

		if(accepted && !justPressedAcceptLol)
		{
			justPressedAcceptLol = true;

			var daSelected:String = menus.get(menu)[curSelected].Option_Name;

			switch(daSelected.toLowerCase())
			{
				case "resume":
					pauseMusic.volume = 0;
					pauseMusic.stop();
					close();
					
				case "restart song":
					menu = "restart";
					updateAlphabets();
				case "no cutscenes":
					PlayState.SONG.speed = PlayState.previousScrollSpeedLmao;
					PlayState.fromPauseMenu = true;

					#if linc_luajit
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end

					PlayState.SONG.keyCount = PlayState.instance.ogKeyCount;
					PlayState.SONG.playerKeyCount = PlayState.instance.ogPlayerKeyCount;

					FlxG.resetState();
				case "with cutscenes":
					PlayState.SONG.speed = PlayState.previousScrollSpeedLmao;

					#if linc_luajit
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end

					PlayState.SONG.keyCount = PlayState.instance.ogKeyCount;
					PlayState.SONG.playerKeyCount = PlayState.instance.ogPlayerKeyCount;

					FlxG.resetState();
				case "bot":
					//utilities.Options.setData(!utilities.Options.getData("botplay"), "botplay");

					@:privateAccess
					{
						PlayState.instance.updateSongInfoText();
						PlayState.instance.hasUsedBot = true;
					}

					FlxTween.tween(scoreWarning, {alpha: 1, y: scoreWarning.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
					FlxTween.tween(scoreWarning, {alpha: 0, y: scoreWarning.y - 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 4});

					warningAmountLols += 1;
				case 'mechanics': 
					//utilities.Options.setData(!utilities.Options.getData("mechanics"), "mechanics");
					FlxTween.tween(scoreWarning, {alpha: 1, y: scoreWarning.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
					FlxTween.tween(scoreWarning, {alpha: 0, y: scoreWarning.y - 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 4});
					warningAmountLols += 1;
					//updateAlphabets();
					if (!showedRestartPopup)
					{
						Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "Song restart required for changes to take affect."));
						showedRestartPopup = true;
					}
				case 'modcharts': 
					//utilities.Options.setData(!utilities.Options.getData("modcharts"), "modcharts");
					FlxTween.tween(scoreWarning, {alpha: 1, y: scoreWarning.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
					FlxTween.tween(scoreWarning, {alpha: 0, y: scoreWarning.y - 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 4});
					warningAmountLols += 1;
					//updateAlphabets();
					if (!showedRestartPopup)
					{
						Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "Song restart required for changes to take affect."));
						showedRestartPopup = true;
					}
				case "opponent play": 
					if (!showedRestartPopup)
					{
						Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "Song restart required for changes to take affect."));
						showedRestartPopup = true;
					}
				case "quick restart":
					//utilities.Options.setData(!utilities.Options.getData("quickRestart"), "quickRestart");

					FlxTween.tween(scoreWarning, {alpha: 1, y: scoreWarning.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
					FlxTween.tween(scoreWarning, {alpha: 0, y: scoreWarning.y - 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 4});

					warningAmountLols += 1;
				case "no miss":
					//utilities.Options.setData(!utilities.Options.getData("noHit"), "noHit");

					FlxTween.tween(scoreWarning, {alpha: 1, y: scoreWarning.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
					FlxTween.tween(scoreWarning, {alpha: 0, y: scoreWarning.y - 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 4});

					warningAmountLols += 1;
				case "ghost tapping":
					//utilities.Options.setData(!utilities.Options.getData("ghostTapping"), "ghostTapping");

					@:privateAccess
					if(utilities.Options.getData("ghostTapping")) // basically making it easier lmao
						PlayState.instance.hasUsedBot = true;

					FlxTween.tween(scoreWarning, {alpha: 1, y: scoreWarning.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
					FlxTween.tween(scoreWarning, {alpha: 0, y: scoreWarning.y - 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 4});

					warningAmountLols += 1;
				case "options":
					menu = "options";
					updateAlphabets();
				case "edit keybinds":
					var substate = new ControlMenuSubstate(); 
					substate.cameras = [PlayState.instance.camHUD];
					openSubState(substate);
				case "fd god practice options":
					menu = "fdGodPractice";
					updateAlphabets();
				case "skip to first duet": 
					//song pos = 52820
					if (PlayState.SONG.song.toLowerCase() == 'final destination old')
						setSongPos(57620);
					else 
						setSongPos(52820);
					
				case "skip to second duet": 
					//song pos = 139220
					if (PlayState.SONG.song.toLowerCase() == 'final destination old')
						setSongPos(131220);
					else 
						setSongPos(139220);
				case "skip to third duet": 
					//song pos = 251220
					if (PlayState.SONG.song.toLowerCase() == 'final destination old')
						setSongPos(144020);
					else 
						setSongPos(251220);
				case "back":
					menu = "default";
					updateAlphabets();
				case "exit to menu":
					#if linc_luajit
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end

					if(PlayState.playingReplay && Replay.getReplayList().length > 0)
					{
						Conductor.offset = utilities.Options.getData("songOffset");

						@:privateAccess
						{
							utilities.Options.setData(PlayState.instance.ogJudgementTimings, "judgementTimings");
							utilities.Options.setData(PlayState.instance.ogGhostTapping, "ghostTapping");
						}

						FlxG.switchState(new ReplaySelectorState());
					}
					else
					{
						if (PlayState.isStoryMode)
							FlxG.switchState(new VoiidMainMenuState());
						else
							FlxG.switchState(new FreeplayState());
					}

					PlayState.playingReplay = false;
				case "no death":
					//utilities.Options.setData(!utilities.Options.getData("noDeath"), "noDeath");

					@:privateAccess
					if(utilities.Options.getData("noDeath"))
						PlayState.instance.hasUsedBot = true;

					FlxTween.tween(scoreWarning, {alpha: 1, y: scoreWarning.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
					FlxTween.tween(scoreWarning, {alpha: 0, y: scoreWarning.y - 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 4});

					warningAmountLols += 1;
				case "play as bf":
					utilities.Options.setData("opponent", "playAs");

					/*var optionsArray = menus.get("options");

					optionsArray.remove(daSelected);

					switch(utilities.Options.getData("playAs"))
					{
						case "bf":
							optionsArray.push("Play As BF");
							menus.set("options", optionsArray);
						case "opponent":
							optionsArray.push("Play As Opponent");
							menus.set("options", optionsArray);
						case "both":
							optionsArray.push("Play As Both");
							menus.set("options", optionsArray);
						default:
							optionsArray.push("Play As BF");
							menus.set("options", optionsArray);
					}*/

					updateAlphabets();

					@:privateAccess
					PlayState.instance.hasUsedBot = true;

					FlxTween.tween(scoreWarning, {alpha: 1, y: scoreWarning.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
					FlxTween.tween(scoreWarning, {alpha: 0, y: scoreWarning.y - 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 4});

					warningAmountLols += 1;
				case "play as opponent":
					utilities.Options.setData("bf", "playAs");

					/*var optionsArray = menus.get("options");

					optionsArray.remove(daSelected);

					switch(utilities.Options.getData("playAs"))
					{
						case "bf":
							optionsArray.push("Play As BF");
							menus.set("options", optionsArray);
						case "opponent":
							optionsArray.push("Play As Opponent");
							menus.set("options", optionsArray);
						case "both":
							optionsArray.push("Play As Both");
							menus.set("options", optionsArray);
						default:
							optionsArray.push("Play As BF");
							menus.set("options", optionsArray);
					}*/

					updateAlphabets();

					@:privateAccess
					PlayState.instance.hasUsedBot = true;

					FlxTween.tween(scoreWarning, {alpha: 1, y: scoreWarning.y + 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
					FlxTween.tween(scoreWarning, {alpha: 0, y: scoreWarning.y - 10}, 0.4, {ease: FlxEase.quartInOut, startDelay: 4});

					warningAmountLols += 1;
			}
		}
	}

	function setSongPos(position:Float)
	{
		@:privateAccess
		PlayState.instance.isCheating = true;

		Conductor.songPosition = position;
		var i:Int = PlayState.instance.unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = PlayState.instance.unspawnNotes[i];
			if(daNote.strumTime-500 < position)
			{
				daNote.active = false;
				daNote.visible = false;
				//daNote.ignoreNote = true;

				daNote.kill();
				PlayState.instance.unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = PlayState.instance.notes.length - 1;
		while (i >= 0) {
			var daNote:Note = PlayState.instance.notes.members[i];
			if(daNote.strumTime-500 < position)
			{
				daNote.active = false;
				daNote.visible = false;
				//daNote.ignoreNote = true;

				daNote.kill();
				PlayState.instance.notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}

		pauseMusic.volume = 0;
		pauseMusic.stop();
		close();
		FlxG.sound.music.time = position;
		Conductor.songPosition = position;
		PlayState.instance.health = 2;
		@:privateAccess
		PlayState.instance.vocals.time = Conductor.songPosition;
		@:privateAccess
		PlayState.instance.ignoreFrameSkipFixer = true;
	}
	override public function close()
	{
		PlayState.instance.refreshBinds();
		super.close();
	}

	function updateAlphabets()
	{
		grpMenuShit.clear();

		for (i in 0...menus.get(menu).length)
		{
			grpMenuShit.add(menus.get(menu)[i]);
		}

		curSelected = 0;
		changeSelection();
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		
		curSelected += change;

		if (curSelected < 0)
			curSelected = menus.get(menu).length - 1;
		if (curSelected >= menus.get(menu).length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.Alphabet_Text.targetY = bullShit - curSelected;
			bullShit++;
			for(i in item.members)
			{
				i.alpha = 0.6;
			}

			if (item.Alphabet_Text.targetY == 0)
			{
				for(i in item.members)
				{
					i.alpha = 1;
				}
			}
		}
	}
}
