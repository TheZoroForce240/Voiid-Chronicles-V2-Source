package game;

import flixel.math.FlxMath;
import utilities.CoolUtil;
import flixel.FlxG;
import flixel.graphics.frames.FlxFramesCollection;
import utilities.NoteVariables;
import shaders.ColorSwap;
import shaders.NoteColors;
import states.PlayState;
import flixel.FlxSprite;
import lime.utils.Assets;
using StringTools;

/*
credit to psych engine devs (sorry idk who made this originally, all ik is that srperez modified it for shaggy and then i got it from there)
*/
class StrumNote extends FlxSprite
{
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;

	public var swagWidth:Float = 0;

	public var keyCount:Int;

	public var modAngle:Float = 0;

	public var colorSwap:ColorSwap;

	var noteColor:Array<Int> = [0,0,0];

	public var isPlayer:Bool = false;

	public var strumlineY:Float = 0;

	public var uiSkin:UISkin;

	public function new(x:Float, y:Float, leData:Int, ?uiSkin:UISkin, ?keyCount:Int, ?isPlayer:Bool = false) {
		
		if(keyCount == null)
			keyCount = PlayState.SONG.keyCount;

		this.keyCount = keyCount;

		noteData = leData;

		this.uiSkin = uiSkin;

		super(x, y);
		strumlineY = y;
		this.isPlayer = isPlayer;

		noteColor = NoteColors.getNoteColor(NoteVariables.Other_Note_Anim_Stuff[keyCount - 1][noteData]);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		colorSwap.hue = noteColor[0] / 360;
		colorSwap.saturation = noteColor[1] / 100;
		colorSwap.brightness = noteColor[2] / 100;
	}

	public var doLerp:Bool = false;
	public var lerpX:Float = 0;
	public var lerpY:Float = 0;

	override function update(elapsed:Float) {
		angle = modAngle;
		
		if(resetAnim > 0) {
			resetAnim -= elapsed;

			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		if (doLerp)
		{
			x = FlxMath.lerp(x, lerpX, elapsed*(5+noteData));
			y = FlxMath.lerp(y, lerpY, elapsed*(5+noteData));
		}

		super.update(elapsed);
	}

	public function changeUISkin(uiSkin:UISkin)
	{
		this.uiSkin = uiSkin;
		loadStrum();
	}

	public function loadStrum()
	{
		var i:Int = noteData;
		frames = uiSkin.arrow_Type_Sprites.get("default");
		antialiasing = uiSkin.ui_Settings.get("aa") == "true";

		var playerManiaOffset:Int = 0;
		if (PlayState.instance != null)
			playerManiaOffset = PlayState.instance.playerManiaOffset;

		setGraphicSize(Std.int((width * Std.parseFloat(uiSkin.ui_Settings.get("globalScale"))) * (Std.parseFloat(uiSkin.ui_Settings.get("noteScale")) - (Std.parseFloat(uiSkin.mania_size[keyCount-1- (isPlayer ? playerManiaOffset : 0)])))));
		updateHitbox();
		
		var animation_Base_Name = NoteVariables.Note_Count_Directions[keyCount - 1][Std.int(Math.abs(i))].toLowerCase();

		animation.addByPrefix('static', animation_Base_Name + " static");
		animation.addByPrefix('pressed', NoteVariables.Other_Note_Anim_Stuff[keyCount - 1][i] + ' press', 24, false);
		animation.addByPrefix('confirm', NoteVariables.Other_Note_Anim_Stuff[keyCount - 1][i] + ' confirm', 24, false);

		scrollFactor.set();
		
		playAnim('static');
		ID = i;
	}

	public function setupStrumPosition(player:Float = 0)
	{
		var i:Int = noteData;
		var playerManiaOffset:Int = 0;
		if (PlayState.instance != null)
			playerManiaOffset = PlayState.instance.playerManiaOffset;

		x = 0;
		x += (width + (2 + Std.parseFloat(uiSkin.mania_gap[keyCount - 1 - (isPlayer ? playerManiaOffset : 0)]))) * Math.abs((isPlayer && i > Math.floor(keyCount/2) ? i-playerManiaOffset : i)) + Std.parseFloat(uiSkin.mania_offset[keyCount - 1 - (isPlayer ? playerManiaOffset : 0)]);
		y = strumlineY - (height / 2);

		x += 100 - ((keyCount - 4 - (isPlayer ? playerManiaOffset : 0)) * 16) + (keyCount >= 10 ? 30 : 0);
		x += ((FlxG.width / 2) * player);
	}

	

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		//updateHitbox();
        centerOrigin();

		if(anim == "static")
		{
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;

			swagWidth = width;
		}
		else
		{
			colorSwap.hue = noteColor[0] / 360;
			colorSwap.saturation = noteColor[1] / 100;
			colorSwap.brightness = noteColor[2] / 100;
		}

		if(uiSkin.ui_Skin != "pixel")
		{
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;
	
			var scale = Std.parseFloat(uiSkin.ui_Settings.get("globalScale")) * (Std.parseFloat(uiSkin.ui_Settings.get("noteScale")) - (Std.parseFloat(uiSkin.mania_size[keyCount - 1])));
	
			offset.x -= 156 * scale / 2;
			offset.y -= 156 * scale / 2;
		}
		else
			centerOffsets();
	}
}

