package game;

import states.PlayState;
import states.VoiidMainMenuState;
import flixel.graphics.FlxGraphic;
import utilities.CoolUtil;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import ui.HealthIcon;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxG;

class GameHUD extends FlxTypedSpriteGroup<FlxSprite>
{
    public var iconP1:HealthIcon = null;
	public var iconP2:HealthIcon = null;

    private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var timeBarBG:FlxSprite;
	private var timeBar:FlxBar;
    
    var scoreTxt:FlxText;
    var scoreTxt2:FlxText;
	var infoTxt:FlxText;

    public var ratingText:FlxText;

    public var visualHealth:Float = 1;
    public var minHealth:Float = 0;
    public var maxHealth:Float = 2;

    public var playerIcon:String = "";
    public var opponentIcon:String = "";
    public var playerColor:FlxColor = FlxColor.GREEN;
    public var opponentColor:FlxColor = FlxColor.RED;

    public var time:Float = 0;

    var oldHealthBar:Bool = false;

    public var uiMap:Map<String, FlxGraphic> = [];

    public function new()
    {
        super();
    }
    public function setCharacters(playerIcon:String, opponentIcon:String, playerColor:FlxColor, opponentColor:FlxColor)
    {
        this.playerIcon = playerIcon;
        this.opponentIcon = opponentIcon;
        this.playerColor = playerColor;
        this.opponentColor = opponentColor;
    }
    public function clearHUD()
    {
        for (m in members)
        {
            m.destroy();
        }
        this.clear();
    }
    public function changeRatingSkin(?uiSkin:String = "default")
    {
        uiMap.set("marvelous", FlxGraphic.fromAssetKey(Paths.image("ui skins/" + uiSkin + "/ratings/" + "marvelous")));
		uiMap.set("sick", FlxGraphic.fromAssetKey(Paths.image("ui skins/" + uiSkin + "/ratings/" + "sick")));
		uiMap.set("good", FlxGraphic.fromAssetKey(Paths.image("ui skins/" + uiSkin + "/ratings/" + "good")));
		uiMap.set("bad", FlxGraphic.fromAssetKey(Paths.image("ui skins/" + uiSkin + "/ratings/" + "bad")));
		uiMap.set("shit", FlxGraphic.fromAssetKey(Paths.image("ui skins/" + uiSkin + "/ratings/" + "shit")));

		for(i in 0...10)
		{
			uiMap.set(Std.string(i), FlxGraphic.fromAssetKey(Paths.image("ui skins/" + uiSkin + "/numbers/num" + Std.string(i))));	
		}
    }
    public function createHUD(?uiSkin:String = "default", ?healthBarType:String = "default")
    {
        changeRatingSkin(uiSkin);

        var healthBarPosY = FlxG.height * 0.9;

        if(utilities.Options.getData("downscroll"))
            healthBarPosY = 60;

        var iconYOffset:Float = 0.0;

        switch (healthBarType)
        {
            case "old": 
                healthBarBG = new FlxSprite(0, healthBarPosY).loadGraphic(Paths.image('ui skins/' + uiSkin + '/other/GonehealthBar', 'shared'));
                healthBarBG.screenCenter(X);
                healthBarBG.scrollFactor.set();
                healthBarBG.pixelPerfectPosition = true;
                add(healthBarBG);
                
                healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
                    'visualHealth', minHealth, maxHealth);
                healthBar.scrollFactor.set();
                healthBar.createFilledBar(opponentColor, playerColor);
                healthBar.pixelPerfectPosition = true;
                add(healthBar);
        
                healthBarBG = new FlxSprite(0, healthBarPosY).loadGraphic(Paths.image('ui skins/' + uiSkin + '/other/VoiidhealthBar', 'shared'));
                healthBarBG.screenCenter(X);
                healthBarBG.scrollFactor.set();
                healthBarBG.pixelPerfectPosition = true;
                add(healthBarBG);
            case "vanilla": 
                healthBarBG = new FlxSprite(0, healthBarPosY).loadGraphic(Paths.image('ui skins/' + uiSkin + '/other/healthBar'));
                healthBarBG.screenCenter(X);
                healthBarBG.scrollFactor.set();
                healthBarBG.pixelPerfectPosition = true;
                add(healthBarBG);
        
                healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
                    'visualHealth', minHealth, maxHealth);
                healthBar.scrollFactor.set();
                healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
                healthBar.pixelPerfectPosition = true;
                add(healthBar);
            default: 
                healthBarBG = new FlxSprite(0, healthBarPosY).loadGraphic(Paths.image('ui skins/' + uiSkin + '/other/newHealthBar', 'shared'));
                healthBarBG.screenCenter(X);
                healthBarBG.scrollFactor.set();
                healthBarBG.pixelPerfectPosition = true;
                
