package modding;
import openfl.system.Capabilities;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.BaseScaleMode;
#if desktop
@:cppFileCode('#include <windows.h>\n#include <dwmapi.h>\n\n#pragma comment(lib, "Dwmapi")')
class FlxTransWindow
{
	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(1, 1, 1), 0, LWA_COLORKEY);
        }
    ')
	static public function getWindowsTransparent(res:Int = 0)
	{
		return res;
	}

	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) ^ WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(1, 1, 1), 1, LWA_COLORKEY);
        }
    ')
	static public function getWindowsbackward(res:Int = 0)
	{
		return res;
	}

    private static var madeTransparent = false;
    public static function setupTransparentWindow()
    {
        flixel.FlxG.fullscreen = false;
        flixel.FlxG.scaleMode = new StupidScaleMode();
        openfl.Lib.application.window.width = Std.int(Capabilities.screenResolutionX);
        openfl.Lib.application.window.height = Std.int(Capabilities.screenResolutionY);
        openfl.Lib.application.window.x = 0;
        openfl.Lib.application.window.y = -1;
        FlxTransWindow.getWindowsTransparent();
        madeTransparent = true;
        if(Main.display != null) {
            Main.display.visible = false;
        }
        if(Main.popupManager != null) {
            Main.popupManager.visible = false;
        }
    }
    public static function restoreWindow()
    {
        if (madeTransparent)
        {
            madeTransparent = false;
            flixel.FlxG.scaleMode = new RatioScaleMode();
			openfl.Lib.application.window.width = 1280;
			openfl.Lib.application.window.height = 720;
			openfl.Lib.application.window.x = Std.int((Capabilities.screenResolutionX/2)-(1280/2));
			openfl.Lib.application.window.y = Std.int((Capabilities.screenResolutionY/2)-(720/2));
			FlxTransWindow.getWindowsbackward();
			if(Main.display != null) {
				Main.display.visible = true;
			}
            if(Main.popupManager != null) {
                Main.popupManager.visible = true;
            }
        }
    }
}
#end

/**
 * keeps the game 720p while its "fullscreen"
 */
class StupidScaleMode extends BaseScaleMode
{
	public var gameWidth:Float = 1280;
	public var gameHeight:Float = 720;
	override public function new()
	{
		super();

	}
	override public function onMeasure(Width:Int, Height:Int)
	{
		updateGameSize(Std.int(gameWidth), Std.int(gameHeight));
		updateDeviceSize(Width, Height);
		updateScaleOffset();
		updateGamePosition();
	}
}