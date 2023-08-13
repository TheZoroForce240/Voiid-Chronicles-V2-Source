package game;

import shaders.NoteColors;
import shaders.ColorSwap;
import game.Song.SwagSong;
import utilities.CoolUtil;
import utilities.NoteVariables;
import states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var prevNoteStrumtime:Float = 0;
	public var prevNoteIsSustainNote:Bool = false;

	public var singAnimPrefix:String = "sing"; //hopefully should make things easier
	public var singAnimSuffix:String = ""; //for alt anims lol

	public var sustains:Array<Note> = [];
	public var missesSustains:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;

	public var rawNoteData:Int = 0;

	public var modifiedByLua:Bool;
	public var modAngle:Float = 0;
	public var localAngle:Float = 0;

	public var character:Int = 0;

	public var characters:Array<Int> = [];
	
	public var arrow_Type:String;

	public var shouldHit:Bool = true;
	public var hitDamage:Float = 0.0;
	public var missDamage:Float = 0.07;
	public var heldMissDamage:Float = 0.035;
	public var playMissOnMiss:Bool = true;

	public var noteWasHit:Bool = false;
	public var wasMissed:Bool = false;

	public var sustainScaleY:Float = 1;

	public var colorSwap:ColorSwap;

	public var inEditor:Bool = false;

	public var xOffset:Float = 0;
	public var yOffset:Float = 0;

	public var halfWidth:Float = 160*0.35;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?character:Int = 0, ?arrowType:String = "default", ?song:SwagSong, ?characters:Array<Int>, ?mustPress:Bool = false, ?inEditor:Bool = false)
	{
		super();

		if(prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		this.inEditor = inEditor;
		this.character = character;
		this.strumTime = strumTime;
		this.arrow_Type = arrowType;
		this.characters = characters;
		this.mustPress = mustPress;

		isSustainNote = sustainNote;

		if(song == null)
			song = PlayState.SONG;

		if (!inEditor)
			this.strumTime = Math.floor(strumTime);

		var localKeyCount = mustPress ? song.playerKeyCount : song.keyCount;

		this.noteData = noteData;

		x += 100;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y = -2000;

		if(!PlayState.instance.uiSkin.arrow_Configs.exists(arrow_Type))
		{
			if(PlayState.instance.uiSkin.types.contains(arrow_Type))
				PlayState.instance.uiSkin.arrow_Configs.set(arrow_Type, PlayState.instance.uiSkin.loadConfig(CoolUtil.coolTextFile(Paths.txt("ui skins/" + song.ui_Skin + "/" + arrow_Type))));
			else
				PlayState.instance.uiSkin.arrow_Configs.set(arrow_Type, PlayState.instance.uiSkin.loadConfig(CoolUtil.coolTextFile(Paths.txt("ui skins/default/" + arrow_Type))));

			PlayState.instance.uiSkin.type_Configs.set(arrow_Type, PlayState.instance.uiSkin.loadConfig(CoolUtil.coolTextFile(Paths.txt("arrow types/" + arrow_Type))));
			PlayState.instance.setupNoteTypeScript(arrow_Type);
		}

		if(!PlayState.instance.uiSkin.arrow_Type_Sprites.exists(arrow_Type))
		{
			var arrowTypeName = arrow_Type;
			if (arrowType == "Wiik3Punch" || arrowType == "RevPunch")
			{
				if (utilities.Options.getData("altPunchNotes"))
					arrowTypeName += "Alt";
			}

			if (PlayState.instance.uiSkin.arrow_Configs.get(arrow_Type).exists("spriteName"))
				arrowTypeName = PlayState.instance.uiSkin.arrow_Configs.get(arrow_Type).get("spriteName"); //force sprite name to stop duplicated sprites

			if(PlayState.instance.uiSkin.types.contains(arrow_Type))
				PlayState.instance.uiSkin.setArrowSprite(arrow_Type, Paths.getSparrowAtlas('ui skins/' + song.ui_Skin + "/arrows/" + arrowTypeName, 'shared'));
			else
				PlayState.instance.uiSkin.setArrowSprite(arrow_Type, Paths.getSparrowAtlas("ui skins/default/arrows/" + arrowTypeName, 'shared'));
		}

		frames = PlayState.instance.uiSkin.arrow_Type_Sprites.get(arrow_Type);

		animation.addByPrefix("default", NoteVariables.Other_Note_Anim_Stuff[localKeyCount - 1][noteData] + "0", 24);
		animation.addByPrefix("hold", NoteVariables.Other_Note_Anim_Stuff[localKeyCount - 1][noteData] + " hold0", 24);
		animation.addByPrefix("holdend", NoteVariables.Other_Note_Anim_Stuff[localKeyCount - 1][noteData] + " hold end0", 24);

		

		var lmaoStuff = Std.parseFloat(PlayState.instance.uiSkin.ui_Settings.get("globalScale")) * (Std.parseFloat(PlayState.instance.uiSkin.ui_Settings.get("noteScale")) - (Std.parseFloat(PlayState.instance.uiSkin.mania_size[localKeyCount-1- (mustPress ? PlayState.instance.playerManiaOffset : 0)])));

		if(isSustainNote)
			setGraphicSize(Std.int(width * lmaoStuff), Std.int(height * Std.parseFloat(PlayState.instance.uiSkin.ui_Settings.get("globalScale")) * (Std.parseFloat(PlayState.instance.uiSkin.ui_Settings.get("noteScale")) - (Std.parseFloat(PlayState.instance.uiSkin.mania_size[3])))));
		else
			setGraphicSize(Std.int(width * lmaoStuff));

		halfWidth = 160*lmaoStuff*0.5;

		updateHitbox();
		
		antialiasing = PlayState.instance.uiSkin.ui_Settings.get("aa") == "true";

		x += swagWidth * noteData;
		animation.play("default");

		if (PlayState.instance.uiSkin.arrow_Configs.get(arrow_Type).exists("singAnimSuffix"))
			singAnimSuffix = PlayState.instance.uiSkin.arrow_Configs.get(arrow_Type).get("singAnimSuffix");




		if (PlayState.instance.uiSkin.arrow_Configs.get(arrow_Type).exists("y"))
			yOffset += Std.parseFloat(PlayState.instance.uiSkin.arrow_Configs.get(arrow_Type).get("y")) * lmaoStuff;

		if (PlayState.instance.uiSkin.arrow_Configs.get(arrow_Type).exists("x"))
			xOffset += Std.parseFloat(PlayState.instance.uiSkin.arrow_Configs.get(arrow_Type).get("x"))*lmaoStuff;

		if (inEditor)
		{
			//offset.x += xOffset;
			//offset.y += yOffset;
		}

		if (PlayState.instance.uiSkin.type_Configs.get(arrow_Type).exists("shouldHit"))
			shouldHit = PlayState.instance.uiSkin.type_Configs.get(arrow_Type).get("shouldHit") == "true";
		if (PlayState.instance.uiSkin.type_Configs.get(arrow_Type).exists("hitDamage"))
			hitDamage = Std.parseFloat(PlayState.instance.uiSkin.type_Configs.get(arrow_Type).get("hitDamage"));
		if (PlayState.instance.uiSkin.type_Configs.get(arrow_Type).exists("missDamage"))
			missDamage = Std.parseFloat(PlayState.instance.uiSkin.type_Configs.get(arrow_Type).get("missDamage"));
 
		if(PlayState.instance.uiSkin.type_Configs.get(arrow_Type).exists("playMiss"))
			playMissOnMiss = PlayState.instance.uiSkin.type_Configs.get(arrow_Type).get("playMiss") == "true";
		else
		{
			if(shouldHit)
				playMissOnMiss = true;
			else
				playMissOnMiss = false;
		}

		if (PlayState.instance.uiSkin.type_Configs.get(arrow_Type).exists("sustainMissDamage"))
			heldMissDamage = Std.parseFloat(PlayState.instance.uiSkin.type_Configs.get(arrow_Type).get("sustainMissDamage"));

		if (utilities.Options.getData("downscroll") && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			//store these for later, dont get while playing cuz prev note gets killed before this note so game could crash idk
			prevNoteStrumtime = prevNote.strumTime;
			prevNoteIsSustainNote = prevNote.isSustainNote;

			if(song.ui_Skin != 'pixel')
				x += width / 2;

			animation.play("holdend");
			updateHitbox();

			if(song.ui_Skin != 'pixel')
				x -= width / 2;

			if (song.ui_Skin == 'pixel')
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play("hold");

				flipX = !prevNote.flipX; //makes each connection more seemless???? sorta idk lol

				var speed = song.speed;

				if(utilities.Options.getData("useCustomScrollSpeed"))
					speed = utilities.Options.getData("customScrollSpeed") / PlayState.songMultiplier;

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * speed;
				prevNote.updateHitbox();
				prevNote.sustainScaleY = prevNote.scale.y;
			}

			centerOffsets();
			centerOrigin();

			sustainScaleY = scale.y;
		}

		var affectedbycolor:Bool = false;

		if(PlayState.instance.uiSkin.arrow_Configs.get(arrow_Type).exists("affectedByColor"))
		{
			if(PlayState.instance.uiSkin.arrow_Configs.get(arrow_Type).get("affectedByColor") == "true")
				affectedbycolor = true;
		}

		if(affectedbycolor)
		{
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;
	
			var noteColor = NoteColors.getNoteColor(NoteVariables.Other_Note_Anim_Stuff[localKeyCount - 1][noteData]);
	
			colorSwap.hue = noteColor[0] / 360;
			colorSwap.saturation = noteColor[1] / 100;
			colorSwap.brightness = noteColor[2] / 100;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		angle = modAngle + localAngle;

		calculateCanBeHit();

		if(!inEditor)
		{
			if(tooLate)
			{
				if (alpha > 0.3)
					alpha = 0.3;
			}
		}
	}

	public function checkPlayerMustPress() //flips must press for opponent mode
	{
		return (PlayState.characterPlayingAs == 1 ? !mustPress : mustPress);
	}

	public static var stunned:Bool = false;

	public function calculateCanBeHit()
	{
		if(this != null)
		{
			if(checkPlayerMustPress())
			{
				if (isSustainNote)
				{
					if(shouldHit)
					{
						if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
							&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
							canBeHit = true;
						else
							canBeHit = false;
					}
					else
					{
						if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
							&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
							canBeHit = true;
						else
							canBeHit = false;
					}
				}
				else
				{
					/*
					TODO: make this shit use something from the arrow config .txt file
					*/ 
					if(shouldHit)
					{
						if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
							&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
							canBeHit = true;
						else
							canBeHit = false;
					}
					else
					{
						if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
							&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
							canBeHit = true;
						else
							canBeHit = false;
					}
				}
	
				if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
					tooLate = true;

				if (stunned)
					canBeHit = false;
			}
			else
			{
				canBeHit = false;
	
				if (strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}
	}
}

typedef NoteType = {
	var shouldHit:Bool;

	var hitDamage:Float;
	var missDamage:Float;
} 