class UISkin
{
	public var ui_Skin:String = "default";
	public var ui_Settings:Map<String, String>;
	public var mania_size:Array<String>;
	public var mania_gap:Array<String>;
	public var mania_offset:Array<String>;
	public var types:Array<String>;
	public var arrow_Configs:Map<String, Map<String, String>> = new Map<String, Map<String, String>>();
	public var type_Configs:Map<String, Map<String, String>> = new Map<String, Map<String, String>>();
	public var arrow_Type_Sprites:Map<String, FlxFramesCollection> = [];
	public var arrow_Type_Cached_Sprites:Array<FlxSprite> = [];

	public var splash_Texture:FlxFramesCollection;
	public var splashesSettings:Map<String, String>;
	public var splashesSkin:String = "default";
	public function new(skin:String = "default")
	{
		ui_Skin = skin;

		ui_Settings = loadConfig(CoolUtil.coolTextFile(Paths.txt("ui skins/" + ui_Skin + "/config")));
		mania_size = CoolUtil.coolTextFile(Paths.txt("ui skins/" + ui_Skin + "/maniasize"));
		mania_offset = CoolUtil.coolTextFile(Paths.txt("ui skins/" + ui_Skin + "/maniaoffset"));

		if(Assets.exists(Paths.txt("ui skins/" + ui_Skin + "/maniagap")))
			mania_gap = CoolUtil.coolTextFile(Paths.txt("ui skins/" + ui_Skin + "/maniagap"));
		else
			mania_gap = CoolUtil.coolTextFile(Paths.txt("ui skins/default/maniagap"));

		types = CoolUtil.coolTextFile(Paths.txt("ui skins/" + ui_Skin + "/types"));

		arrow_Configs.set("default", loadConfig(CoolUtil.coolTextFile(Paths.txt("ui skins/" + ui_Skin + "/default"))));
		type_Configs.set("default", loadConfig(CoolUtil.coolTextFile(Paths.txt("arrow types/default"))));

		setArrowSprite("default", Paths.getSparrowAtlas('ui skins/' + ui_Skin + "/arrows/default", 'shared'));

		if(Std.parseInt(ui_Settings.get("splashes")) == 1)
		{
			splash_Texture = Paths.getSparrowAtlas('ui skins/' + ui_Skin + "/arrows/Note_Splashes", 'shared');
			splashesSettings = ui_Settings;
		}
		else
		{
			splash_Texture = Paths.getSparrowAtlas("ui skins/default/arrows/Note_Splashes", 'shared');
			splashesSettings = loadConfig(CoolUtil.coolTextFile(Paths.txt("ui skins/default/config")));
		}
	}

	public function loadConfig(a:Array<String>)
	{
		var map:Map<String, String> = new Map<String, String>();
		for (i in a)
		{
			var split = i.split(':');
			if (split.length > 1)
				map.set(split[0], split[1]);
		}
		//trace(map);
		return map;
	}
	public function setArrowSprite(type:String, frames:FlxFramesCollection)
	{
		arrow_Type_Sprites.set(type, frames);
		var spr:FlxSprite = new FlxSprite(0,0); //keep an instance to prevent any crashes
		spr.frames = frames;
		arrow_Type_Cached_Sprites.push(spr);
	}
} 