                healthBar = new FlxBar(healthBarBG.x + 13, healthBarBG.y + 15, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 25), 23, this,
                    'visualHealth', minHealth, maxHealth);
                healthBar.scrollFactor.set();
                healthBar.createFilledBar(opponentColor, playerColor);
                healthBar.pixelPerfectPosition = true;
                add(healthBar);
    
                healthBar.offset.y += 10;
                healthBarBG.offset.y += 10;
        
                add(healthBarBG);

        }


        if(utilities.Options.getData("healthIcons"))
        {
            iconP1 = new HealthIcon(playerIcon, true);
            iconP1.y = healthBar.y - (iconP1.height / 2) - iconP1.offsetY;
            add(iconP1);
    
            iconP2 = new HealthIcon(opponentIcon, false);
            iconP2.y = healthBar.y - (iconP2.height / 2) - iconP2.offsetY;
            add(iconP2);
    
            iconP1.y += iconYOffset;
            iconP2.y += iconYOffset;
        }


        var scoreTxtSize:Int = 16;
        var funnyBarOffset:Int = 45;

        if(utilities.Options.getData("biggerScoreInfo"))
            scoreTxtSize = 20;

        scoreTxt = new FlxText(0, healthBarBG.y + funnyBarOffset, 0, "", 20);
        scoreTxt.screenCenter(X);
        scoreTxt.setFormat(Paths.font("vcr.ttf"), scoreTxtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        scoreTxt.scrollFactor.set();

        if(utilities.Options.getData("biggerScoreInfo"))
            scoreTxt.borderSize = 1.25;

        add(scoreTxt);

        if (PlayState.inMultiplayerSession)
        {
            scoreTxt2 = new FlxText(0, healthBarBG.y + funnyBarOffset, 0, "", 20);
            scoreTxt2.screenCenter(X);
            scoreTxt2.setFormat(Paths.font("vcr.ttf"), scoreTxtSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            scoreTxt.setFormat(Paths.font("vcr.ttf"), scoreTxtSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            scoreTxt2.scrollFactor.set();
    
            if(utilities.Options.getData("biggerScoreInfo"))
                scoreTxt2.borderSize = 1.25;
    
            add(scoreTxt2);
        }

        var infoTxtSize:Int = 16;

        if(utilities.Options.getData("biggerInfoText") == true)
            infoTxtSize = 20;

        infoTxt = new FlxText(0, 0, 0, "SONG - DIFF " + (utilities.Options.getData("botplay") ? " (BOT)" : ""), 20);
        infoTxt.setFormat(Paths.font("vcr.ttf"), infoTxtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        infoTxt.screenCenter(X);
        
        infoTxt.scrollFactor.set();

        switch(utilities.Options.getData("timeBarStyle").toLowerCase())
        {
            default: // includes 'leather engine'
                timeBarBG = new FlxSprite(0, healthBarPosY).loadGraphic(Paths.image('ui skins/' + uiSkin + '/other/healthBar', 'shared'));
                timeBarBG.screenCenter(X);
                timeBarBG.scrollFactor.set();
                timeBarBG.pixelPerfectPosition = true;
                
                if(utilities.Options.getData("downscroll"))
                    timeBarBG.y = FlxG.height - (timeBarBG.height + 1);
                else
                    timeBarBG.y = 1;
                
                add(timeBarBG);
                
                timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
                    'time', 0, FlxG.sound.music.length);
                timeBar.scrollFactor.set();
                timeBar.createGradientBar([FlxColor.TRANSPARENT], [playerColor, opponentColor]);
                timeBar.updateFilledBar();
                timeBar.pixelPerfectPosition = true;
                timeBar.numDivisions = 400;
                add(timeBar);

                if(utilities.Options.getData("downscroll"))
                    infoTxt.y = timeBarBG.y - timeBarBG.height - 1;
                else
                    infoTxt.y = timeBarBG.y + timeBarBG.height + 1;
            case "psych engine":
                timeBarBG = new FlxSprite(0, healthBarPosY).loadGraphic(Paths.image('psychTimeBar', 'shared'));
                timeBarBG.screenCenter(X);
                timeBarBG.scrollFactor.set();
                timeBarBG.pixelPerfectPosition = true;
                
                if(utilities.Options.getData("downscroll"))
                    timeBarBG.y = FlxG.height - 36;
                else
                    timeBarBG.y = 10;
                
                add(timeBarBG);


                var len:Float = FlxG.sound.music.length;
                if (len <= 0)
                    len = 1000;
                
                timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
                    'time', 0, len);
                timeBar.scrollFactor.set();
                timeBar.createGradientBar([FlxColor.TRANSPARENT], [playerColor, opponentColor]);
                timeBar.updateFilledBar();
                timeBar.pixelPerfectPosition = true;
                timeBar.numDivisions = 800;
                add(timeBar);

                if(utilities.Options.getData("biggerInfoText") == true)
                {
                    infoTxt.borderSize = 2;
                    infoTxt.size = 32;
                }
                else
                {
                    infoTxt.borderSize = 1.5;
                    infoTxt.size = 20;
                }

                infoTxt.y = timeBarBG.y - (infoTxt.height / 4);
            case "old kade engine":
                timeBarBG = new FlxSprite(0, healthBarPosY).loadGraphic(Paths.image('ui skins/' + uiSkin + '/other/healthBar', 'shared'));
                timeBarBG.screenCenter(X);
                timeBarBG.scrollFactor.set();
                timeBarBG.pixelPerfectPosition = true;
                
                if(utilities.Options.getData("downscroll"))
                    timeBarBG.y = FlxG.height * 0.9 + 45;
                else
                    timeBarBG.y = 10;
                
                add(timeBarBG);
                
                timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
                    'time', 0, FlxG.sound.music.length);
                timeBar.scrollFactor.set();
                timeBar.createGradientBar([FlxColor.TRANSPARENT], [playerColor, opponentColor]);
                timeBar.updateFilledBar();
                timeBar.pixelPerfectPosition = true;
                timeBar.numDivisions = 400;
                add(timeBar);

                infoTxt.y = timeBarBG.y;
        }

        add(infoTxt);

        if(utilities.Options.getData("sideRatings") == true)
        {
            ratingText = new FlxText(0,0,0,"bruh");
            ratingText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            ratingText.screenCenter(Y);
    
            ratingText.scrollFactor.set();
            add(ratingText);
        }

        updateHealthIconPosition();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function updateHealthIconScale(icon_Zoom_Lerp:Float, songMultiplier:Float = 1)
    {
        if (iconP1 == null || iconP2 == null)
            return;
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, iconP1.startWidth, icon_Zoom_Lerp * songMultiplier)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, iconP2.startWidth, icon_Zoom_Lerp * songMultiplier)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		iconP1.setGraphicSize(Std.int(CoolUtil.boundTo(iconP1.width, 0, iconP1.startWidth + 30)));
		iconP2.setGraphicSize(Std.int(CoolUtil.boundTo(iconP2.width, 0, iconP2.startWidth + 30)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();
    }

    public function iconBump(songMultiplier:Float = 1)
    {
        if (iconP1 == null || iconP2 == null)
            return;
        iconP1.setGraphicSize(Std.int(iconP1.width + (30 / (songMultiplier < 1 ? 1 : songMultiplier))));
		iconP2.setGraphicSize(Std.int(iconP2.width + (30 / (songMultiplier < 1 ? 1 : songMultiplier))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		iconP1.setGraphicSize(Std.int(CoolUtil.boundTo(iconP1.width, 0, iconP1.startWidth + 30)));
		iconP2.setGraphicSize(Std.int(CoolUtil.boundTo(iconP2.width, 0, iconP2.startWidth + 30)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

        updateHealthIconPosition();
    }

    public function updateHealthIconPosition()
    {
        if (iconP1 == null || iconP2 == null)
            return;
        var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset) - iconP1.offsetX;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset) - iconP2.offsetX;
    }

    public function updateHealthIconAnimation()
    {
        if (iconP1 == null || iconP2 == null)
            return;
        if (healthBar.percent < 20)
        {
            if(!iconP1.animatedIcon)
                iconP1.animation.curAnim.curFrame = 1;
            if(!iconP2.animatedIcon)
                iconP2.animation.curAnim.curFrame = 2;

            if(iconP2.animation.curAnim.curFrame != 2 && !iconP2.animatedIcon)
                iconP2.animation.curAnim.curFrame = 0;
        }
        else
        {
            if(!iconP1.animatedIcon)
                iconP1.animation.curAnim.curFrame = 0;

            if(!iconP2.animatedIcon)
                iconP2.animation.curAnim.curFrame = 0;
        }

        if (healthBar.percent > 80)
        {
            if(!iconP2.animatedIcon)
                iconP2.animation.curAnim.curFrame = 1;
            if(!iconP1.animatedIcon)
                iconP1.animation.curAnim.curFrame = 2;

            if(iconP1.animation.curAnim.curFrame != 2 && !iconP1.animatedIcon)
                iconP1.animation.curAnim.curFrame = 0;
        }
    }
    public function updateScoreText(text:String)
    {
        if (!PlayState.inMultiplayerSession)
            scoreTxt.x = (healthBarBG.x + (healthBarBG.width / 2)) - (scoreTxt.width / 2);

        scoreTxt.text = text;

        if (PlayState.inMultiplayerSession)
        {
            scoreTxt.x = healthBarBG.x+healthBarBG.width-scoreTxt.width;
            scoreTxt.y = healthBarBG.y+45;
            if(!utilities.Options.getData("downscroll"))
                scoreTxt.y -= scoreTxt.height+45;
        }
    }
    public function updateScoreTextP2(text:String)
    {
        if (scoreTxt2 != null)
        {
            scoreTxt2.text = text;

            scoreTxt2.x = healthBarBG.x;
            scoreTxt2.y = healthBarBG.y+45;
            if(!utilities.Options.getData("downscroll"))
                scoreTxt2.y -= scoreTxt2.height+45;
        }
            
    }

    public function updateRatingText(text:String)
    {
        if (ratingText != null)
        {
            ratingText.text = text;
            ratingText.screenCenter(Y);
        }
    }

    public function updateSongInfoText(text:String)
    {
        infoTxt.text = text;
        infoTxt.screenCenter(X);
    }



    public function changeHealthBarColors(playerColor:FlxColor, opponentColor:FlxColor)
    {
        this.playerColor = playerColor;
        this.opponentColor = opponentColor;
        healthBar.createFilledBar(opponentColor, playerColor);
        healthBar.updateFilledBar();
        if (timeBar != null)
        {
            timeBar.createGradientBar([FlxColor.TRANSPARENT], [playerColor, opponentColor]);
            timeBar.updateFilledBar();
        }
    }

    public function changePlayerIcon(icon:String)
    {
        if (iconP1 == null || iconP2 == null)
            return;
        iconP1.changeIconSet(icon);
    }
    public function changeOpponentIcon(icon:String)
    {
        if (iconP1 == null || iconP2 == null)
            return;
        iconP2.changeIconSet(icon);
    }
}