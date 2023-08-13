package modding;
#if desktop
import modding.FlxTransWindow;
#end
import flixel.input.gamepad.FlxGamepad;
import flixel.input.FlxInput.FlxInputState;
import Popup.MessagePopup;
import openfl.display.BitmapData;
import flixel.addons.effects.FlxTrail;
import flixel.text.FlxText;
import utilities.Options;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import openfl.display.BlendMode;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import utilities.Controls;
import backgrounds.DancingSprite;
import game.Note;
import game.Boyfriend;
import openfl.display.Sprite;
import flixel.util.FlxTimer;
import ui.HealthIcon;
import lime.ui.Window;
import openfl.Lib;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import game.Character;
import flixel.util.FlxColor;
#if linc_luajit
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import flixel.FlxSprite;
import states.PlayState;
import lime.utils.Assets;
import flixel.system.FlxSound;
import utilities.CoolUtil;
import polymod.Polymod;
import polymod.backends.PolymodAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import llua.Lua.Lua_helper;
import flixel.FlxG;
import game.Conductor;
import states.LoadingState;
import lime.app.Application;
import states.MainMenuState;
import flixel.math.FlxMath;

import hscript.Parser;
import hscript.Interp;

using StringTools;

typedef LuaCamera =
{
    var cam:FlxCamera;
    var shaders:Array<BitmapFilter>;
    var shaderNames:Array<String>;
} 

class ModchartUtilities
{
    public var lua:State = null;

    public static var lua_Sprites:Map<String, FlxSprite> = [
        'boyfriend' => PlayState.boyfriend,
        'girlfriend' => PlayState.gf,
        'dad' => PlayState.dad,
    ];

    public static var lua_Characters:Map<String, Character> = [
        'boyfriend' => PlayState.boyfriend,
        'girlfriend' => PlayState.gf,
        'dad' => PlayState.dad,
    ];
    var windowDad:Window;
	var dadWin = new Sprite();
	var dadScrollWin = new Sprite();
    public var defaultCamZoom:Float = 1.05;

    public static var lua_Sounds:Map<String, FlxSound> = [];
    public static var lua_Cameras:Map<String, LuaCamera> = [];
    public static var lua_Shaders:Map<String, shaders.Shaders.ShaderEffect> = [];
    //public static var camGameShaders:Array<BitmapFilter> = [];
    //public static var camHUDShaders:Array<BitmapFilter> = [];

    //taken from psych engine (slightly old because i think its easier to quickly add lol)
    public static var haxeInterp:Interp = null;
    public function initHaxeInterp()
        {
            if(haxeInterp == null)
            {
                haxeInterp = new Interp();
                haxeInterp.variables.set('FlxG', FlxG);
                haxeInterp.variables.set('FlxSprite', FlxSprite);
                haxeInterp.variables.set('FlxCamera', FlxCamera);
                haxeInterp.variables.set('FlxTween', FlxTween);
                haxeInterp.variables.set('FlxEase', FlxEase);
                haxeInterp.variables.set('PlayState', states.PlayState);
                haxeInterp.variables.set('game', states.PlayState.instance);
                haxeInterp.variables.set('Paths', Paths);
                haxeInterp.variables.set('Conductor', game.Conductor);
                haxeInterp.variables.set('Note', game.Note);
                haxeInterp.variables.set('Character', game.Character);
                haxeInterp.variables.set('Alphabet', ui.Alphabet);
                haxeInterp.variables.set('StringTools', StringTools);
                haxeInterp.variables.set('FlxTrail', FlxTrail);

                haxeInterp.variables.set('FlxView3D', flx3D.FlxView3D);
                haxeInterp.variables.set('Scene3D', states.TestState.Scene3D);
                
                haxeInterp.variables.set('Mesh', away3d.entities.Mesh);
                haxeInterp.variables.set('ControllerBase', away3d.controllers.ControllerBase);
                haxeInterp.variables.set('FirstPersonController', away3d.controllers.FirstPersonController);
                haxeInterp.variables.set('HoverController', away3d.controllers.HoverController);
    
                haxeInterp.variables.set('setVar', function(name:String, value:Dynamic)
                {
                    PlayState.instance.variables.set(name, value);
                });
                haxeInterp.variables.set('getVar', function(name:String)
                {
                    if(!PlayState.instance.variables.exists(name)) return null;
                    return PlayState.instance.variables.get(name);
                });
            }
        }

	function getActorByName(id:String):Dynamic
    {
        if (lua_Cameras.exists(id))
            return lua_Cameras.get(id).cam;
        // lua objects or what ever
        if(!lua_Sprites.exists(id))
        {
            if(Std.parseInt(id) == null)
                return Reflect.getProperty(PlayState.instance, id);

            @:privateAccess
            return PlayState.strumLineNotes.members[Std.parseInt(id)];
        }
 

        return lua_Sprites.get(id);
    }

    function getCharacterByName(id:String):Dynamic
    {
        // lua objects or what ever
        if(lua_Characters.exists(id))
            return lua_Characters.get(id);
        else
            return null;
    }
    
    function getCameraByName(id:String):LuaCamera
    {
        if(lua_Cameras.exists(id))
            return lua_Cameras.get(id);

        switch(id.toLowerCase())
        {
            case 'camhud' | 'hud': return lua_Cameras.get("hud");
        }
        

        return lua_Cameras.get("game");
    }
    public static function killShaders() //dead
    {
        for (cam in lua_Cameras)
        {
            cam.shaders = [];
            cam.shaderNames = [];
        }
    }

    public function die()
    {
        PlayState.songMultiplier = oldMultiplier;

        lua_Sprites.clear();
        lua_Characters.clear();
        lua_Cameras.clear();
        lua_Sounds.clear();


        Lua.close(lua);
        lua = null;
    }

    function getLuaErrorMessage(l) {
		var v:String = Lua.tostring(l, -1);
		Lua.pop(l, 1);

		return v;
	}

    function callLua(func_name : String, args : Array<Dynamic>, ?type : String) : Dynamic
    {
        var result : Any = null;

        Lua.getglobal(lua, func_name);

        for( arg in args ) {
            Convert.toLua(lua, arg);
        }

        result = Lua.pcall(lua, args.length, 1, 0);

        var p = Lua.tostring(lua, result);
        var e = getLuaErrorMessage(lua);

        if (e != null)
        {
            if (p != null)
            {
                /*
                Application.current.window.alert("LUA ERROR:\n" + p + "\nhaxe things: " + e,"Leather's Funkin' Engine Modcharts");
                lua = null; 
                LoadingState.loadAndSwitchState(new MainMenuState());
                */
            }
        }

        if( result == null) {
            return null;
        } else {
            return convert(result, type);
        }
    }

    public function setVar(var_name : String, object : Dynamic)
    {
        if(Std.isOfType(object, Bool))
            Lua.pushboolean(lua, object);
        else if(Std.isOfType(object, String))
            Lua.pushstring(lua, object);
        else
            Lua.pushnumber(lua, object);

		Lua.setglobal(lua, var_name);
	}

    var oldMultiplier:Float = PlayState.songMultiplier;

    public var trails:Map<String, FlxTrail> = [];

    public var perlin:Perlin;

    function new(?path:Null<String>)
    {
        var propBlackList = ["onUnlock", "score", "songScore", "misses", "accuracy", "hasMechAndModchartsEnabled", "health", "propBlackList", "isCheating", "hasUsedBot", "didDie", "invincible", 'playingFDGOD', "beatFDGOD", "beatFDGODold", "FlxG.save.data", "save.data", 
        "inMultiplayerSession", "multiplayerEnded", "multiplayerSessionEndcheck", "badChart", "fdgod2PlayerSide", "progress", "goodNoteHit", "wasGoodHit", "strumTime", "notes", "unspawnNotes"];
        var classBlackList = ["ChartChecker", "GameJoltStuff", "Popup", "FlxGameJolt", "Options", "AwardManager"];

        //some shaders just dont work at all on mobile
        var mobileShaderBlacklist:Array<String> = ["BloomEffect", "ChromAbEffect", "ChromAbBlueSwapEffect", "VignetteEffect", "SparkEffect", "MosaicEffect", "ColorFillEffect", "SobelEffect"]; 

        oldMultiplier = PlayState.songMultiplier;

        perlin = new Perlin();

        lua_Sprites.set("boyfriend", PlayState.boyfriend);
        lua_Sprites.set("girlfriend", PlayState.gf);
        lua_Sprites.set("dad", PlayState.dad);

        lua_Characters.set("boyfriend", PlayState.boyfriend);
        lua_Characters.set("girlfriend", PlayState.gf);
        lua_Characters.set("dad", PlayState.dad);

        lua_Cameras.set("game", {cam: PlayState.instance.camGame, shaders: [], shaderNames: []});
        lua_Cameras.set("hud", {cam: PlayState.instance.camHUD, shaders: [], shaderNames: []});

        lua_Sounds.set("Inst", FlxG.sound.music);
        @:privateAccess
        lua_Sounds.set("Voices", PlayState.instance.vocals);

        lua = LuaL.newstate();
        LuaL.openlibs(lua);

        //trace("lua version: " + Lua.version());
        //trace("LuaJIT version: " + Lua.versionJIT());
        trace(path);

        Lua.init_callbacks(lua);

        if(path == null)
        {
            #if mobile
            path = SUtil.getStorageDirectory() + Paths.lua("modcharts/" + PlayState.SONG.modchartPath);
            #else 
            path = PolymodAssets.getPath(Paths.lua("modcharts/" + PlayState.SONG.modchartPath));
            #end
        }
            

        var result = LuaL.dofile(lua, path); // execute le file

        if (result != 0)
        {
            #if !mobile
            Application.current.window.alert("lua COMPILE ERROR:\n" + Lua.tostring(lua,result),"Leather Engine Modcharts");
            #end
            //FlxG.switchState(new MainMenuState());
        }

        // this might become a problem if i don't do this
        setVar("require", false);
        setVar("os", false);

        // get some fukin globals up in here bois

        setVar("songLower", PlayState.SONG.song.toLowerCase());

        setVar("bloomSetting", utilities.Options.getData("bloom"));
        setVar("shaders", utilities.Options.getData("shaders"));
        setVar("modcharts", utilities.Options.getData("modcharts"));
        setVar("mechanics", utilities.Options.getData("mechanics"));

        setVar("difficulty", PlayState.storyDifficultyStr);
        setVar("bpm", Conductor.bpm);
        setVar("songBpm", PlayState.SONG.bpm);
        setVar("keyCount", PlayState.SONG.keyCount);
        setVar("playerKeyCount", PlayState.SONG.playerKeyCount);
        setVar("scrollspeed", PlayState.SONG.speed);
        setVar("fpsCap", utilities.Options.getData("maxFPS"));
        setVar("opponentPlay", PlayState.characterPlayingAs == 1);
        setVar("bot", utilities.Options.getData("botplay"));
        setVar("noDeath", utilities.Options.getData("noDeath"));
        setVar("downscroll", utilities.Options.getData("downscroll") == true ? 1 : 0); // fuck you compatibility
        setVar("downscrollBool", utilities.Options.getData("downscroll"));
	    setVar("middlescroll", utilities.Options.getData("middlescroll"));
        setVar("flashingLights", utilities.Options.getData("flashingLights"));
        setVar("flashing", utilities.Options.getData("flashingLights"));
        //setVar("distractions", .distractions);
        setVar("cameraZooms", utilities.Options.getData("cameraZooms"));

        setVar("animatedBackgrounds", utilities.Options.getData("animatedBGs"));

        setVar("charsAndBGs", utilities.Options.getData("charsAndBGs"));

        setVar("curStep", 0);
        setVar("curBeat", 0);
        setVar("crochet", Conductor.stepCrochet / PlayState.songMultiplier);
        setVar("safeZoneOffset", Conductor.safeZoneOffset);

        setVar("crochetUnscaled", Conductor.stepCrochet);

        setVar("hudZoom", PlayState.instance.camHUD.zoom);
        setVar("cameraZoom", FlxG.camera.zoom);

        setVar("cameraAngle", FlxG.camera.angle);

        setVar("camHudAngle", PlayState.instance.camHUD.angle);

        setVar("followXOffset",0);
        setVar("followYOffset",0);

        setVar("showOnlyStrums", false);
        setVar("strumLine1Visible", true);
        setVar("strumLine2Visible", true);

        setVar("screenWidth", lime.app.Application.current.window.display.currentMode.width);
        setVar("screenHeight", lime.app.Application.current.window.display.currentMode.height);
        setVar("windowWidth", FlxG.width);
        setVar("windowHeight", FlxG.height);

        setVar("hudWidth", PlayState.instance.camHUD.width);
        setVar("hudHeight", PlayState.instance.camHUD.height);

        setVar("mustHit", false);
        setVar("strumLineY", PlayState.instance.strumLine.y);

        setVar("characterPlayingAs", PlayState.characterPlayingAs);
        setVar("inReplay", PlayState.playingReplay);
        
        setVar("player1", PlayState.SONG.player1);
        setVar("player2", PlayState.SONG.player2);

        setVar("curStage", PlayState.SONG.stage);

        #if mobile
        setVar("mobile", true);
        #else 
        setVar("mobile", false);
        #end

        // callbacks

        Lua_helper.add_callback(lua, "runHaxeCode", function(codeToRun:String) {
			initHaxeInterp();
            var isCheating:Bool = false;

            for (blacklistedVar in propBlackList)
            {
                if (codeToRun.contains(blacklistedVar))
                {
                    //Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "stop lol"));
                    isCheating = true;
                }
            }
            for (blacklistedVar in classBlackList)
            {
                if (codeToRun.contains(blacklistedVar))
                {
                    //Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "stop lol"));
                    isCheating = true;
                }
            }
            if (isCheating)
                return;

			try {
				var myFunction:Dynamic = haxeInterp.expr(new Parser().parseString(codeToRun));
				myFunction();
			}
			catch (e:Dynamic) {
                
			}
		});

		Lua_helper.add_callback(lua, "addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			initHaxeInterp();


            for (blacklistedVar in classBlackList)
            {
                if (libName.contains(blacklistedVar) || libPackage.contains(blacklistedVar))
                {
                    Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "stop lol"));
                    return;
                }
            }

			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';

