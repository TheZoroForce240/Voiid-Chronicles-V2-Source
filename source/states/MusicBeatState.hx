package states;

import online.Multiplayer;
import online.GameJolt;
import flixel.input.gamepad.FlxGamepad;
import utilities.Options;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.Transition;
import flixel.graphics.FlxGraphic;
import lime.utils.Assets;
import lime.utils.AssetCache;
import flixel.input.FlxInput.FlxInputState;
import flixel.FlxSprite;
import flixel.FlxBasic;
import openfl.Lib;
import lime.app.Application;
import game.Conductor;
import utilities.PlayerSettings;
import game.Conductor.BPMChangeEvent;
import utilities.Controls;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import openfl.utils.Assets as OpenFlAssets;

class MusicBeatState extends FlxUIState
{
	public var lastBeat:Float = 0;
	public var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	private var controls(get, never):Controls;

	public static var windowNameSuffix:String = "";
	public static var windowNamePrefix:String = "Leather Engine";

	public static var fullscreenBind:String = "F11";

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public static var usingController:Bool = false;

	override public function new()
	{	
		super();
	}

	override public function create() 
	{
		super.create();
		FlxG.autoPause = Options.getData("autoPause");
		updateGameJolt();
	}
	function updateGameJolt()
	{
		if (GameJolt.connected)
		{
			GameJolt.resetPingTimer(); //pings dont seem to transfer when changing state
			Multiplayer.resetServerPingTimer();
		}	
	}
	override public function onFocus():Void
	{
		updateGameJolt();
		super.onFocus();
	}

	var ignoreFrameSkipFixer = false; //to disable when skipping through a song

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (curStep - oldStep > 1 && curStep > 0 && !ignoreFrameSkipFixer)
		{
			trace('missed frame');
			var nextStep:Int = curStep;
			while(nextStep - oldStep > 1)
			{
				oldStep++;
				curStep = oldStep;
				stepHit(); //do step hits for any missed frames?????
				//trace('finished step hit: '+curStep);
			}
			curStep = nextStep;
		}
		ignoreFrameSkipFixer = false;

		if (oldStep != curStep && curStep > 0)
		{
			stepHit();
		}
			

		super.update(elapsed);

		if(FlxG.stage != null)
			FlxG.stage.frameRate = utilities.Options.getData("maxFPS");

		if(!utilities.Options.getData("antialiasing"))
		{
			forEachAlive(function(basic:FlxBasic) {
				if(Std.isOfType(basic, FlxSprite))
					Reflect.setProperty(basic, "antialiasing", false);
			}, true);
		}

		if(FlxG.keys.checkStatus(FlxKey.fromString(utilities.Options.getData("fullscreenBind", "binds")), FlxInputState.JUST_PRESSED))
			FlxG.fullscreen = !FlxG.fullscreen;

		Application.current.window.title = windowNamePrefix + windowNameSuffix;		

		if (FlxG.mouse.justPressed || FlxG.mouse.justMoved || FlxG.keys.justPressed.ANY #if mobile || MobileControls.justPressedAny() #end)
		{
			usingController = false;
		}
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			if (gamepad.anyInput())
				usingController = true;
		}
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / Conductor.timeScale[1]);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		
		for(i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		var dumb:TimeScaleChangeEvent = {
			stepTime: 0,
			songTime: 0,
			timeScale: [4,4]
		};

		var lastTimeChange:TimeScaleChangeEvent = dumb;

		for(i in 0...Conductor.timeScaleChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.timeScaleChangeMap[i].songTime)
				lastTimeChange = Conductor.timeScaleChangeMap[i];
		}

		if(lastTimeChange != dumb)
			Conductor.timeScale = lastTimeChange.timeScale;

		var multi:Float = 1;

		if(FlxG.state == PlayState.instance)
			multi = PlayState.songMultiplier;

		Conductor.recalculateStuff(multi);

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);

		updateBeat();
	}

	public function stepHit():Void
	{
		if (curStep % Conductor.timeScale[0] == 0)
			beatHit();
	}

	public function beatHit():Void { /* do literally nothing dumbass */ }
}
