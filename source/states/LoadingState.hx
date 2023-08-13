package states;

import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import game.StageGroup;
import flixel.system.FlxSound;
import game.Song;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import haxe.io.Path;
#if sys
import sys.FileSystem;
#end

using StringTools;

class AsyncAssetPreloader
{
	var uiSkins:Array<String> = [];
	var characters:Array<String> = [];
	var stages:Array<String> = [];
	var audio:Array<String> = [];

	var onComplete:Void->Void = null;

	public var percent(get, default):Float = 0;
	private function get_percent()
	{
		if (totalLoadCount > 0)
		{
			percent = loadedCount/totalLoadCount;
		}

		return percent;
	}
	public var totalLoadCount:Int = 0;
	public var loadedCount:Int = 0;

	public function new(onComplete:Void->Void)
	{
		this.onComplete = onComplete;
		generatePreloadList();
	}

	private function generatePreloadList()
	{
		var uiSkin:String = PlayState.SONG.ui_Skin;
		if(Std.string(uiSkin) == "null")
			uiSkin = "default";
		if(uiSkin == "default")
			uiSkin = utilities.Options.getData("uiSkin");

		uiSkins.push(uiSkin);
		stages.push(PlayState.SONG.stage);

		characters.push(PlayState.SONG.player1);
		characters.push(PlayState.SONG.player2);
		characters.push(PlayState.SONG.gf);

		audio.push(Paths.inst(PlayState.SONG.song, 
			(PlayState.SONG.specialAudioName == null ? PlayState.storyDifficultyStr.toLowerCase() : PlayState.SONG.specialAudioName)));
		audio.push(Paths.voices(PlayState.SONG.song, 
			(PlayState.SONG.specialAudioName == null ? PlayState.storyDifficultyStr.toLowerCase() : PlayState.SONG.specialAudioName)));


		var events:Array<Array<Dynamic>> = [];

		if(PlayState.SONG.events.length > 0)
		{
			for(event in PlayState.SONG.events)
			{
				events.push(event);
			}
		}

		if(Assets.exists(Paths.songEvents(PlayState.SONG.song.toLowerCase(), PlayState.storyDifficultyStr.toLowerCase())))
		{
			var eventFunnies:Array<Array<Dynamic>> = Song.parseJSONshit(Assets.getText(Paths.songEvents(PlayState.SONG.song.toLowerCase(), PlayState.storyDifficultyStr.toLowerCase()))).events;

			for(event in eventFunnies)
			{
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
			var eventStr:String = event[0].toLowerCase();
			switch(eventStr)
			{
				case "change character": 
					if (!characters.contains(event[2]))
						characters.push(event[2]);
				case "change stage":
					if (!stages.contains(event[2]))
						stages.push(event[2]);
				case "change ui skin":
					if (!uiSkins.contains(event[2]))
						uiSkins.push(event[2]);
			}
		}

		totalLoadCount = audio.length + characters.length + stages.length + uiSkins.length-1; //do -1 because it will be behind at the end when theres a small freeze
	}

	public function load(async:Bool = true)
	{
		if (async)
		{
			trace('loading async');

		
			var multi:Bool = false;

			if (multi) //sometimes faster, sometimes slower, wont bother using it
			{
				setupFuture(function()
				{
					loadAudio();
					return true;
				});
				setupFuture(function()
				{
					loadStages();
					return true;
				});
				setupFuture(function()
				{
					loadCharacters();
					return true;
				});
				setupFuture(function()
				{
					loadUISkins();
					return true;
				});
			}
			else 
			{
				setupFuture(function()
				{
					loadAudio();
					loadCharacters();
					loadStages();
					loadUISkins();	
					return true;
				});
			}


		}
		else 
		{
			loadAudio();
			loadCharacters();
			loadStages();
			loadUISkins();	
			finish();
		}
	}
	function setupFuture(func:Void->Bool)
	{
		var fut:Future<Bool> = new Future(func, true);
		fut.onComplete(function(ashgfjkasdfhkjl) {
			finish();
		});
		fut.onError(function(_) {
			finish(); //just continue anyway who cares
		});
		totalFinishes++;
	}
	var totalFinishes:Int = 0;
	var finshCount:Int = 0;
	private function finish()
	{
		finshCount++;
		if (finshCount < totalFinishes)
			return;

		if (onComplete != null)
			onComplete();
	}
	public function loadAudio()
	{
		for (i in audio)
		{
			loadedCount++;
			new FlxSound().loadEmbedded(i);
		}
		trace('loaded audio');
	}
	public function loadCharacters()
	{
		if(!utilities.Options.getData("charsAndBGs"))
			return;
		for (i in characters)
		{
			loadedCount++;
			new game.Character(0,0, i);
		}
		trace('loaded characters');
	}
	public function loadStages()
	{
		if(!utilities.Options.getData("charsAndBGs"))
			return;
		for (i in stages)
		{
			loadedCount++;
			new StageGroup(i);
		}
		trace('loaded stages');
	}
	public function loadUISkins()
	{
		for (i in uiSkins)
		{
			loadedCount++;
			new game.StrumNote.UISkin(i);
		}
		trace('loaded UI Skins');
	}



}

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;
	
	var target:FlxState;
	var stopMusic = false;
	var callbacks:MultiCallback;
	
	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft = false;

	public static var instance:LoadingState = null;
	
