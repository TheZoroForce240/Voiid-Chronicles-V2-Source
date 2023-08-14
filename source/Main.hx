package;

import haxe.CallStack;
import haxe.CallStack.StackItem;
import openfl.events.UncaughtErrorEvent;
import utilities.Options;
import openfl.system.Capabilities;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import openfl.display.Bitmap;
import Popup.PopupManager;
import flixel.graphics.FlxGraphic;
import openfl.text.TextFormat;
import flixel.FlxG;
import ui.SimpleInfoDisplay;
import ui.MemoryCounter;
import states.TitleState;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		#if mobile
		SUtil.uncaughtErrorHandler();
		#end
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	public static var popupManager:PopupManager;

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !cpp
		framerate = 60;
		#end

		#if !debug
		initialState = TitleState;
		#end

		#if cpp 
		cpp.vm.Gc.enable(true);
		#end

		SUtil.checkFiles();

		addChild(new Bitmap(new BitmapData(Std.int(Capabilities.screenResolutionX),
		Std.int(Capabilities.screenResolutionY), false, FlxColor.fromRGB(1,1,1)), true));

		var game:FlxGame = new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		FlxGraphic.defaultPersist = false;
		FlxG.signals.preStateSwitch.add(function()
		{

			//i tihnk i finally fixed it

			@:privateAccess
			for (key in FlxG.bitmap._cache.keys())
			{
				var obj = FlxG.bitmap._cache.get(key);
				if (obj != null)
				{
					lime.utils.Assets.cache.image.remove(key);
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					//obj.destroy(); //breaks the game lol
				}
			}

			//idk if this helps because it looks like just clearing it does the same thing
			for (k => f in lime.utils.Assets.cache.font)
				lime.utils.Assets.cache.font.remove(k);
			for (k => s in lime.utils.Assets.cache.audio)
				lime.utils.Assets.cache.audio.remove(k);

			/* 
			@:privateAccess
			{
				for (k => f in openfl.Assets.cache._font)
					openfl.Assets.cache._font.removeFont(k);
				for (k => s in openfl.Assets.cache._audio)
					openfl.Assets.cache.audio.removeSound(k);
			}
			*/

			


			//Paths.clearMemory();
			lime.utils.Assets.cache.clear();

			openfl.Assets.cache.clear();
	
			FlxG.bitmap.dumpCache();
	
			#if polymod
			polymod.Polymod.clearCache();
			
			#end

			#if cpp
			cpp.vm.Gc.enable(true);
			#end
	
			#if sys
			openfl.system.System.gc();	
			#end
		});

		FlxG.signals.postStateSwitch.add(function()
		{
			#if cpp
			cpp.vm.Gc.enable(true);
			#end
	
			#if sys
			openfl.system.System.gc();	
			#end
		});

		//#if !mobile
		display = new SimpleInfoDisplay(10, 3, 0xFFFFFF, "_sans");
		addChild(display);
		//#end

		FlxG.signals.gameResized.add(fixCameraShaders);

		popupManager = new PopupManager();
		addChild(popupManager);
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	function onCrash(e:UncaughtErrorEvent)
	{
		#if desktop
		var callstack:Array<StackItem> = CallStack.exceptionStack(true);
		trace(CallStack.toString(callstack));
		trace(e.error);

		Lib.application.window.alert(CallStack.toString(callstack), e.error); //popup crash with callstack and error message

		Sys.exit(0);
		#end
	}

	public static var display:SimpleInfoDisplay;

	public static function toggleFPS(fpsEnabled:Bool):Void
	{
		display.infoDisplayed[0] = fpsEnabled;
	}

	public static function toggleMem(memEnabled:Bool):Void
	{
		display.infoDisplayed[1] = memEnabled;
	}
	
	public static function toggleVers(versEnabled:Bool):Void
	{
		display.infoDisplayed[2] = versEnabled;
	}

	public static function changeFont(font:String):Void
	{
		display.defaultTextFormat = new TextFormat(font, (font == "_sans" ? 12 : 14), display.textColor);
	}

	/* cool kade functions D) */
	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public static function fixCameraShaders(w:Int, h:Int) //fixes shaders after resizing the window / fullscreening
	{
		if (FlxG.cameras.list.length > 0)
		{
			for (cam in FlxG.cameras.list)
			{
				if (cam.flashSprite != null)
				{
					@:privateAccess 
					{
						cam.flashSprite.__cacheBitmap = null;
						cam.flashSprite.__cacheBitmapData = null;
						cam.flashSprite.__cacheBitmapData2 = null;
						cam.flashSprite.__cacheBitmapData3 = null;
						cam.flashSprite.__cacheBitmapColorTransform = null;
					}
				}
			}
		}
		
	}

	public static var noGPU:Bool = false;

	public static function loadGPUTexture(key:String, bitmap:BitmapData)
	{
		var disable:Bool = !Options.getData("gpuTextures");
		//trace(key);
		if (disable || noGPU) //dont load gpu texture
		{
			return bitmap;
		}

		//load gpu texture
		var tex = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
		tex.uploadFromBitmapData(bitmap);
		bitmap.image.data = null;
		bitmap.dispose();
		bitmap.disposeImage();
		bitmap = BitmapData.fromTexture(tex);
		return bitmap;
	}
}
