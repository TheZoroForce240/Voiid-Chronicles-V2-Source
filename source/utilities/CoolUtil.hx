package utilities;

import flixel.math.FlxMath;
import flixel.FlxG;
import states.PlayState;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function boundTo(value:Float, min:Float, max:Float):Float {
		var newValue:Float = value;

		if(newValue < min)
			newValue = min;
		else if(newValue > max)
			newValue = max;
		
		return newValue;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}
		/*#if mobile
		var appendPath = path.replace("assets/data/", "mods/Voiid Chronicles/_append/data/");
		//lime.app.Application.current.window.alert("appendPath:\n" + appendPath + (Assets.exists(appendPath) ? "does exist" : ""),"testing stuff");
		if (sys.FileSystem.exists(SUtil.getStorageDirectory() + appendPath))
		{
			var text = sys.io.File.getContent(SUtil.getStorageDirectory() + appendPath);
			var appendedList:Array<String> = text.trim().split("\n");
			//lime.app.Application.current.window.alert(text,"testing stuff");
			for (i in 0...appendedList.length)
			{
				daList.push(appendedList[i].trim());
			}	
		}
		#end*/

		return daList;
	}

	public static function coolTextFileOfArrays(path:String, ?delimeter:String = " "):Array<Array<String>>
	{
		var daListOg = coolTextFile(path);

		var daList:Array<Array<String>> = [];

		for(line in daListOg)
		{
			daList.push(line.split(delimeter));
		}

		return daList;
	}

	#if sys
	public static function coolTextFileFromSystem(path:String):Array<String>
	{
		return coolTextFile(path);
		/*
		var daList:Array<String> = File.getContent(Sys.getCwd() + "assets/" + path + ".txt").trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;*/
	}

	public static function coolTextFilePolymod(path:String):Array<String>
	{
		return coolTextFile(path);
		/*
		var daList:Array<String> = PolymodAssets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;*/
	}
	#end

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function openURL(url:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	public static function coolTextCase(text:String):String
	{
		var returnText:String = "";

		var textArray:Array<String> = text.split(" ");

		for(text in textArray) {
			var textStuffs = text.split("");

			for(i in 0...textStuffs.length)
			{
				if(i != 0)
					returnText += textStuffs[i].toLowerCase();
				else
					returnText += textStuffs[i].toUpperCase();
			}

			returnText += " ";
		}

		return returnText;
	}

	// stolen from psych lmao cuz i'm lazy
	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];

		for(col in 0...sprite.frameWidth)
		{
			for(row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);

				if(colorOfThisPixel != 0)
				{
					if(countByColor.exists(colorOfThisPixel))
						countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
					else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687))
						countByColor[colorOfThisPixel] = 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color

		countByColor[flixel.util.FlxColor.BLACK] = 0;

		for(key in countByColor.keys())
		{
			if(countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}

		return maxKey;
	}

	/**
	 * List of formatting for different byte amounts
	 * in an array formatted like this:
	 * 
	 * [`Format`, `Divisor`]
	 */
	 public static var byte_formats:Array<Array<Dynamic>> = [
		["$bytes B", 1.0],
		["$bytes KB", 1024.0],
		["$bytes MB", 1048576.0],
		["$bytes GB", 1073741824.0],
		["$bytes TB", 1099511627776.0]
	];

	/**
	 * Formats `bytes` into a `String`.
	 * 
	 * Examples (Input = Output)
	 * 
	 * ```
	 * 1024 = '1 kb'
	 * 1536 = '1.5 kb'
	 * 1048576 = '2 mb'
	 * ```
	 * 
	 * @param bytes Amount of bytes to format and return.
	 * @param onlyValue (Optional, Default = `false`) Whether or not to only format the value of bytes (ex: `'1.5 mb' -> '1.5'`).
	 * @param precision (Optional, Default = `2`) The precision of the decimal value of bytes. (ex: `1 -> 1.5, 2 -> 1.53, etc`).
	 * @return Formatted byte string.
	 */
	public static function formatBytes(bytes:Float, onlyValue:Bool = false, precision:Int = 2):String {
		var formatted_bytes:String = "?";

		for (i in 0...byte_formats.length) {
			// If the next byte format has a divisor smaller than the current amount of bytes,
			// and thus not the right format skip it.
			if (byte_formats.length > i + 1 && byte_formats[i + 1][1] < bytes)
				continue;

			var format:Array<Dynamic> = byte_formats[i];

			if (!onlyValue)
				formatted_bytes = StringTools.replace(format[0], "$bytes", Std.string(FlxMath.roundDecimal(bytes / format[1], precision)));
			else
				formatted_bytes = Std.string(FlxMath.roundDecimal(bytes / format[1], precision));

			break;
		}

		return formatted_bytes;
	}
}