	function new(target:FlxState, stopMusic:Bool)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
	}

	var loader:AsyncAssetPreloader = null;
	var loadingBar:FlxBar;
	var loadingText:FlxText;
	var lerpedPercent:Float = 0;
	var loadTime:Float = 0;
	
	override function create()
	{
		MusicBeatState.windowNameSuffix = " is loading...";

		instance = this;

		#if PRELOAD_ALL
		var loadingScreen = new FlxSprite(0, 0);
		/*var pickedImage = 'load0.png';
		#if sys
		var path = 'assets/images/loading/loadingscreen';
		#if mobile 
			path = SUtil.getStorageDirectory() + path;
		#end
		var list:Array<String> = [];
		for (file in FileSystem.readDirectory(path))
		{
			if (file.endsWith('.png'))
			{
				list.push(file);
				//trace(file);
			}
		}
		var rarelist:Array<String> = [];
		for (file in FileSystem.readDirectory(path+'rare/'))
		{
			if (file.endsWith('.png'))
			{
				rarelist.push(file);
			}
		}
		//if (FlxG.random.bool(50)) //doesnt work for some reason
		//{
		//	pickedImage = rarelist[FlxG.random.int(0, rarelist.length-1)];
		//}
		//else 
		//{
			pickedImage = list[FlxG.random.int(0, list.length-1)];
		//}
		#end
		
		pickedImage = pickedImage.replace('.png', '');

		trace(pickedImage);*/

		
		loadingScreen.loadGraphic(Paths.image('loading/loadingscreen'));
		loadingScreen.setGraphicSize(1280,720);
		loadingScreen.antialiasing = true;
		loadingScreen.updateHitbox();
		loadingScreen.screenCenter();
		add(loadingScreen);
		/*new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			//FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			onLoad(); //once transition has ended
		});*/



		loader = new AsyncAssetPreloader(function()
		{
			FlxTransitionableState.skipNextTransOut = true;
			trace("Load time: " + loadTime);
			onLoad();
		});
		loader.load(true);

		loadingBar = new FlxBar(0, FlxG.height-25, LEFT_TO_RIGHT, FlxG.width, 25, this,
		'lerpedPercent', 0, 1);
		loadingBar.scrollFactor.set();
		loadingBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		add(loadingBar);

		loadingText = new FlxText(2, FlxG.height-25-26, 0, "Loading...");
		loadingText.setFormat(Paths.font("Contb___.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadingText);

		#else 
		logo = new FlxSprite(-150, -100);
		logo.frames = Paths.getSparrowAtlas('title/logoBumpin');
		logo.antialiasing = true;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.animation.play('bump');
		logo.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('title/gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(logo);
		
		
		
		initSongsManifest().onComplete
		(
			function (lib)
			{
				callbacks = new MultiCallback(onLoad);
				var introComplete = callbacks.add("introComplete");
				checkLoadSong(getSongPath());

				if (PlayState.SONG.needsVoices)
					checkLoadSong(getVocalPath());

				checkLibrary("shared");
				checkLibrary("stages");
				checkLibrary("songs");
				
				var fadeTime = 0.5;
				FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
				new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
			}
		);
		#end

		

		
	}
	
	public function checkLoadSong(path:String)
	{
		if(Assets.exists(path))
		{
			if (!Assets.cache.hasSound(path))
			{
				if(callbacks == null)
					callbacks = new MultiCallback(onLoad);
	
				var library = Assets.getLibrary("songs");
				final symbolPath = path.split(":").pop();
				// @:privateAccess
				// library.types.set(symbolPath, SOUND);
				// @:privateAccess
				// library.pathGroups.set(symbolPath, [library.__cacheBreak(symbolPath)]);
				var callback = callbacks.add("song:" + path);
				Assets.loadSound(path).onComplete(function (_) { callback(); });
			}
		}
	}
	
	function checkLibrary(library:String)
	{
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;
			
			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function (_) { callback(); });
		}
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		#if NO_PRELOAD_ALL
		logo.animation.play('bump');
		danceLeft = !danceLeft;
		
		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');
		#end
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (loader != null)
		{
			loadTime += elapsed;
			lerpedPercent = FlxMath.lerp(lerpedPercent, loader.percent, elapsed*8);
			loadingText.text = "Loading... (" + loader.loadedCount + "/" + (loader.totalLoadCount+1) + ")";
		}
		
		#if debug
		if (FlxG.keys.justPressed.SPACE)
			trace('fired: ' + callbacks.getFired() + " unfired:" + callbacks.getUnfired());
		#end
	}
	
	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		FlxG.switchState(target);
	}
	
	public static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}
	
	public static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		FlxG.switchState(getNextState(target, stopMusic));
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		Paths.setCurrentLevel("week" + PlayState.storyWeek);
		#if NO_PRELOAD_ALL
		var loaded = isSoundLoaded(getSongPath())
			&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()))
			&& isLibraryLoaded("shared");
		
		if (!loaded)
			return new LoadingState(target, stopMusic);
		#end
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return new LoadingState(target, stopMusic);
	}
	
	#if NO_PRELOAD_ALL
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	#end
	
	override function destroy()
	{
		super.destroy();
		
		callbacks = null;
	}
	
	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();
	
	public function new (callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function ()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;
				
				if (logId != null)
					log('fired $id, $numRemaining remaining');
				
				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}
	
	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}
	
	public function getFired() return fired.copy();
	public function getUnfired() return [for (id in unfired.keys()) id];
}