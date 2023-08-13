package;

import lime.utils.AssetType as LimeAssetType;
import lime.utils.Assets;
import flixel.graphics.FlxGraphic;
#if sys
import sys.io.File;
import sys.FileSystem;
import polymod.backends.PolymodAssets;
#end
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		#if mobile //dumb android shit idk
		if (FileSystem.exists(SUtil.getStorageDirectory() + 'mods/Voiid Chronicles/shared/$file'))
		{
			return 'mods/Voiid Chronicles/shared/$file';
		}
		if (FileSystem.exists(SUtil.getStorageDirectory() + 'mods/Voiid Chronicles/stages/$file'))
		{
			return 'mods/Voiid Chronicles/stages/$file';
		}
		if (FileSystem.exists(SUtil.getStorageDirectory() + 'mods/Voiid Chronicles/_append/$file'))
		{
			return 'mods/Voiid Chronicles/_append/$file';
		}
		if (FileSystem.exists(SUtil.getStorageDirectory() + 'mods/Voiid Chronicles/$file'))
		{
			return 'mods/Voiid Chronicles/$file';
		}
		#end
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);

			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");

			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function lua(key:String,?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}
	inline static public function ogmo(key:String, ?library:String)
	{
		return getPath('data/$key.ogmo', TEXT, library);
	}

	static public function video(key:String, ?ext:String = VIDEO_EXT)
	{
		return 'assets/videos/$key.$ext';
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	static public function voices(song:String, ?difficulty:String)
	{
		#if !mobile 
		var prefix:String = "songs:assets/";
		song = song.toLowerCase();
		#else 
		var prefix:String = "";
		#end

		var path:String = "";
		if(difficulty != null)
		{
			if(Assets.exists(prefix+'songs/${song}/Voices-$difficulty.$SOUND_EXT'))
			{
				path = prefix+'songs/${song}/Voices-$difficulty.$SOUND_EXT';
				#if mobile //dumb android shit idk
				if (FileSystem.exists(SUtil.getStorageDirectory() + 'mods/Voiid Chronicles/$path'))
				{
					return 'mods/Voiid Chronicles/$path';
				}
				#end
				return path;
			}
		}
		path = prefix+'songs/${song}/Voices.$SOUND_EXT';
		#if mobile //dumb android shit idk
		if (FileSystem.exists(SUtil.getStorageDirectory() + 'mods/Voiid Chronicles/$path'))
		{
			return 'mods/Voiid Chronicles/$path';
		}
		#end
		return path;
	}

	static public function inst(song:String, ?difficulty:String)
	{
		#if !mobile 
		var prefix:String = "songs:assets/";
		song = song.toLowerCase();
		#else 
		var prefix:String = "";
		#end

		var path:String = "";
		if(difficulty != null)
		{
			if(Assets.exists(prefix+'songs/${song}/Inst-$difficulty.$SOUND_EXT'))
			{
				path = prefix+'songs/${song}/Inst-$difficulty.$SOUND_EXT';
				#if mobile //dumb android shit idk
				if (FileSystem.exists(SUtil.getStorageDirectory() + 'mods/Voiid Chronicles/$path'))
				{
					return 'mods/Voiid Chronicles/$path';
				}
				#end
				return path;
			}
		}
		path = prefix+'songs/${song}/Inst.$SOUND_EXT';
		#if mobile //dumb android shit idk
		if (FileSystem.exists(SUtil.getStorageDirectory() + 'mods/Voiid Chronicles/$path'))
		{
			return 'mods/Voiid Chronicles/$path';
		}
		#end
		return path;
	}

	static public function songEvents(song:String, ?difficulty:String)
	{
		#if !mobile 
		song = song.toLowerCase();
		if (difficulty != null)
			difficulty = difficulty.toLowerCase();
		#end
		if(difficulty != null)
		{
			if(Assets.exists(Paths.json("song data/" + song + '/events-${difficulty}')))
				return Paths.json("song data/" + song + '/events-${difficulty}');
		}

		return Paths.json("song data/" + song + "/events");
	}

	public static var storedImages:Map<String, FlxGraphic>;

	inline static public function image(key:String, ?library:String)
	{
		var path = getPath('images/$key.png', IMAGE, library);
		//var graphic:FlxGraphic = FlxG.bitmap.add(path, false, null);
		//if (graphic != null && !storedImages.exists(path))
		//{
		//	storedImages.set(path, graphic);
		//}
		return path;
	}
	public static function clearMemory()
	{
		for (key => graphic in storedImages)
		{
			@:privateAccess
			if (openfl.Assets.cache.hasBitmapData(key))
			{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
			}
			graphic.destroy();
			storedImages.remove(key);
		}
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		if(Assets.exists(file('images/$key.xml', library)))
			return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		else
			return FlxAtlasFrames.fromSparrow(image("Bind_Menu_Assets", "preload"), file('images/Bind_Menu_Assets.xml', "preload"));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		if(Assets.exists(file('images/$key.txt', library)))
			return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		else
			return FlxAtlasFrames.fromSparrow(image("Bind_Menu_Assets", "preload"), file('images/Bind_Menu_Assets.xml', "preload"));
	}

	#if sys
	inline static public function getSparrowAtlasSYS(key:String, ?library:String)
	{
		return getSparrowAtlas(key, library);
	}

	inline static public function imageSYS(key:String, ?library:String)
	{
		return image(key, library);
	}

	inline static public function getPackerAtlasSYS(key:String, ?library:String)
	{
		return getPackerAtlas(key, library);
	}

	inline static public function jsonSYS(key:String, ?library:String)
	{
		return pathStyleSYS(key + ".json", library, "data");
	}

	inline static public function voicesSYS(song:String)
	{
		return 'assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function instSYS(song:String)
	{
		return 'assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	// path stuff lol for system
	inline static public function pathStyleSYS(key:String, ?library:String, ?dataType:String = "images")
	{
		if(library != null)
			library = library + "/";
		else
			library = "";

		return "assets/" + library + dataType + "/" + key;
	}
	#end
}