				haxeInterp.variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				//luaTrace(scriptName + ":" + lastCalledFunction + " - " + e, false, false);
			}
		});

        Lua_helper.add_callback(lua,"flashCamera", function(camera:String = "", color:String = "#FFFFFF", time:Float = 1, force:Bool = false) {
            if(utilities.Options.getData("flashingLights"))
                cameraFromString(camera).flash(FlxColor.fromString(color), time, null, force);
        });

        Lua_helper.add_callback(lua,"trace", function(str:String = "") {
            trace(str);
        });

        #if VIDEOS_ALLOWED
        Lua_helper.add_callback(lua,"startLuaVideo", function(name:String = "", ext:String = ".mp4") {
            
            var foundFile:Bool = false;
            var fileName:String = #if sys Sys.getCwd() + PolymodAssets.getPath(Paths.video(name, ext)) #else Paths.video(name, ext) #end;
    
            #if sys
            if(sys.FileSystem.exists(fileName)) {
                foundFile = true;
            }
            #end
    
            if(!foundFile) {
                fileName = Paths.video(name);
    
                #if sys
                if(sys.FileSystem.exists(fileName)) {
                #else
                if(OpenFlAssets.exists(fileName)) {
                #end
                    foundFile = true;
                }
            }

            if (foundFile)
            {
                @:privateAccess
                PlayState.instance.canPause = false;

                PlayState.instance.luaVideo = new FlxVideo(fileName);
                PlayState.instance.luaVideo.finishCallback = function()
                {
                    @:privateAccess
                    PlayState.instance.canPause = true;
                    PlayState.instance.luaVideo = null;
                }
                PlayState.instance.luaVideo.readyCallback = function()
                {
                    //FlxVideo.vlcBitmap.pause();
                }
            }
        });

        Lua_helper.add_callback(lua,"pauseLuaVideo", function() {
            if (PlayState.instance.luaVideo != null)
            {
                #if desktop
                if (FlxVideo.vlcBitmap != null)
                {
                    FlxVideo.vlcBitmap.pause();
                }
                #end
            }
        });
        Lua_helper.add_callback(lua,"resumeLuaVideo", function() {
            if (PlayState.instance.luaVideo != null)
            {
                #if desktop
                if (FlxVideo.vlcBitmap != null)
                {
                    FlxVideo.vlcBitmap.resume();
                }
                #end
            }
        });
        Lua_helper.add_callback(lua,"setLuaVideoTime", function(time:Float) {
            if (PlayState.instance.luaVideo != null)
            {
                #if desktop
                if (FlxVideo.vlcBitmap != null)
                {
                    FlxVideo.vlcBitmap.seek(time);
                }
                #end
            }
        });
        Lua_helper.add_callback(lua,"setLuaVideoHide", function(hide:Bool) {
            if (PlayState.instance.luaVideo != null)
            {
                #if desktop
                if (FlxVideo.vlcBitmap != null)
                {
                    FlxVideo.vlcBitmap.hideVideo = hide;
                }
                #end
            }
        });
        Lua_helper.add_callback(lua,"stopLuaVideo", function() {
            if (PlayState.instance.luaVideo != null)
            {
                PlayState.instance.luaVideo.onVLCComplete();
            }
        });
        #end
        

        Lua_helper.add_callback(lua,"perlin", function(x:Float, y:Float, z:Float) {
            return perlin.perlin(x,y,z);
        });

        Lua_helper.add_callback(lua,"PopupWindow", function(thetext:String) {
            Application.current.window.alert(thetext,"REJECTED");
        });

        Lua_helper.add_callback(lua,"addCharacterToMap", function(m:String, character:String) {
            var map:Map<String, Dynamic>;

            switch(m.toLowerCase())
            {
                case "dad" | "opponent" | "player2" | "1":
                    map = PlayState.instance.dadMap;
                case "gf" | "girlfriend" | "player3" | "2":
                    map = PlayState.instance.gfMap;
                default:
                    map = PlayState.instance.bfMap;
            }
            var funnyCharacter:Character;

            if(map == PlayState.instance.bfMap)
                funnyCharacter = new Boyfriend(100, 100, character);
            else
                funnyCharacter = new Character(100, 100, character);

            funnyCharacter.alpha = 0.00001;
            PlayState.instance.add(funnyCharacter);

            map.set(character, funnyCharacter);

            if(funnyCharacter.otherCharacters != null)
            {
                for(character in funnyCharacter.otherCharacters)
                {
                    character.alpha = 0.00001;
                    PlayState.instance.add(character);
                }
            }
        });

        Lua_helper.add_callback(lua,"triggerEvent", function(event_name:String, argument_1:Dynamic, argument_2:Dynamic) {
			var string_arg_1:String = Std.string(argument_1);
			var string_arg_2:String = Std.string(argument_2);

            if(!PlayState.instance.event_luas.exists(event_name.toLowerCase()) && Assets.exists(Paths.lua("event data/" + event_name.toLowerCase())))
            {
                PlayState.instance.event_luas.set(event_name.toLowerCase(), ModchartUtilities.createModchartUtilities(PolymodAssets.getPath(Paths.lua("event data/" + event_name.toLowerCase()))));
                PlayState.instance.generatedSomeDumbEventLuas = true;
            }

            PlayState.instance.processEvent([event_name, Conductor.songPosition, string_arg_1, string_arg_2]);
        });

        Lua_helper.add_callback(lua,"setObjectCamera", function(id:String, camera:String = "") {
            var actor:FlxSprite = getActorByName(id);

            if(actor != null)
                Reflect.setProperty(actor, "cameras", [cameraFromString(camera)]);
        });

        Lua_helper.add_callback(lua,"setActorColorRGB", function(id:String, color:String) {
            var actor:FlxSprite = getActorByName(id);

            var colors = color.split(',');
            var red = Std.parseInt(colors[0]);
            var green = Std.parseInt(colors[1]);
            var blue = Std.parseInt(colors[2]);

            if(actor != null)
                Reflect.setProperty(actor, "color", FlxColor.fromRGB(red,green,blue));
        });

        Lua_helper.add_callback(lua,"justPressedDodgeKey", function() {
            
            var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
            if (gamepad != null)
            {
                if (gamepad.checkStatus(FlxGamepadInputID.fromString(utilities.Options.getData("dodgeControllerBind", "binds")), FlxInputState.JUST_PRESSED))
                {
                    return true;
                }

            }

            #if mobile
            var controls = PlayState.instance.mobileControls;
            if (controls.getDodgeJustPressed())
                return true;
            #end

            return FlxG.keys.checkStatus(FlxKey.fromString(utilities.Options.getData("dodgeBind", "binds")), FlxInputState.JUST_PRESSED);
        });


        Lua_helper.add_callback(lua,"justPressed", function(key:String = "SPACE") {
            return Reflect.getProperty(FlxG.keys.justPressed, key);
        });
        Lua_helper.add_callback(lua,"pressed", function(key:String = "SPACE") {
            return Reflect.getProperty(FlxG.keys.pressed, key);
        });

        Lua_helper.add_callback(lua,"setGraphicSize", function(id:String, width:Int = 0, height:Int = 0) {
            var actor:FlxSprite = getActorByName(id);

            if(actor != null)
                actor.setGraphicSize(width, height);
        });

        Lua_helper.add_callback(lua,"updateHitbox", function(id:String) {
            var actor:FlxSprite = getActorByName(id);

            if(actor != null)
                actor.updateHitbox();
        });

        Lua_helper.add_callback(lua, "setBlendMode", function(id:String, blend:String = '') {
            var actor:FlxSprite = getActorByName(id);

            if(actor != null)
                actor.blend = blendModeFromString(blend);
		});

        Lua_helper.add_callback(lua,"getSingDirectionID",function(id:Int) {
            var thing = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
            var singDir = utilities.NoteVariables.Character_Animation_Arrays[PlayState.SONG.playerKeyCount - 1][Std.int(Math.abs(id % PlayState.SONG.playerKeyCount))];
            return thing.indexOf(singDir);
        });

        // sprites

        // stage

        Lua_helper.add_callback(lua, "makeGraphic", function(id:String, width:Int, height:Int, color:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).visible = true;
                getActorByName(id).makeGraphic(width, height, FlxColor.fromString(color));

            }
		});
        Lua_helper.add_callback(lua, "makeGraphicRGB", function(id:String, width:Int, height:Int, color:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).visible = true;
                var colors = color.split(',');
                var red = Std.parseInt(colors[0]);
                var green = Std.parseInt(colors[1]);
                var blue = Std.parseInt(colors[2]);
                getActorByName(id).makeGraphic(width, height, FlxColor.fromRGB(red,green,blue));
            }      
		});

        Lua_helper.add_callback(lua,"makeStageSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:FlxSprite = new FlxSprite(x, y);

                @:privateAccess
                if(filename != null && filename.length > 0)
                    Sprite.loadGraphic(Paths.image(PlayState.instance.stage.stage + "/" + filename, "stages"));

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                @:privateAccess
                PlayState.instance.stage.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", "Leather Engine Modcharts");
        });

        Lua_helper.add_callback(lua,"makeStageAnimatedSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:FlxSprite = new FlxSprite(x, y);

                @:privateAccess
                if(filename != null && filename.length > 0)
                    Sprite.frames = Paths.getSparrowAtlas(PlayState.instance.stage.stage + "/" + filename, "stages");

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                @:privateAccess
                PlayState.instance.stage.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", "Leather Engine Modcharts");
        });

        Lua_helper.add_callback(lua,"makeStageDancingSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1, ?oneDanceAnimation:Bool, ?antialiasing:Bool) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:DancingSprite = new DancingSprite(x, y, oneDanceAnimation, antialiasing);

                @:privateAccess
                if(filename != null && filename.length > 0)
                    Sprite.frames = Paths.getSparrowAtlas(PlayState.instance.stage.stage + "/" + filename, "stages");

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                @:privateAccess
                PlayState.instance.stage.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", "Leather Engine Modcharts");
        });

        // regular

        Lua_helper.add_callback(lua,"setActorTextColor", function(id:String, color:String) {
            if(getActorByName(id) != null)
                Reflect.setProperty(getActorByName(id), "color", FlxColor.fromString(color));
        });

        Lua_helper.add_callback(lua,"setActorText", function(id:String, text:String) {
            if(getActorByName(id) != null)
                Reflect.setProperty(getActorByName(id), "text", text);
        });
        Lua_helper.add_callback(lua,"setActorFont", function(id:String, font:String) {
            if(getActorByName(id) != null)
                Reflect.setProperty(getActorByName(id), "font", Paths.font(font));
        });

        Lua_helper.add_callback(lua,"setActorOutlineColor", function(id:String, color:String) {
            if(getActorByName(id) != null)
                Reflect.setProperty(getActorByName(id), "borderColor", FlxColor.fromString(color));
        });

        Lua_helper.add_callback(lua,"setActorAlignment", function(id:String, align:String) {
            if(getActorByName(id) != null)
                Reflect.setProperty(getActorByName(id), "alignment", align);
        });

        Lua_helper.add_callback(lua,"makeText", function(id:String, text:String, x:Float, y:Float, size:Int = 32, font:String = "vcr.ttf", fieldWidth:Float = 0) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:FlxTextFix = new FlxTextFix(x, y, fieldWidth, text, size);
                Sprite.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.TRANSPARENT);
                //Sprite.setFormat(Paths.font(font), size);
                Sprite.font = Paths.font(font);
                Sprite.antialiasing = true;

    
                lua_Sprites.set(id, Sprite);
    
                PlayState.instance.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", "Leather Engine Modcharts");
        });

        Lua_helper.add_callback(lua,"makeSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:FlxSprite = new FlxSprite(x, y);

                if(filename != null && filename.length > 0)
                {
                    Sprite.loadGraphic(Paths.image(filename));
                    Sprite.setGraphicSize(Std.int(Sprite.width * size));
                    Sprite.updateHitbox();
                }
                else 
                    Sprite.visible = false;
    
                lua_Sprites.set(id, Sprite);
    
                PlayState.instance.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", "Leather Engine Modcharts");
        });

        Lua_helper.add_callback(lua,"makeSpriteCopy", function(id:String, targetID:String) {
            var actor:FlxSprite = null;
            if(getCharacterByName(targetID) != null)
            {
                var character = getCharacterByName(targetID);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    actor = character.otherCharacters[0];
                }                    
            }
            if(getActorByName(targetID) != null && actor == null)
                actor = getActorByName(targetID);

            if(!lua_Sprites.exists(id) && actor != null)
            {
                var Sprite:FlxSprite = new FlxSprite(actor.x, actor.y);

                Sprite.loadGraphicFromSprite(actor);

                Sprite.alpha = actor.alpha;
                Sprite.angle = actor.angle;
                Sprite.offset.x = actor.offset.x;
                Sprite.offset.y = actor.offset.y;
                Sprite.origin.x = actor.origin.x;
                Sprite.origin.y = actor.origin.y;
                Sprite.scale.x = actor.scale.x;
                Sprite.scale.y = actor.scale.y;
                Sprite.active = false;
                Sprite.animation.frameIndex = actor.animation.frameIndex;
                Sprite.flipX = actor.flipX;
                Sprite.flipY = actor.flipY;
                Sprite.animation.curAnim = actor.animation.curAnim;
                //trace('made sprite copy');
                lua_Sprites.set(id, Sprite);
    
                PlayState.instance.add(Sprite);
            }
        });

        Lua_helper.add_callback(lua,"makeNoteCopy", function(id:String, noteIdx:Int) {
            var actor:FlxSprite = PlayState.instance.notes.members[noteIdx];
            

            if(!lua_Sprites.exists(id) && actor != null)
            {
                var Sprite:FlxSprite = new FlxSprite(actor.x, actor.y);

                Sprite.loadGraphicFromSprite(actor);

                Sprite.alpha = actor.alpha;
                Sprite.angle = actor.angle;
                Sprite.offset.x = actor.offset.x;
                Sprite.offset.y = actor.offset.y;
                Sprite.origin.x = actor.origin.x;
                Sprite.origin.y = actor.origin.y;
                Sprite.scale.x = actor.scale.x;
                Sprite.scale.y = actor.scale.y;
                Sprite.active = false;
                Sprite.animation.frameIndex = actor.animation.frameIndex;
                Sprite.flipX = actor.flipX;
                Sprite.flipY = actor.flipY;
                Sprite.animation.curAnim = actor.animation.curAnim;
                //trace('made sprite copy');
                lua_Sprites.set(id, Sprite);
    
                PlayState.instance.add(Sprite);
            }
        });

        Lua_helper.add_callback(lua,"makeAnimatedSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:FlxSprite = new FlxSprite(x, y);

                if(filename != null && filename.length > 0)
                    Sprite.frames = Paths.getSparrowAtlas(filename);

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                PlayState.instance.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", "Leather Engine Modcharts");
        });

        Lua_helper.add_callback(lua,"makeDancingSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1, ?oneDanceAnimation:Bool, ?antialiasing:Bool) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:DancingSprite = new DancingSprite(x, y, oneDanceAnimation, antialiasing);

                if(filename != null && filename.length > 0)
                    Sprite.frames = Paths.getSparrowAtlas(filename);

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                PlayState.instance.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", "Leather Engine Modcharts");
        });

        Lua_helper.add_callback(lua, "destroySprite", function(id:String) {
            var sprite = lua_Sprites.get(id);

            if (sprite == null)
                return false;

            lua_Sprites.remove(id);

            PlayState.instance.removeObject(sprite);
            sprite.kill();
            sprite.destroy();

            return true;
        });

        Lua_helper.add_callback(lua,"getIsColliding", function(sprite1Name:String, sprite2Name:String) {
            var sprite1 = getActorByName(sprite1Name);

            if(sprite1 != null)
            {
                var sprite2 = getActorByName(sprite2Name);

                if(sprite2 != null)
                    return sprite1.overlaps(sprite2);
            }

            return false;
        });

        Lua_helper.add_callback(lua,"addActorTrail", function(id:String, length:Int = 10, delay:Int = 3, alpha:Float = 0.4, diff:Float = 0.05) {
            if(!trails.exists(id) && getActorByName(id) != null)
            {
                var trail = new FlxTrail(getActorByName(id), null, length, delay, alpha, diff);

                PlayState.instance.insert(PlayState.instance.members.indexOf(getActorByName(id)) - 1, trail);

                trails.set(id, trail);
            }
            else
                trace("Trail " + id + " already exists (or actor is null)!!!");
        });

        Lua_helper.add_callback(lua,"removeActorTrail", function(id:String) {
            if(trails.exists(id))
            {
                PlayState.instance.remove(trails.get(id));

                trails.get(id).destroy();
                trails.remove(id);
            }
            else
                trace("Trail " + id + " doesn't exist!!!");
        });

        Lua_helper.add_callback(lua,"getActorLayer", function(id:String) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    return PlayState.instance.members.indexOf(character.otherCharacters[0]);
                }
                    
            }
            var actor = getActorByName(id);

            if(actor != null)
                return PlayState.instance.members.indexOf(actor);
            else
                return -1;
        });

        Lua_helper.add_callback(lua,"setActorLayer", function(id:String, layer:Int) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    PlayState.instance.remove(character.otherCharacters[0]);
                    PlayState.instance.insert(layer, character.otherCharacters[0]);
                    return;
                }
                    
            }
            var actor = getActorByName(id);
            
            if(actor != null)
            {
                if(trails.exists(id))
                {
                    PlayState.instance.remove(trails.get(id));
                    PlayState.instance.insert(layer - 1, trails.get(id));
                }
                
                PlayState.instance.remove(actor);
                PlayState.instance.insert(layer, actor);
            }
        });

        // health
        
        Lua_helper.add_callback(lua,"getHealth",function() {
            return PlayState.instance.health;
        });

        Lua_helper.add_callback(lua,"setHealth", function (heal:Float) {
            if (PlayState.instance.playingFDGOD)
            {
                if (heal > PlayState.instance.health)
                {
                    //trace('stop healing lol');
                    return; //if you try to force heal, health drain should still work
                }
                    
            }
            PlayState.instance.health = heal;
        });

        Lua_helper.add_callback(lua,"getMinHealth",function() {
            return PlayState.instance.minHealth;
        });

        Lua_helper.add_callback(lua,"getMaxHealth",function() {
            return PlayState.instance.maxHealth;
        });

        Lua_helper.add_callback(lua,'changeHealthRange', function (minHealth:Float, maxHealth:Float) {

            if (PlayState.instance.playingFDGOD)
                return;

            @:privateAccess
            {
                var bar = PlayState.instance.gameHUD.healthBar;
                PlayState.instance.minHealth = minHealth;
                PlayState.instance.maxHealth = maxHealth;
                bar.setRange(minHealth, maxHealth);
            }
        });

        // hud/camera

        Lua_helper.add_callback(lua,"setHudAngle", function (x:Float) {
            PlayState.instance.camHUD.angle = x;
        });

        Lua_helper.add_callback(lua,"setHudPosition", function (x:Int, y:Int) {
            PlayState.instance.camHUD.x = x;
            PlayState.instance.camHUD.y = y;
        });

        Lua_helper.add_callback(lua,"getHudX", function () {
            return PlayState.instance.camHUD.x;
        });

        Lua_helper.add_callback(lua,"getHudY", function () {
            return PlayState.instance.camHUD.y;
        });
        
        Lua_helper.add_callback(lua,"setCamPosition", function (x:Int, y:Int) {
            @:privateAccess
            {
                PlayState.instance.camFollow.x = x;
                PlayState.instance.camFollow.y = y;
            }
        });

        Lua_helper.add_callback(lua,"getCameraX", function () {
            @:privateAccess
            return PlayState.instance.camFollow.x;
        });

        Lua_helper.add_callback(lua,"getCameraY", function () {
            @:privateAccess
            return PlayState.instance.camFollow.y;
        });

        Lua_helper.add_callback(lua,"getCamZoom", function() {
            return FlxG.camera.zoom;
        });

        Lua_helper.add_callback(lua,"getHudZoom", function() {
            return PlayState.instance.camHUD.zoom;
        });

        Lua_helper.add_callback(lua,"setCamZoom", function(zoomAmount:Float) {
            FlxG.camera.zoom = zoomAmount;
        });

        Lua_helper.add_callback(lua,"setHudZoom", function(zoomAmount:Float) {
            PlayState.instance.camHUD.zoom = zoomAmount;
        });
        

        // strumline

        Lua_helper.add_callback(lua, "setStrumlineY", function(y:Float, ?dontMove:Bool = false)
        {
            PlayState.instance.strumLine.y = y;

            if(!dontMove)
            {
                for(note in PlayState.strumLineNotes)
                {
                    note.y = y;
                }
            }
        });

        // actors


        Lua_helper.add_callback(lua,"getUnspawnNotes", function() {
            return PlayState.instance.unspawnNotes.length;
        });
        Lua_helper.add_callback(lua,"getUnspawnedNoteNoteType", function(id:Int) {
            return PlayState.instance.unspawnNotes[id].arrow_Type;
        });
        Lua_helper.add_callback(lua,"getUnspawnedNoteStrumtime", function(id:Int) {
            return PlayState.instance.unspawnNotes[id].strumTime;
        });
        Lua_helper.add_callback(lua,"getUnspawnedNoteMustPress", function(id:Int) {
            return PlayState.instance.unspawnNotes[id].mustPress;
        });
        Lua_helper.add_callback(lua,"getUnspawnedNoteSustainNote", function(id:Int) {
            return PlayState.instance.unspawnNotes[id].isSustainNote;
        });
        Lua_helper.add_callback(lua,"getUnspawnedNoteNoteData", function(id:Int) {
            return PlayState.instance.unspawnNotes[id].noteData;
        });
        Lua_helper.add_callback(lua,"getUnspawnedNoteScaleX", function(id:Int) {
            return PlayState.instance.unspawnNotes[id].scale.x;
        });
        Lua_helper.add_callback(lua,"setUnspawnedNoteXOffset", function(id:Int, offset:Float) {
           PlayState.instance.unspawnNotes[id].xOffset = offset;
        });
        Lua_helper.add_callback(lua,"setUnspawnedNoteYOffset", function(id:Int, offset:Float) {
            PlayState.instance.unspawnNotes[id].yOffset = offset;
        });
        Lua_helper.add_callback(lua,"setUnspawnedNoteAngle", function(id:Int, offset:Float) {
            PlayState.instance.unspawnNotes[id].localAngle = offset;
        });
        Lua_helper.add_callback(lua,"setUnspawnedNoteSingAnimPrefix", function(id:Int, prefix:String) {
            PlayState.instance.unspawnNotes[id].singAnimPrefix = prefix;
        });

        
        Lua_helper.add_callback(lua,"getRenderedNotes", function() {
            return PlayState.instance.notes.length;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteX", function(id:Int) {
            return PlayState.instance.notes.members[id].x;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteArrowType", function(id:Int) {
            return PlayState.instance.notes.members[id].arrow_Type;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteY", function(id:Int) {
            return PlayState.instance.notes.members[id].y;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteType", function(id:Int) {
            return PlayState.instance.notes.members[id].noteData;
        });

        Lua_helper.add_callback(lua,"isSustain", function(id:Int) {
            return PlayState.instance.notes.members[id].isSustainNote;
        });

        Lua_helper.add_callback(lua,"isParentSustain", function(id:Int) {
            return PlayState.instance.notes.members[id].prevNote.isSustainNote;
        });
        
        Lua_helper.add_callback(lua,"getRenderedNoteParentX", function(id:Int) {
            return PlayState.instance.notes.members[id].prevNote.x;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteParentY", function(id:Int) {
            return PlayState.instance.notes.members[id].prevNote.y;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteHit", function(id:Int) {
            return PlayState.instance.notes.members[id].mustPress;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteCalcX", function(id:Int) {
            if (PlayState.instance.notes.members[id].mustPress)
                return PlayState.playerStrums.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;

            return PlayState.strumLineNotes.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
        });

        Lua_helper.add_callback(lua,"anyNotes", function() {
            return PlayState.instance.notes.members.length != 0;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteStrumtime", function(id:Int) {
            return PlayState.instance.notes.members[id].strumTime;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteScaleX", function(id:Int) {
            return PlayState.instance.notes.members[id].scale.x;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteScaleY", function(id:Int) {
            return PlayState.instance.notes.members[id].scale.y;
        });

        Lua_helper.add_callback(lua,"setRenderedNoteScaleX", function(scale:Float, id:Int) {
            //PlayState.instance.notes.members[id].modifiedByLua = true;
            PlayState.instance.notes.members[id].scale.x = scale;
        });
        Lua_helper.add_callback(lua,"setRenderedNoteScaleY", function(scale:Float, id:Int) {
            //PlayState.instance.notes.members[id].modifiedByLua = true;
            PlayState.instance.notes.members[id].scale.y = scale;
        });
        Lua_helper.add_callback(lua,"isRenderedNoteSustainEnd", function(id:Int) {
            if (PlayState.instance.notes.members[id].animation.curAnim != null)
                return PlayState.instance.notes.members[id].animation.curAnim.name.endsWith('end');
            return false;
        });
        Lua_helper.add_callback(lua,"getRenderedNoteSustainScaleY", function(id:Int) {
            return PlayState.instance.notes.members[id].sustainScaleY;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteOffsetX", function(id:Int) {
            var daNote:Note = PlayState.instance.notes.members[id];
            if (daNote.mustPress && !daNote.modifiedByLua)
            {
                var arrayVal = Std.string([daNote.noteData, daNote.arrow_Type, daNote.isSustainNote]);
                if (PlayState.instance.prevPlayerXVals.exists(arrayVal))
                    return PlayState.instance.prevPlayerXVals.get(arrayVal) - daNote.xOffset;
            }
            else 
            {
                var arrayVal = Std.string([daNote.noteData, daNote.arrow_Type, daNote.isSustainNote]);
                if (PlayState.instance.prevEnemyXVals.exists(arrayVal))
                    return PlayState.instance.prevEnemyXVals.get(arrayVal) - daNote.xOffset;
            }

            return 0;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteOffsetY", function(id:Int) {
            var daNote:Note = PlayState.instance.notes.members[id];
            return daNote.yOffset;
        });

        Lua_helper.add_callback(lua,"setRenderedNotePos", function(x:Float,y:Float, id:Int) {
            if (PlayState.instance.notes.members[id] == null)
                throw('error! you cannot set a rendered notes position when it doesnt exist! ID: ' + id);
            else
            {
                //PlayState.instance.notes.members[id].modifiedByLua = true;
                PlayState.instance.notes.members[id].x = x;
                PlayState.instance.notes.members[id].y = y;
            }
        });

        Lua_helper.add_callback(lua,"setRenderedNoteAlpha", function(alpha:Float, id:Int) {
            //PlayState.instance.notes.members[id].modifiedByLua = true;
            PlayState.instance.notes.members[id].alpha = alpha;
        });

        Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scale:Float, id:Int) {
            //PlayState.instance.notes.members[id].modifiedByLua = true;
            PlayState.instance.notes.members[id].setGraphicSize(Std.int(PlayState.instance.notes.members[id].width * scale));
        });

        Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scaleX:Int, scaleY:Int, id:Int) {
            //PlayState.instance.notes.members[id].modifiedByLua = true;
            PlayState.instance.notes.members[id].setGraphicSize(scaleX,scaleY);
        });

        Lua_helper.add_callback(lua,"getRenderedNoteWidth", function(id:Int) {
            return PlayState.instance.notes.members[id].width;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteHeight", function(id:Int) {
            return PlayState.instance.notes.members[id].height;
        });

        Lua_helper.add_callback(lua,"getRenderedNotePrevNoteStrumtime", function(id:Int) {
            return PlayState.instance.notes.members[id].prevNoteStrumtime;
        });

        Lua_helper.add_callback(lua,"setRenderedNoteAngle", function(angle:Float, id:Int) {
            //PlayState.instance.notes.members[id].modifiedByLua = true;
            PlayState.instance.notes.members[id].modAngle = angle;
        });

        Lua_helper.add_callback(lua,"setActorX", function(x:Float,id:String) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    character.otherCharacters[0].x = x;
                    return;
                }
                    
            }
            if(getActorByName(id) != null)
                getActorByName(id).x = x;
        });

        Lua_helper.add_callback(lua,"setActorPos", function(x:Float,y:Float,id:String) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    character.otherCharacters[0].x = x;
                    character.otherCharacters[0].y = y;
                    return;
                }
                    
            }
            var actor = getActorByName(id);

            if(actor != null)
            {
                actor.x = x;
                actor.y = y;
            }
        });

        Lua_helper.add_callback(lua,"setActorScroll", function(x:Float,y:Float,id:String) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    character.otherCharacters[0].scrollFactor.set(x,y);
                    return;
                }
                    
            }
            var actor = getActorByName(id);

            if(getActorByName(id) != null)
            {
                actor.scrollFactor.set(x,y);
            }
        });

        
        Lua_helper.add_callback(lua,"actorScreenCenter", function(id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        character.otherCharacters[0].screenCenter();
                        return;
                    }
                        
                }
            var actor = getActorByName(id);

            if(getActorByName(id) != null)
            {
                actor.screenCenter();
            }
        });
        
        Lua_helper.add_callback(lua,"getOriginalCharX", function(character:Int) {
            @:privateAccess
            return PlayState.instance.stage.getCharacterPos(character)[0];
        });

        Lua_helper.add_callback(lua,"getOriginalCharY", function(character:Int) {
            @:privateAccess
            return PlayState.instance.stage.getCharacterPos(character)[1];
        });
        
        Lua_helper.add_callback(lua,"setActorAccelerationX", function(x:Float,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).acceleration.x = x;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorDragX", function(x:Float,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).drag.x = x;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorVelocityX", function(x:Float,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).velocity.x = x;
            }
        });

        Lua_helper.add_callback(lua,"setActorOriginX", function(x:Float,id:String) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    character.otherCharacters[0].origin.x = x;
                    return;
                }
                    
            }
            if(getActorByName(id) != null)
                getActorByName(id).origin.x = x;
        });
        Lua_helper.add_callback(lua,"setActorOriginY", function(x:Float,id:String) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    character.otherCharacters[0].origin.y = x;
                    return;
                }
                    
            }
            if(getActorByName(id) != null)
                getActorByName(id).origin.y = x;
        });

        Lua_helper.add_callback(lua,"setActorAntialiasing", function(antialiasing:Bool,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).antialiasing = antialiasing;
            }
        });

        Lua_helper.add_callback(lua,"addActorAnimation", function(id:String,prefix:String,anim:String,fps:Int = 30, looped:Bool = true) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).animation.addByPrefix(prefix, anim, fps, looped);
            }
        });

        Lua_helper.add_callback(lua,"addActorAnimationIndices", function(id:String,prefix:String,indiceString:String,anim:String,fps:Int = 30, looped:Bool = true) {
            if(getActorByName(id) != null)
            {
                var indices:Array<Dynamic> = indiceString.split(",");

                for(indiceIndex in 0...indices.length)
                {
                    indices[indiceIndex] = Std.parseInt(indices[indiceIndex]);
                }

                getActorByName(id).animation.addByIndices(anim, prefix, indices, "", fps, looped);
            }
        });
        
        Lua_helper.add_callback(lua,"playActorAnimation", function(id:String,anim:String,force:Bool = false,reverse:Bool = false,frame:Int = 0) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    character.otherCharacters[0].animation.play(anim, force, reverse, frame);
                    return;
                }
                    
            }
            if(getActorByName(id) != null)
            {
                getActorByName(id).animation.play(anim, force, reverse, frame);
            }
        });
        
        Lua_helper.add_callback(lua,"playActorDance", function(id:String, ?altAnim:String = '') {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    character.otherCharacters[0].dance(altAnim);
                    return;
                }
                    
            }
            if(getActorByName(id) != null)
            {
                getActorByName(id).dance(altAnim);
            }
        });

        Lua_helper.add_callback(lua,"playCharacterAnimation", function(id:String,anim:String,force:Bool = false,reverse:Bool = false,frame:Int = 0) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    character.otherCharacters[0].playAnim(anim, force, reverse, frame);
                    return;
                }
                    
            }
            if(getActorByName(id) != null)
            {
                getActorByName(id).playAnim(anim, force, reverse, frame);
            }
        });

        Lua_helper.add_callback(lua,"setCharacterShouldDance", function(id:String, shouldDance:Bool = true) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        character.otherCharacters[0].shouldDance = shouldDance;
                        return;
                    }
                        
                }
            if(getActorByName(id) != null)
            {
                getActorByName(id).shouldDance = shouldDance;
            }
        });
        Lua_helper.add_callback(lua,"setCharacterPlayFullAnim", function(id:String, playFullAnim:Bool = true) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        character.otherCharacters[0].playFullAnim = playFullAnim;
                        return;
                    }
                        
                }
            if(getActorByName(id) != null)
            {
                getActorByName(id).playFullAnim = playFullAnim;
            }
        });
        Lua_helper.add_callback(lua,"setCharacterSingPrefix", function(id:String, prefix:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        character.otherCharacters[0].singAnimPrefix = prefix;
                        return;
                    }
                        
                }
            if(getActorByName(id) != null)
            {
                getActorByName(id).singAnimPrefix = prefix;
            }
        });
        Lua_helper.add_callback(lua,"setCharacterPreventDanceForAnim", function(id:String, preventDanceForAnim:Bool = true) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    character.otherCharacters[0].preventDanceForAnim = preventDanceForAnim;
                    return;
                }
                    
            }
            if(getActorByName(id) != null)
            {
                getActorByName(id).preventDanceForAnim = preventDanceForAnim;
            }
        });

        Lua_helper.add_callback(lua,"playCharacterDance", function(id:String,?altAnim:String) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    character.otherCharacters[0].dance(altAnim);
                    return;
                }
                    
            }
            if(getActorByName(id) != null)
            {
                getActorByName(id).dance(altAnim);
            }
        });

        Lua_helper.add_callback(lua,"getPlayingActorAnimation", function(id:String) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    return Reflect.getProperty(Reflect.getProperty(Reflect.getProperty(character.otherCharacters[0], "animation"), "curAnim"), "name");
            }
            if(getActorByName(id) != null)
            {
                if(Reflect.getProperty(Reflect.getProperty(getActorByName(id), "animation"), "curAnim") != null)
                    return Reflect.getProperty(Reflect.getProperty(Reflect.getProperty(getActorByName(id), "animation"), "curAnim"), "name");
            }

            return "unknown";
        });

        Lua_helper.add_callback(lua,"getPlayingActorAnimationFrame", function(id:String) {
            if(getActorByName(id) != null)
            {
                if(Reflect.getProperty(Reflect.getProperty(getActorByName(id), "animation"), "curAnim") != null)
                    return Reflect.getProperty(Reflect.getProperty(Reflect.getProperty(getActorByName(id), "animation"), "curAnim"), "curFrame");
            }

            return 0;
        });

        Lua_helper.add_callback(lua,"setActorAlpha", function(alpha:Float,id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        Reflect.setProperty(character.otherCharacters[0], "alpha", alpha);
                        return;
                    }
                        
                }
            if(getActorByName(id) != null)
                Reflect.setProperty(getActorByName(id), "alpha", alpha);
        });

        Lua_helper.add_callback(lua,"setActorVisible", function(visible:Bool,id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        character.otherCharacters[0].visible = visible;
                        return;
                    }
                        
                }
            if(getActorByName(id) != null)
                getActorByName(id).visible = visible;
        });

        Lua_helper.add_callback(lua,"setActorColor", function(id:String,r:Int,g:Int,b:Int,alpha:Int = 255) {
            if(getActorByName(id) != null)
            {
                Reflect.setProperty(getActorByName(id), "color", FlxColor.fromRGB(r, g, b, alpha));
            }
        });

        Lua_helper.add_callback(lua,"setActorY", function(y:Float,id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        Reflect.setProperty(character.otherCharacters[0], "y", y);
                        return;
                    }
                        
                }
            if(getActorByName(id) != null)
                Reflect.setProperty(getActorByName(id), "y", y);
        });

        Lua_helper.add_callback(lua,"setActorAccelerationY", function(y:Float,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).acceleration.y = y;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorDragY", function(y:Float,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).drag.y = y;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorVelocityY", function(y:Float,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).velocity.y = y;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorAngle", function(angle:Float,id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        Reflect.setProperty(character.otherCharacters[0], "angle", angle);
                        return;
                    }
                        
                }
            if(getActorByName(id) != null)
                Reflect.setProperty(getActorByName(id), "angle", angle);
        });

        Lua_helper.add_callback(lua,"setActorModAngle", function(angle:Float,id:String) {
            if(getActorByName(id) != null)
                getActorByName(id).modAngle = angle;
        });

        Lua_helper.add_callback(lua,"setActorScale", function(scale:Float,id:String) {
            if(getActorByName(id) != null)
                getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scale));
        });
        
        Lua_helper.add_callback(lua, "setActorScaleXY", function(scaleX:Float, scaleY:Float, id:String)
        {
            if(getActorByName(id) != null)
                getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scaleX), Std.int(getActorByName(id).height * scaleY));
        });

        Lua_helper.add_callback(lua,"setActorScaleX", function(id:String, scale:Float) {
            if(getActorByName(id) != null)
                getActorByName(id).scale.x = scale;
        });
        Lua_helper.add_callback(lua,"setActorScaleY", function(id:String, scale:Float) {
            if(getActorByName(id) != null)
                getActorByName(id).scale.y = scale;
        });
        Lua_helper.add_callback(lua,"getActorScaleX", function(id:String) {
            if(getActorByName(id) != null)
                return getActorByName(id).scale.x;
            return 1.0;
        });
        Lua_helper.add_callback(lua,"getActorScaleY", function(id:String) {
            if(getActorByName(id) != null)
                return getActorByName(id).scale.y;
            return 1.0;
        });

        Lua_helper.add_callback(lua, "setActorFlipX", function(flip:Bool, id:String)
        {
            if(getActorByName(id) != null)
                getActorByName(id).flipX = flip;
        });
        Lua_helper.add_callback(lua, "getActorFlipX", function(id:String)
            {
                if(getActorByName(id) != null)
                    return getActorByName(id).flipX;
                return false;
            });
        Lua_helper.add_callback(lua, "setActorFlipY", function(flip:Bool, id:String)
        {
            if(getActorByName(id) != null)
                getActorByName(id).flipY = flip;
        });

        Lua_helper.add_callback(lua,"setActorTrailVisible", function(id:String,visibleVal:Bool) {
            var char = getCharacterByName(id);

            if(char != null)
            {
                if(char.coolTrail != null)
                {
                    char.coolTrail.visible = visibleVal;
                    return true;
                }
                else
                    return false;
            }
            else
                return false;
        });

        Lua_helper.add_callback(lua,"getActorTrailVisible", function(id:String) {
            var char = getCharacterByName(id);

            if(char != null)
            {
                if(char.coolTrail != null)
                    return char.coolTrail.visible;
                else
                    return false;
            }
            else
                return false;
        });

        Lua_helper.add_callback(lua,"getActorWidth", function (id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        return character.otherCharacters[0].width;
                    }
                        
                }
            if(getActorByName(id) != null)
                return getActorByName(id).width;
            else
                return 0;
        });

        Lua_helper.add_callback(lua,"getActorHeight", function (id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        return character.otherCharacters[0].height;
                    }
                        
                }
            if(getActorByName(id) != null)
                return getActorByName(id).height;
            else
                return 0;
        });

        Lua_helper.add_callback(lua,"getActorAlpha", function(id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        return character.otherCharacters[0].alpha;
                    }
                        
                }
            if(getActorByName(id) != null)
                return getActorByName(id).alpha;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"getActorAngle", function(id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        return character.otherCharacters[0].angle;
                    }
                        
                }
            if(getActorByName(id) != null)
                return getActorByName(id).angle;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"getActorX", function (id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        return character.otherCharacters[0].x;
                    }
                        
                }
            if(getActorByName(id) != null)
                return getActorByName(id).x;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"getActorY", function (id:String) {
            if(getCharacterByName(id) != null)
                {
                    var character = getCharacterByName(id);
                    if (character.otherCharacters != null && character.otherCharacters.length > 0)
                    {
                        return character.otherCharacters[0].y;
                    }
                        
                }
            if(getActorByName(id) != null)
                return getActorByName(id).y;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"setActorReflection", function(id:String, r:Bool) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    for (i in 0...character.otherCharacters.length)
                        character.otherCharacters[i].drawReflection = r;
                    return;
                }
            }
            Reflect.setProperty(getActorByName(id), "drawReflection", r);
        });

        Lua_helper.add_callback(lua,"setActorReflectionYOffset", function(id:String, y:Float) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    Reflect.setProperty(character.otherCharacters[0], "reflectionYOffset", y);
                    return;
                }
            }
            Reflect.setProperty(getActorByName(id), "reflectionYOffset", y);
        });
        Lua_helper.add_callback(lua,"setActorReflectionAlpha", function(id:String, a:Float) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    Reflect.setProperty(character.otherCharacters[0], "reflectionAlpha", a);
                    return;
                }
            }
            Reflect.setProperty(getActorByName(id), "reflectionAlpha", a);
        });
        Lua_helper.add_callback(lua,"setActorReflectionColor", function(id:String, color:String) {
            if(getCharacterByName(id) != null)
            {
                var character = getCharacterByName(id);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    Reflect.setProperty(character.otherCharacters[0], "reflectionColor", FlxColor.fromString(color));
                    return;
                }
            }
            Reflect.setProperty(getActorByName(id), "reflectionColor", FlxColor.fromString(color));
        });

        Lua_helper.add_callback(lua,"setWindowPos",function(x:Int,y:Int) {
            Application.current.window.move(x, y);
        });

        #if !mobile
        Lua_helper.add_callback(lua,"popupWindow",function(customWidth:Int, customHeight:Int, ?customX:Int, ?customName:String) {
            var display = Application.current.window.display.currentMode;

            if(customName == '' || customName == null){
                customName = 'Opponent.json';
            }

            windowDad = Lib.application.createWindow({
                title: customName,
                width: customWidth,
                height: customHeight,
                borderless: true,
                alwaysOnTop: true
            });

            if(customX == null){
                customX = -1000;
            }

            FlxTween.tween(windowDad, { x: -50, y: 0}, 1);

            windowDad.stage.color = 0xFF010101;
            @:privateAccess
            windowDad.stage.addEventListener("keyDown", FlxG.keys.onKeyDown);
            @:privateAccess
            windowDad.stage.addEventListener("keyUp", FlxG.keys.onKeyUp);

            FlxTransWindow.getWindowsTransparent();

            var m = new Matrix();

            FlxG.mouse.useSystemCursor = true;

            Application.current.window.onClose.add(function()
                {
                    if (windowDad != null)
                    {
                        windowDad.close();
                    }
                }, false, 100);	

            //dadWin.graphics.beginBitmapFill(dad.pixels, m);
            //dadWin.graphics.drawRect(0, 0, dad.pixels.width, dad.pixels.height);
            //dadWin.graphics.endFill();
            dadScrollWin.scrollRect = new Rectangle();

            //windowDad.stage.addChild(dadScrollWin);
            //dadScrollWin.addChild(dadWin);
            dadScrollWin.scaleX = 0.7;
            dadScrollWin.scaleY = 0.7;
            
            Application.current.window.focus();
            FlxG.autoPause = false;
        });
        #end

        Lua_helper.add_callback(lua,"getWindowX",function() {
            return Application.current.window.x;
        });

        Lua_helper.add_callback(lua,"getWindowY",function() {
            return Application.current.window.y;
        });

        Lua_helper.add_callback(lua,"getCenteredWindowX",function() {
            return (Application.current.window.display.currentMode.width / 2) - (Application.current.window.width / 2);
        });

        Lua_helper.add_callback(lua,"getCenteredWindowY",function() {
            return (Application.current.window.display.currentMode.height / 2) - (Application.current.window.height / 2);
        });

        Lua_helper.add_callback(lua,"resizeWindow",function(Width:Int,Height:Int) {
            Application.current.window.resize(Width,Height);
        });
        
        Lua_helper.add_callback(lua,"getScreenWidth",function() {
            return Application.current.window.display.currentMode.width;
        });

        Lua_helper.add_callback(lua,"getScreenHeight",function() {
            return Application.current.window.display.currentMode.height;
        });

        Lua_helper.add_callback(lua,"getWindowWidth",function() {
            return Application.current.window.width;
        });

        Lua_helper.add_callback(lua,"getWindowHeight",function() {
            return Application.current.window.height;
        });

        Lua_helper.add_callback(lua,"setCanFullscreen",function(can_Fullscreen:Bool) {
            PlayState.instance.canFullscreen = can_Fullscreen;
        });

        Lua_helper.add_callback(lua,"changeDadCharacter", function (character:String) {
            var oldDad = PlayState.dad;
            PlayState.instance.removeObject(oldDad);
            
            var dad = new Character(100, 100, character);
            PlayState.dad = dad;

            if(dad.otherCharacters == null)
            {
                if(dad.coolTrail != null)
                    PlayState.instance.add(dad.coolTrail);
    
                PlayState.instance.add(dad);
            }
            else
            {
                for(character in dad.otherCharacters)
                {
                    if(character.coolTrail != null)
                        PlayState.instance.add(character.coolTrail);
    
                    PlayState.instance.add(character);
                }
            }

            lua_Sprites.remove("dad");

            oldDad.kill();
            oldDad.destroy();

            lua_Sprites.set("dad", dad);

            //just use the event lol
           /* @:privateAccess
            {
                var oldIcon = PlayState.instance.iconP2;
                var bar = PlayState.instance.healthBar;
                
                PlayState.instance.removeObject(oldIcon);
                oldIcon.kill();
                oldIcon.destroy();

                PlayState.instance.iconP2 = new HealthIcon(dad.icon, false);
                PlayState.instance.iconP2.y = PlayState.instance.healthBar.y - (PlayState.instance.iconP2.height / 2);
                PlayState.instance.iconP2.cameras = [PlayState.instance.camHUD];
                PlayState.instance.add(PlayState.instance.iconP2);

                bar.createFilledBar(dad.barColor, PlayState.boyfriend.barColor);
                bar.updateFilledBar();

                PlayState.instance.stage.setCharOffsets();
            }*/
        });

        Lua_helper.add_callback(lua,"changeBoyfriendCharacter", function (character:String) {
            var oldBF = PlayState.boyfriend;
            PlayState.instance.removeObject(oldBF);
            
            var boyfriend = new Boyfriend(770, 450, character);
            PlayState.boyfriend = boyfriend;

            if(boyfriend.otherCharacters == null)
            {
                if(boyfriend.coolTrail != null)
                    PlayState.instance.add(boyfriend.coolTrail);
    
                PlayState.instance.add(boyfriend);
            }
            else
            {
                for(character in boyfriend.otherCharacters)
                {
                    if(character.coolTrail != null)
                        PlayState.instance.add(character.coolTrail);
    
                    PlayState.instance.add(character);
                }
            }

            lua_Sprites.remove("boyfriend");

            oldBF.kill();
            oldBF.destroy();

            lua_Sprites.set("boyfriend", boyfriend);

           /* @:privateAccess
            {
                var oldIcon = PlayState.instance.iconP1;
                var bar = PlayState.instance.healthBar;
                
                PlayState.instance.removeObject(oldIcon);
                oldIcon.kill();
                oldIcon.destroy();

                PlayState.instance.iconP1 = new HealthIcon(boyfriend.icon, false);
                PlayState.instance.iconP1.y = PlayState.instance.healthBar.y - (PlayState.instance.iconP1.height / 2);
                PlayState.instance.iconP1.cameras = [PlayState.instance.camHUD];
                PlayState.instance.iconP1.flipX = true;
                PlayState.instance.add(PlayState.instance.iconP1);

                bar.createFilledBar(PlayState.dad.barColor, boyfriend.barColor);
                bar.updateFilledBar();

                PlayState.instance.stage.setCharOffsets();
            }*/
        });

        // scroll speed

        var original_Scroll_Speed = PlayState.SONG.speed;

        Lua_helper.add_callback(lua,"getBaseScrollSpeed",function() {
            return original_Scroll_Speed;
        });

        Lua_helper.add_callback(lua,"getScrollSpeed",function() {
            return PlayState.SONG.speed;
        });

        Lua_helper.add_callback(lua,"setScrollSpeed",function(speed:Float) {
            PlayState.SONG.speed = speed;
        });

        // sounds

        Lua_helper.add_callback(lua, "createSound", function(id:String, file_Path:String, library:String, ?looped:Bool = false) {
            if(lua_Sounds.get(id) == null)
            {
                lua_Sounds.set(id, new FlxSound().loadEmbedded(Paths.sound(file_Path, library), looped));

                FlxG.sound.list.add(lua_Sounds.get(id));
            }
            else
                trace("Error! Sound " + id + " already exists! Try another sound name!");
        });

        Lua_helper.add_callback(lua, "removeSound",function(id:String) {
            if(lua_Sounds.get(id) != null)
            {
                var sound = lua_Sounds.get(id);
                sound.stop();
                sound.kill();
                sound.destroy();

                lua_Sounds.set(id, null);
            }
        });

        Lua_helper.add_callback(lua, "playSound",function(id:String, ?forceRestart:Bool = false) {
            if(lua_Sounds.get(id) != null)
                lua_Sounds.get(id).play(forceRestart);
        });

        Lua_helper.add_callback(lua, "stopSound",function(id:String) {
            if(lua_Sounds.get(id) != null)
                lua_Sounds.get(id).stop();
        });

        Lua_helper.add_callback(lua,"setSoundVolume", function(id:String, volume:Float) {
            if(lua_Sounds.get(id) != null)
                lua_Sounds.get(id).volume = volume;
        });

        Lua_helper.add_callback(lua,"getSoundTime", function(id:String) {
            if(lua_Sounds.get(id) != null)
                return lua_Sounds.get(id).time;

            return 0;
        });

        // tweens
        
        Lua_helper.add_callback(lua,"tweenCameraPos", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenCameraAngle", function(toAngle:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraZoom", function(toZoom:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance, {defaultCamZoom:toZoom}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudPos", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenHudAngle", function(toAngle:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudZoom", function(toZoom:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance, {defaultHudCamZoom:toZoom}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPos", function(id:String, toX:Int, toY:Int, time:Float, ?onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.quintInOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenCameraAngleOut", function(toAngle:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraZoomOut", function(toZoom:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance, {defaultCamZoom:toZoom}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenHudAngleOut", function(toAngle:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudZoomOut", function(toZoom:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance, {defaultHudCamZoom:toZoom}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosOut", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosXAngleOut", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosYAngleOut", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenAngleOut", function(id:String, toAngle:Int, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenCameraAngleIn", function(toAngle:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraZoomIn", function(toZoom:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance, {defaultCamZoom:toZoom}, time, {ease: FlxEase.quintInOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenHudAngleIn", function(toAngle:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance.camHUD, {angle:toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudZoomIn", function(toZoom:Float, time:Float, onComplete:String = "") {
            PlayState.instance.tweenManager.tween(PlayState.instance, {defaultHudCamZoom:toZoom}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosIn", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosXAngleIn", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosYAngleIn", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenAngleIn", function(id:String, toAngle:Int, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenFadeIn", function(id:String, toAlpha:Float, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenFadeOut", function(id:String, toAlpha:Float, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenFadeCubeInOut", function(id:String, toAlpha:Float, time:Float, onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.cubeInOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenActorColor", function(id:String, r1:Int, g1:Int, b1:Int, r2:Int, g2:Int, b2:Int, time:Float, onComplete:String = "") {
            var actor = getActorByName(id);

            if(getActorByName(id) != null)
            {
                FlxTween.color(
                    actor,
                    time,
                    FlxColor.fromRGB(r1, g1, b1, 255),
                    FlxColor.fromRGB(r2, g2, b2, 255),
                    {
                        ease: FlxEase.circIn,
                        onComplete: function(flxTween:FlxTween) {
                            if (onComplete != '' && onComplete != null)
                            {
                                executeState(onComplete,[id]);
                            }
                        }
                    }
                );
            }
        });

        Lua_helper.add_callback(lua,"tweenScaleX", function(id:String, toAlpha:Float, time:Float, easeStr:String = "", onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id).scale, {x: toAlpha}, time, {ease: getEase(easeStr), onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });
        Lua_helper.add_callback(lua,"tweenScaleY", function(id:String, toAlpha:Float, time:Float, easeStr:String = "", onComplete:String = "") {
            if(getActorByName(id) != null)
                PlayState.instance.tweenManager.tween(getActorByName(id).scale, {y: toAlpha}, time, {ease: getEase(easeStr), onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {executeState(onComplete,[id]);}}});
        });

        // properties

        Lua_helper.add_callback(lua,"setProperty", function(object:String, property:String, value:Dynamic) {

            if (propBlackList.contains(property))
            {
                Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "stop cheating lol"));
                return;
            }

            if(object != "")
            {
                @:privateAccess
                if(Reflect.getProperty(PlayState.instance, object) != null)
                    Reflect.setProperty(Reflect.getProperty(PlayState.instance, object), property, value);
                else
                    Reflect.setProperty(Reflect.getProperty(PlayState, object), property, value);
            }
            else
            {
                @:privateAccess
                if(Reflect.getProperty(PlayState.instance, property) != null)
                    Reflect.setProperty(PlayState.instance, property, value);
                else
                    Reflect.setProperty(PlayState, property, value);
            }
        });

        Lua_helper.add_callback(lua,"getProperty", function(object:String, property:String) {
            if(object != "")
            {
                @:privateAccess
                if(Reflect.getProperty(PlayState.instance, object) != null)
                    return Reflect.getProperty(Reflect.getProperty(PlayState.instance, object), property);
                else
                    return Reflect.getProperty(Reflect.getProperty(PlayState, object), property);
            }
            else
            {
                @:privateAccess
                if(Reflect.getProperty(PlayState.instance, property) != null)
                    return Reflect.getProperty(PlayState.instance, property);
                else
                    return Reflect.getProperty(PlayState, property);
            }
        });

        Lua_helper.add_callback(lua, "getPropertyFromClass", function(className:String, variable:String) {

            if (propBlackList.contains(variable) || classBlackList.contains(className))
            {
                Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "stop lol"));
                return null;
            }
            @:privateAccess
            {
                var variablePaths = variable.split(".");

                if(variablePaths.length > 1)
                {
                    var selectedVariable:Dynamic = Reflect.getProperty(Type.resolveClass(className), variablePaths[0]);

                    for (i in 1...variablePaths.length-1)
                    {
                        selectedVariable = Reflect.getProperty(selectedVariable, variablePaths[i]);
                    }

                    return Reflect.getProperty(selectedVariable, variablePaths[variablePaths.length - 1]);
                }

                return Reflect.getProperty(Type.resolveClass(className), variable);
            }
		});

		Lua_helper.add_callback(lua, "setPropertyFromClass", function(className:String, variable:String, value:Dynamic) {
            if (propBlackList.contains(variable) || classBlackList.contains(className))
                {
                    Main.popupManager.addPopup(new MessagePopup(5, 300, 50, "stop lol"));
                    return null;
                }

            @:privateAccess
            {
                var variablePaths:Array<String> = variable.split('.');

                if(variablePaths.length > 1)
                {
                    var selectedVariable:Dynamic = Reflect.getProperty(Type.resolveClass(className), variablePaths[0]);

                    for (i in 1...variablePaths.length-1)
                    {
                        selectedVariable = Reflect.getProperty(selectedVariable, variablePaths[i]);
                    }

                    return Reflect.setProperty(selectedVariable, variablePaths[variablePaths.length - 1], value);
                }

                return Reflect.setProperty(Type.resolveClass(className), variable, value);
            }
		});

        // song stuff

        Lua_helper.add_callback(lua,"setSongPosition", function(position:Float) {
            @:privateAccess
            PlayState.instance.isCheating = true;
            Conductor.songPosition = position;
            setVar('songPos', Conductor.songPosition);
            var i:Int = PlayState.instance.unspawnNotes.length - 1;
            while (i >= 0) {
                var daNote:Note = PlayState.instance.unspawnNotes[i];
                if(daNote.strumTime+350 < position)
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
                if(daNote.strumTime+350 < position)
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
        });

        Lua_helper.add_callback(lua,"stopSong", function() {
            if (PlayState.instance.playingFDGOD)
                {
                    trace('fd god run is no longer valid');
                    @:privateAccess
                    PlayState.instance.isCheating = true;
                }
            @:privateAccess
            {
                PlayState.instance.paused = true;

                FlxG.sound.music.volume = 0;
                PlayState.instance.vocals.volume = 0;
    
                PlayState.instance.notes.clear();
                PlayState.instance.remove(PlayState.instance.notes);

                FlxG.sound.music.time = 0;
                PlayState.instance.vocals.time = 0;
    
                Conductor.songPosition = 0;
                PlayState.songMultiplier = 0;

                Conductor.recalculateStuff(PlayState.songMultiplier);

                #if cpp
                lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, PlayState.songMultiplier);

                if(PlayState.instance.vocals.playing)
                    lime.media.openal.AL.sourcef(PlayState.instance.vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, PlayState.songMultiplier);
                #end

                PlayState.instance.stopSong = true;
            }

            return true;
        });

        Lua_helper.add_callback(lua,"endSong", function() {
            @:privateAccess
            {
                PlayState.instance.isCheating = true;
                FlxG.sound.music.time = FlxG.sound.music.length;
                PlayState.instance.vocals.time = FlxG.sound.music.length;

                PlayState.instance.health = 500000;
                PlayState.instance.invincible = true;

                PlayState.instance.stopSong = false;

                PlayState.instance.resyncVocals();
            }

            return true;
        });

        Lua_helper.add_callback(lua,"getCharFromEvent", function(eventId:String) {
            switch(eventId.toLowerCase())
            {
                case "girlfriend" | "gf" | "player3" | "2":
                    return "girlfriend";
                case "dad" | "opponent" | "player2" | "1":
                    return "dad";
                case "bf" | "boyfriend" | "player" | "player1" | "0":
                    return "boyfriend";
            }
    
            return eventId;
        });

        // shader bullshit

        Lua_helper.add_callback(lua,"setActor3DShader", function(id:String, ?speed:Float = 3, ?frequency:Float = 10, ?amplitude:Float = 0.25) {
            var actor = getActorByName(id);

            if(actor != null)
            {
                var funnyShader:shaders.Shaders.ThreeDEffect = shaders.Shaders.newEffect("3d");
                funnyShader.waveSpeed = speed;
                funnyShader.waveFrequency = frequency;
                funnyShader.waveAmplitude = amplitude;
                lua_Shaders.set(id, funnyShader);
                
                actor.shader = funnyShader.shader;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorNoShader", function(id:String) {
            var actor = getActorByName(id);

            if(actor != null)
            {
                lua_Shaders.remove(id);
                actor.shader = null;
            }
        });

        Lua_helper.add_callback(lua,"initShader", function(name:String, classString:String) {

            if (!utilities.Options.getData("shaders"))
                return;

            #if mobile
            //Application.current.window.alert("loading shader: "+classString,"Leather Engine Modcharts");
            if (mobileShaderBlacklist.contains(classString))
                return;
            #end

            var shaderClass = Type.resolveClass('shaders.'+classString);
            if (shaderClass != null)
            {
                var shad = Type.createInstance(shaderClass, []);
                lua_Shaders.set(name, shad);
                trace('created shader: '+name);
            }
            else 
            {
                Application.current.window.alert("shader brokey\n"+classString+" doesnt exist lol","Leather Engine Modcharts");
            }
        });
        Lua_helper.add_callback(lua,"setActorShader", function(actorStr:String, shaderName:String) {
            if (!utilities.Options.getData("shaders"))
                return;

            var shad = lua_Shaders.get(shaderName);
            if(getCharacterByName(actorStr) != null)
            {
                var character = getCharacterByName(actorStr);
                if (character.otherCharacters != null && character.otherCharacters.length > 0)
                {
                    for (c in 0...character.otherCharacters.length)
                    {
                        character.otherCharacters[c].shader = Reflect.getProperty(shad, 'shader');
                    }
                    return;
                }                    
            }
            var actor = getActorByName(actorStr);
            

            if(actor != null && shad != null)
            {
                actor.shader = Reflect.getProperty(shad, 'shader'); //use reflect to workaround compiler errors

                //trace('added shader '+shaderName+" to " + actorStr);

            }
        });

        Lua_helper.add_callback(lua,"setShaderProperty", function(shaderName:String, prop:String, value:Dynamic) {
            if (!utilities.Options.getData("shaders"))
                return;
            var shad = lua_Shaders.get(shaderName);

            if(shad != null)
            {
                Reflect.setProperty(shad, prop, value);
                //trace('set shader prop');
            }
        });

        Lua_helper.add_callback(lua,"tweenShaderProperty", function(shaderName:String, prop:String, value:Dynamic, time:Float, easeStr:String = "linear") {
            if (!utilities.Options.getData("shaders"))
                return;
            var shad = lua_Shaders.get(shaderName);
            var ease = getEase(easeStr);        

            if(shad != null)
            {
                var startVal = Reflect.getProperty(shad, prop);

                PlayState.instance.tweenManager.num(startVal, value, time, {onUpdate: function(tween:FlxTween){
					var ting = FlxMath.lerp(startVal,value, ease(tween.percent));
                    Reflect.setProperty(shad, prop, ting);
				}, ease: ease, onComplete: function(tween:FlxTween) {
					Reflect.setProperty(shad, prop, value);
				}});
                //trace('set shader prop');
            }
        });

        Lua_helper.add_callback(lua,"tweenActorProperty", function(id:String, prop:String, value:Dynamic, time:Float, easeStr:String = "linear") {
            var actor = getActorByName(id);
            var ease = getEase(easeStr);

            if(actor != null && Reflect.getProperty(actor, prop) != null)
            {
                var startVal = Reflect.getProperty(actor, prop);

                PlayState.instance.tweenManager.num(startVal, value, time, {onUpdate: function(tween:FlxTween){
					var ting = FlxMath.lerp(startVal,value, ease(tween.percent));
                    Reflect.setProperty(actor, prop, ting);
				}, ease: ease, onComplete: function(tween:FlxTween) {
					Reflect.setProperty(actor, prop, value);
				}});
            }
        });

        Lua_helper.add_callback(lua,"setActorProperty", function(id:String, prop:String, value:Dynamic) {
            var actor = getActorByName(id);
            if(actor != null && Reflect.getProperty(actor, prop) != null)
            {
                Reflect.setProperty(actor, prop, value);
            }
        });

        Lua_helper.add_callback(lua,"tweenStageColorSwap", function(prop:String, value:Dynamic, time:Float, easeStr:String = "linear") {
            @:privateAccess
            var actor = PlayState.instance.stage.colorSwap;
            var ease = getEase(easeStr);

            if(actor != null)
            {
                var startVal = Reflect.getProperty(actor, prop);

                PlayState.instance.tweenManager.num(startVal, value, time, {onUpdate: function(tween:FlxTween){
					var ting = FlxMath.lerp(startVal,value, ease(tween.percent));
                    Reflect.setProperty(actor, prop, ting);
				}, ease: ease, onComplete: function(tween:FlxTween) {
					Reflect.setProperty(actor, prop, value);
				}});
            }
        });

        
        Lua_helper.add_callback(lua,"setStageColorSwap", function(prop:String, value:Dynamic) {
            @:privateAccess
            var actor = PlayState.instance.stage.colorSwap;

            if(actor != null)
            {
                Reflect.setProperty(actor, prop, value);
            }
        });

        Lua_helper.add_callback(lua,"getStrumTimeFromStep", function(step:Float) {
            var beat = step*0.25;
            var totalTime:Float = 0;
            var curBpm = Conductor.bpm;
            if (PlayState.SONG != null)
                curBpm = PlayState.SONG.bpm;
            for (i in 0...Math.floor(beat))
            {
                if (Conductor.bpmChangeMap.length > 0)
                {
                    for (j in 0...Conductor.bpmChangeMap.length)
                    {
                        if (totalTime >= Conductor.bpmChangeMap[j].songTime)
                            curBpm = Conductor.bpmChangeMap[j].bpm;
                    }
                }
                totalTime += (60/curBpm)*1000;
            }

            var leftOverBeat = beat - Math.floor(beat);
            totalTime += (60/curBpm)*1000*leftOverBeat;

            return totalTime;
        });

        Lua_helper.add_callback(lua,"setCameraShader", function(camStr:String, shaderName:String) {
            if (!utilities.Options.getData("shaders"))
                return;
            var cam = getCameraByName(camStr);
            var shad = lua_Shaders.get(shaderName);

            if(cam != null && shad != null)
            {
                cam.shaders.push(new ShaderFilter(Reflect.getProperty(shad, 'shader'))); //use reflect to workaround compiler errors
                cam.shaderNames.push(shaderName);
                cam.cam.setFilters(cam.shaders);
                //trace('added shader '+shaderName+" to " + camStr);
            }
        });
        Lua_helper.add_callback(lua,"removeCameraShader", function(camStr:String, shaderName:String) {
            if (!utilities.Options.getData("shaders"))
                return;
            var cam = getCameraByName(camStr);
            if (cam != null)
            {
                if (cam.shaderNames.contains(shaderName))
                {
                    var idx:Int = cam.shaderNames.indexOf(shaderName);
                    if (idx != -1)
                    {
                        cam.shaderNames.remove(cam.shaderNames[idx]);
                        cam.shaders.remove(cam.shaders[idx]);
                        cam.cam.setFilters(cam.shaders); //refresh filters
                    }
                    
                }
            }
        });
        Lua_helper.add_callback(lua,"makeCamera", function(camStr:String) {
            var newCam:FlxCamera = new FlxCamera();
            newCam.bgColor.alpha = 0;
            PlayState.instance.reorderCameras(newCam);
            lua_Cameras.set(camStr, {cam: newCam, shaders: [], shaderNames: []});
            PlayState.instance.usedLuaCameras = true;
        });

        Lua_helper.add_callback(lua,"setNoteCameras", function(camStr:String) {
            var cameras = camStr.split(',');
            var camList:Array<FlxCamera> = [];
            for (c in cameras)
            {
                var cam = getCameraByName(c);
                if (cam != null)
                    camList.push(cam.cam);
            }
            if (camList.length > 0)
            {
                
                PlayState.strumLineNotes.cameras = camList;
                PlayState.instance.notes.cameras = camList;
            }
        });

        Lua_helper.add_callback(lua,"setObjectCameras", function(id:String, camStr:String) {
            var cameras = camStr.split(',');
            var actor:FlxSprite = getActorByName(id);
            var camList:Array<FlxCamera> = [];
            for (c in cameras)
            {
                var cam = getCameraByName(c);
                if (cam != null)
                    camList.push(cam.cam);
            }
            if (camList.length > 0)
            {
                if(actor != null)
                    Reflect.setProperty(actor, "cameras", camList);
            }
        });

        Lua_helper.add_callback(lua,"getCameraScrollX", function(camStr:String) {
            var cam = getCameraByName(camStr);
            if(cam != null)
            {
                return cam.cam.scroll.x;
            }
            return 0.0;
        });
        Lua_helper.add_callback(lua,"getCameraScrollY", function(camStr:String) {
            var cam = getCameraByName(camStr);
            if(cam != null)
            {
                return cam.cam.scroll.y;
            }
            return 0.0;
        });

        #if !mobile
        Lua_helper.add_callback(lua,"setupTransparentWindow", function() {
            FlxTransWindow.setupTransparentWindow();
        });
        Lua_helper.add_callback(lua,"restoreWindow", function() {
            FlxTransWindow.restoreWindow();
        });
        #end

        Lua_helper.add_callback(lua,"updateRating", function() {
            PlayState.instance.updateRating();
        });


        executeState("onCreate", []);
        executeState("createLua", []);
    }

    public function setupTheShitCuzPullRequestsSuck()
        {
            lua_Sounds.set("Inst", FlxG.sound.music);
            @:privateAccess
            lua_Sounds.set("Voices", PlayState.instance.vocals);
    
            @:privateAccess
            for(object in PlayState.instance.stage.stage_Objects)
            {
                lua_Sprites.set(object[0], object[1]);
            }
    
            if(PlayState.dad.otherCharacters != null)
            {
                lua_Sprites.set('dad', PlayState.dad.otherCharacters[0]);
                lua_Characters.set('dad', PlayState.dad.otherCharacters[0]);
                for(char in 0...PlayState.dad.otherCharacters.length)
                {
                    lua_Sprites.set("dadCharacter" + char, PlayState.dad.otherCharacters[char]);
                    lua_Characters.set("dadCharacter" + char, PlayState.dad.otherCharacters[char]);
                }
            }
            //else 
           // {
                lua_Sprites.set("boyfriend", PlayState.boyfriend);
                lua_Characters.set("boyfriend", PlayState.boyfriend);
            //}
    
            if(PlayState.boyfriend.otherCharacters != null)
            {
                //lua_Sprites.set('boyfriend', PlayState.boyfriend.otherCharacters[0]);
                //lua_Characters.set('boyfriend', PlayState.boyfriend.otherCharacters[0]);
                for(char in 0...PlayState.boyfriend.otherCharacters.length)
                {
                    lua_Sprites.set("bfCharacter" + char, PlayState.boyfriend.otherCharacters[char]);
                    lua_Characters.set("bfCharacter" + char, PlayState.boyfriend.otherCharacters[char]);
                }
            }
           // else 
            //{   
                lua_Sprites.set("dad", PlayState.dad);
                lua_Characters.set("dad", PlayState.dad);
            //}
    
            if(PlayState.gf.otherCharacters != null)
            {
               // lua_Sprites.set('girlfriend', PlayState.gf.otherCharacters[0]);
                //lua_Characters.set('girlfriend', PlayState.gf.otherCharacters[0]);
                for(char in 0...PlayState.gf.otherCharacters.length)
                {
                    lua_Sprites.set("gfCharacter" + char, PlayState.gf.otherCharacters[char]);
                    lua_Characters.set("gfCharacter" + char, PlayState.gf.otherCharacters[char]);
                }
            }
            //else 
            //{
                lua_Sprites.set("girlfriend", PlayState.gf);
                lua_Characters.set("girlfriend", PlayState.gf);
            //}

            lua_Sprites.set("iconP1", PlayState.instance.gameHUD.iconP1);
            lua_Sprites.set("iconP2", PlayState.instance.gameHUD.iconP2);

            setVar("player1", PlayState.boyfriend.curCharacter);
            setVar("player2", PlayState.dad.curCharacter);
        }

    private function convert(v : Any, type : String) : Dynamic { // I didn't write this lol
        if(Std.isOfType(v, String) && type != null ) {
            var v : String = v;

            if( type.substr(0, 4) == 'array' )
            {
                if( type.substr(4) == 'float' ) {
                    var array : Array<String> = v.split(',');
                    var array2 : Array<Float> = new Array();

                    for( vars in array ) {
                        array2.push(Std.parseFloat(vars));
                    }

                    return array2;
                    }
                    else if( type.substr(4) == 'int' ) {
                    var array : Array<String> = v.split(',');
                    var array2 : Array<Int> = new Array();

                    for( vars in array ) {
                        array2.push(Std.parseInt(vars));
                    }

                    return array2;
                    } 
                    else {
                    var array : Array<String> = v.split(',');

                    return array;
                }
            } else if( type == 'float' ) {
                return Std.parseFloat(v);
            } else if( type == 'int' ) {
                return Std.parseInt(v);
            } else if( type == 'bool' ) {
                if( v == 'true' ) {
                return true;
                } else {
                return false;
                }
            } else {
                return v;
            }
            } else {
            return v;
        }
    }

    public function getVar(var_name : String, type : String) : Dynamic {
		var result:Any = null;

		Lua.getglobal(lua, var_name);
		result = Convert.fromLua(lua,-1);
		Lua.pop(lua, 1);

		if (result == null)
		    return null;
		else
        {
		    var new_result = convert(result, type);
		    return new_result;
		}
	}

    public function executeState(name,args:Array<Dynamic>)
    {
        return Lua.tostring(lua, callLua(name, args));
    }

    public static function createModchartUtilities(?path:Null<String>):ModchartUtilities
    {
        
        return new ModchartUtilities(path);
    }

    function cameraFromString(cam:String):FlxCamera
    {
        var camera:LuaCamera = getCameraByName(cam);
        if (camera == null)
        {
            switch(cam.toLowerCase())
            {
                case 'camhud' | 'hud': return PlayState.instance.camHUD;
            }
            return PlayState.instance.camGame;
        }
        return camera.cam;
	}

    function blendModeFromString(blend:String):BlendMode
    {
		switch(blend.toLowerCase().trim())
        {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}

		return NORMAL;
	}

    public static function getEase(ease:String = '')
        {
            switch (ease.toLowerCase())
            {
                case 'backin': 
                    return FlxEase.backIn;
                case 'backinout': 
                    return FlxEase.backInOut;
                case 'backout': 
                    return FlxEase.backOut;
                case 'bouncein': 
                    return FlxEase.bounceIn;
                case 'bounceinout': 
                    return FlxEase.bounceInOut;
                case 'bounceout': 
                    return FlxEase.bounceOut;
                case 'circin': 
                    return FlxEase.circIn;
                case 'circinout':
                    return FlxEase.circInOut;
                case 'circout': 
                    return FlxEase.circOut;
                case 'cubein': 
                    return FlxEase.cubeIn;
                case 'cubeinout': 
                    return FlxEase.cubeInOut;
                case 'cubeout': 
                    return FlxEase.cubeOut;
                case 'elasticin': 
                    return FlxEase.elasticIn;
                case 'elasticinout': 
                    return FlxEase.elasticInOut;
                case 'elasticout': 
                    return FlxEase.elasticOut;
                case 'expoin': 
                    return FlxEase.expoIn;
                case 'expoinout': 
                    return FlxEase.expoInOut;
                case 'expoout': 
                    return FlxEase.expoOut;
                case 'quadin': 
                    return FlxEase.quadIn;
                case 'quadinout': 
                    return FlxEase.quadInOut;
                case 'quadout': 
                    return FlxEase.quadOut;
                case 'quartin': 
                    return FlxEase.quartIn;
                case 'quartinout': 
                    return FlxEase.quartInOut;
                case 'quartout': 
                    return FlxEase.quartOut;
                case 'quintin': 
                    return FlxEase.quintIn;
                case 'quintinout': 
                    return FlxEase.quintInOut;
                case 'quintout': 
                    return FlxEase.quintOut;
                case 'sinein': 
                    return FlxEase.sineIn;
                case 'sineinout': 
                    return FlxEase.sineInOut;
                case 'sineout': 
                    return FlxEase.sineOut;
                case 'smoothstepin': 
                    return FlxEase.smoothStepIn;
                case 'smoothstepinout': 
                    return FlxEase.smoothStepInOut;
                case 'smoothstepout': 
                    return FlxEase.smoothStepInOut;
                case 'smootherstepin': 
                    return FlxEase.smootherStepIn;
                case 'smootherstepinout': 
                    return FlxEase.smootherStepInOut;
                case 'smootherstepout': 
                    return FlxEase.smootherStepOut;
                default: 
                    return FlxEase.linear;
            }
        }
}
#end

class FlxTextFix extends FlxText
{
	override function regenGraphic()
	{
		if (textField == null || !_regen)
			return;

		var oldWidth:Int = FlxText.VERTICAL_GUTTER;
		var oldHeight:Int = FlxText.VERTICAL_GUTTER;

		if (graphic != null)
		{
			oldWidth = graphic.width;
			oldHeight = graphic.height;
		}

		var newWidth:Int = Math.ceil(textField.width) + FlxText.VERTICAL_GUTTER*2;
		// Account for gutter
		var newHeight:Int = Math.ceil(textField.textHeight) + FlxText.VERTICAL_GUTTER;

        newWidth += Math.ceil(borderSize*2);

		// prevent text height from shrinking on flash if text == ""
		if (textField.textHeight == 0)
		{
			newHeight = oldHeight;
		}

		if (oldWidth != newWidth || oldHeight != newHeight)
		{
			// Need to generate a new buffer to store the text graphic
			height = newHeight;
			var key:String = flixel.FlxG.bitmap.getUniqueKey("text");
			makeGraphic(newWidth, newHeight, FlxColor.TRANSPARENT, false, key);

			if (_hasBorderAlpha)
				_borderPixels = graphic.bitmap.clone();
            frameWidth = newWidth;
			frameHeight = newHeight;
			textField.width = width * 1.5;
			textField.height = height * 1.2;
			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = newWidth;
			_flashRect.height = newHeight;
		}
		else // Else just clear the old buffer before redrawing the text
		{
			graphic.bitmap.fillRect(_flashRect, FlxColor.TRANSPARENT);
			if (_hasBorderAlpha)
			{
				if (_borderPixels == null)
					_borderPixels = new BitmapData(frameWidth, frameHeight, true);
				else
					_borderPixels.fillRect(_flashRect, FlxColor.TRANSPARENT);
			}
		}

		if (textField != null && textField.text != null && textField.text.length > 0)
		{
			// Now that we've cleared a buffer, we need to actually render the text to it
			copyTextFormat(_defaultFormat, _formatAdjusted);

			_matrix.identity();
			
			_matrix.translate(borderSize*3, borderSize*2);
			applyBorderStyle();
			applyBorderTransparency();
			applyFormats(_formatAdjusted, false);

			
			drawTextFieldTo(graphic.bitmap);
		}

		_regen = false;
		resetFrame();
	}
}


