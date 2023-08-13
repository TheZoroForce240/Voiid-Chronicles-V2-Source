local perlinX = 0
local perlinY = 0
local perlinZ = 0

local perlinSpeed = 0.5

local perlinXRange = 0.01
local perlinYRange = 0.01
local perlinZRange = 0.1

function update(elapsed)

    perlinX = perlinX + elapsed*math.random()*perlinSpeed
	perlinY = perlinY + elapsed*math.random()*perlinSpeed
	perlinZ = perlinZ + elapsed*math.random()*perlinSpeed
    --local noiseX = perlin.noise(perlinX, 0, 0)
	--trace(perlin(perlinX, 0, 0)*0.1)
    setShaderProperty('barrel', 'x', ((-0.5 + perlin(perlinX, 0, 0))*perlinXRange))
	setShaderProperty('barrel', 'y', ((-0.5 + perlin(0, perlinY, 0))*perlinYRange))
	setShaderProperty('barrel', 'angle', ((-0.5 + perlin(0, 0, perlinZ))*perlinZRange))

    if curStep == 896 then
        tweenAngleOut("camAngle", -2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 904 then
        tweenAngleOut("camAngle", 2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 912 then
        tweenAngleOut("camAngle", -2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 920 then
        tweenAngleOut("camAngle", 2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 924 then
        tweenAngleOut("camAngle", -2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 928 then
        tweenAngleOut("camAngle", 2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 936 then
        tweenAngleOut("camAngle", -2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 944 then
        tweenAngleOut("camAngle", 2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 952 then
        tweenAngleOut("camAngle", -2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 956 then
        tweenAngleOut("camAngle", 2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 960 then
        tweenAngleOut("camAngle", -2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 968 then
        tweenAngleOut("camAngle", 2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 976 then
        tweenAngleOut("camAngle", -2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 984 then
        tweenAngleOut("camAngle", 2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 988 then
        tweenAngleOut("camAngle", -2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 992 then
        tweenAngleOut("camAngle", 2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 1000 then
        tweenAngleOut("camAngle", -2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 1008 then
        tweenAngleOut("camAngle", 2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 1016 then
        tweenAngleOut("camAngle", -2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 1020 then
        tweenAngleOut("camAngle", 2.5, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 1024 then
        tweenAngleOut("camAngle", -0, (getPropertyFromClass("game.Conductor", "crochet") / 1000))
    end
    if curStep == 1408 then
        tweenAngleOut("camAngle", 5, (getPropertyFromClass("game.Conductor", "crochet") / 100))
    end
    if curStep == 1440 then
        tweenAngleOut("camAngle", -5, (getPropertyFromClass("game.Conductor", "crochet") / 100))
    end
    if curStep == 1472 then
        tweenAngleOut("camAngle", 0, (getPropertyFromClass("game.Conductor", "crochet") / 250))
    end
    if curStep == 2048 then
        tweenAngleOut("camAngle", 180, (getPropertyFromClass("game.Conductor", "crochet") / 200))
    end
    if curStep == 2112 then
        tweenAngleOut("camAngle", 0, (getPropertyFromClass("game.Conductor", "crochet") / 100))
    end

    setShaderProperty('mirror2', 'angle', getActorAngle('camAngle'))

    --setActorX(getOriginalCharX(0)+500*math.sin(songPos*0.0005), 'boyfriend')
end

function playerTwoSing(data, time, type)

end

local zooms = {128, 140,152,184,192,204,216}
local leftTilts = {304,376,432, 652, 816,1024,1144,1560,1632,1648,1664}
local rightTilts = {368,658,1016, 1072,1136,1200,1592,1640, 1656}

local leftTiltsGrey = {600,536, 664, 728}
local rightTiltsGrey = {604,540, 668, 732}

function createPost()

    makeSprite('camAngle', '', 0, 0, 1)

    showOnlyStrums = true

	initShader('mirror', 'MirrorRepeatEffect')
	setCameraShader('game', 'mirror')
    if modcharts then 
		setCameraShader('hud', 'mirror')
	end
	setShaderProperty('mirror', 'zoom', 0.1)

    initShader('mirror2', 'MirrorRepeatEffect')
    --setCameraShader('game', 'mirror2')
    if modcharts then 
		setCameraShader('hud', 'mirror2')
	end
	setShaderProperty('mirror2', 'zoom', 1)

    initShader('barrel', 'BarrelBlurEffect')
	setCameraShader('game', 'barrel')
	setCameraShader('hud', 'barrel')
	setShaderProperty('barrel', 'zoom', 1.0)
    setShaderProperty('barrel', 'barrel', 0)
    --setShaderProperty('barrelChroma', 'doChroma', true)


    initShader('sobel', 'SobelEffect')

    --setCameraShader('game', 'sobel')
    if modcharts then 
        setCameraShader('hud', 'sobel')
	end
    setShaderProperty('sobel', 'strength', 0)
    setShaderProperty('sobel', 'intensity', 2)

    initShader('bloom2', 'BloomEffect')
    setCameraShader('game', 'bloom2')
    setCameraShader('hud', 'bloom2')

    setShaderProperty('bloom2', 'effect', 0)
    setShaderProperty('bloom2', 'strength', 0)

    initShader('caBlue', 'ChromAbEffect')
    setCameraShader('game', 'caBlue')
    setCameraShader('hud', 'caBlue')
    setShaderProperty('caBlue', 'strength', 0.0)

    initShader('grey', 'GreyscaleEffect')
    setCameraShader('game', 'grey')
    setCameraShader('hud', 'grey')
    setShaderProperty('grey', 'strength', 1.0)

    initShader('scanline', 'ScanlineEffect')
    setCameraShader('hud', 'scanline')
    setShaderProperty('scanline', 'strength', 0)
    setShaderProperty('scanline', 'pixelsBetweenEachLine', 10)

    initShader('vignette', 'VignetteEffect')
    setCameraShader('hud', 'vignette')
    setCameraShader('game', 'vignette')
    setShaderProperty('vignette', 'strength', 15)
    setShaderProperty('vignette', 'size', 0.4)

    setProperty('camGame', 'alpha', 0)

    --addCharacterToMap('boyfriend', 'Wiik3BFOnii')
end
function songStart()
    setProperty('camGame', 'alpha', 1)
    tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*16*5, 'cubeOut')
end
function stepHit()

    if curStep == 64 then 
        tweenShaderProperty('grey', 'strength', 0, crochet*0.001*16*2, 'cubeInOut')
    elseif curStep == 256 then 
        showOnlyStrums = false
        tweenShaderProperty('grey', 'strength', 0, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
    end

    if curStep == 188 then 
        triggerEvent('add camera zoom', 0.2,0.2)
        setProperty('', 'camZooming', true)
    elseif curStep == 224 then 
        tweenShaderProperty('grey', 'strength', 1, crochet*0.001*16*2, 'cubeInOut')
        tweenShaderProperty('mirror', 'zoom', 0.7, crochet*0.001*16*2, 'cubeIn')
    elseif curStep == 236 then 
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeIn')
    elseif curStep == 240 then 
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 244 then 
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeIn')
    elseif curStep == 248 then 
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    end

    for i = 1, #zooms do 
        if curStep == zooms[i] then 
            tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        elseif curStep == zooms[i]-4 then 
            tweenShaderProperty('mirror', 'zoom', 0.8, crochet*0.001*4, 'cubeIn')
        end
    end
    for i = 1, #leftTilts do 
        if curStep == leftTilts[i] then 
            tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*3, 'cubeOut')
        elseif curStep == leftTilts[i]-3 then 
            tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*3, 'cubeIn')
        end
    end
    for i = 1, #rightTilts do 
        if curStep == rightTilts[i] then 
            tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*3, 'cubeOut')
        elseif curStep == rightTilts[i]-3 then 
            tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*3, 'cubeIn')
        end
    end

    for i = 1, #leftTiltsGrey do 
        if curStep == leftTiltsGrey[i] then 
            tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*3, 'cubeOut')
            tweenShaderProperty('grey', 'strength', 0, crochet*0.001*3, 'cubeOut')
        elseif curStep == leftTiltsGrey[i]-1 then 
            tweenShaderProperty('mirror', 'angle', 40, crochet*0.001*1, 'cubeIn')
            tweenShaderProperty('grey', 'strength', 1, crochet*0.001*1, 'cubeOut')
        end
    end
    for i = 1, #rightTiltsGrey do 
        if curStep == rightTiltsGrey[i] then 
            tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*3, 'cubeOut')
            tweenShaderProperty('grey', 'strength', 0, crochet*0.001*3, 'cubeOut')
        elseif curStep == rightTiltsGrey[i]-1 then 
            tweenShaderProperty('mirror', 'angle', -40, crochet*0.001*1, 'cubeIn')
            tweenShaderProperty('grey', 'strength', 1, crochet*0.001*1, 'cubeOut')
        end
    end

    if (curStep > 256 and curStep < 512) or (curStep > 1024 and curStep < 1280) then 
        if curStep % 64 < 16 then 
            if curStep % 16 == 0 then 
                tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
            end
        else 
            if curStep % 16 == 8 then 
                tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
            end
            if curStep % 16 == 4 then 
                tweenShaderProperty('mirror', 'zoom', 0.8, crochet*0.001*4, 'cubeIn')
            end
        end

        if curStep % 16 == 60 then 
            tweenShaderProperty('mirror', 'zoom', 0.8, crochet*0.001*4, 'cubeIn')
        end
    end
    if curStep > 1280 and curStep < 1408 then 
        if curStep % 16 == 0 then 
            tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        end
        if curStep % 16 == 12 then 
            tweenShaderProperty('mirror', 'zoom', 0.85, crochet*0.001*4, 'cubeIn')
        end
        perlinXRange = 0.1
        perlinYRange = 0.1
        perlinZRange = 3
        perlinSpeed = 1
    end
    if (curStep >= 1404 and curStep < 1472) or (curStep >= 1660 and curStep < 1792) then 
        if curStep % 8 == 0 then 
            tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        end
        if curStep % 8 == 4 then 
            tweenShaderProperty('mirror', 'zoom', 0.85, crochet*0.001*4, 'cubeIn')
        end
        perlinXRange = 0.1
        perlinYRange = 0.1
        perlinZRange = 3
        perlinSpeed = 1.5
    end
    if curStep >= 1470 and curStep < 1504 then 
        if curStep % 4 == 0 then 
            tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
        end
        if curStep % 4 == 2 then 
            tweenShaderProperty('mirror', 'zoom', 0.85, crochet*0.001*2, 'cubeIn')
        end
        perlinXRange = 0.1
        perlinYRange = 0.1
        perlinZRange = 3
        perlinSpeed = 2
    end
    if curStep == 480 then 
        tweenShaderProperty('barrel', 'zoom', 0.5, crochet*0.001*32, 'cubeIn')
        tweenShaderProperty('bloom2', 'effect', 0.5, crochet*0.001*32, 'cubeIn')
        tweenShaderProperty('bloom2', 'strength', 6, crochet*0.001*32, 'cubeIn')
        tweenShaderProperty('barrel', 'barrel', -2, crochet*0.001*32, 'cubeIn')
    elseif curStep == 512 then 
        tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('bloom2', 'effect', 0, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('bloom2', 'strength', 0, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('barrel', 'barrel', 0, crochet*0.001*8, 'cubeOut')

        perlinXRange = 0.1
        perlinYRange = 0.1
        perlinZRange = 5
        perlinSpeed = 1.3
    end

    if curStep == 512 or curStep == 576 or curStep == 704 then 
        triggerEvent('screen shake', (crochet*0.001*24)..',0.005', (crochet*0.001*24)..',0.005')
    end

    if curStep == 752 then 
        tweenShaderProperty('bloom2', 'effect', 0.25, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('bloom2', 'strength', 4, crochet*0.001*16, 'cubeIn')
    elseif curStep == 768 then 
        tweenShaderProperty('bloom2', 'effect', 0, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('bloom2', 'strength', 0, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('scanline', 'strength', 1, crochet*0.001*1, 'cubeOut')
        tweenShaderProperty('caBlue', 'strength', 0.003, crochet*0.001*1, 'cubeOut')
        perlinXRange = 0.04
        perlinYRange = 0.04
        perlinZRange = 1
        perlinSpeed = 0.7
    end
    if curStep == 1008 then 
        tweenShaderProperty('bloom2', 'effect', 0.25, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('bloom2', 'strength', 4, crochet*0.001*16, 'cubeIn')
    elseif curStep == 1024 then 
        tweenShaderProperty('bloom2', 'effect', 0, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('bloom2', 'strength', 0, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('scanline', 'strength', 0, crochet*0.001*1, 'cubeOut')
        tweenShaderProperty('caBlue', 'strength', 0, crochet*0.001*1, 'cubeOut')
    end

    if curStep == 1504 then 
        tweenShaderProperty('sobel', 'strength', 1, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('mirror2', 'zoom', 3, crochet*0.001*16, 'cubeIn')
        --tweenShaderProperty('barrel', 'barrel', -3, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1520 then 
        tweenShaderProperty('sobel', 'strength', 0, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('mirror2', 'zoom', 1, crochet*0.001*16, 'cubeIn')
        --tweenShaderProperty('barrel', 'barrel', 0, crochet*0.001*16, 'cubeIn')
        --tweenShaderProperty('bloom2', 'effect', 0.5, crochet*0.001*16, 'cubeIn')
        --tweenShaderProperty('bloom2', 'strength', 6, crochet*0.001*16, 'cubeIn')
    elseif curStep == 1536 then 
        --triggerEvent('change character', 'boyfriend', 'Wiik3BFOnii')
        --flashCamera('game', '#FFFFFF', crochet*0.001*16, true)
        tweenShaderProperty('bloom2', 'effect', 0, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('bloom2', 'strength', 0, crochet*0.001*8, 'cubeOut')
        perlinXRange = 0.15
        perlinYRange = 0.15
        perlinZRange = 7
        perlinSpeed = 2
    end


    if curStep >= 1536 and curStep < 1664 then 
        if curStep % 16 == 0 then 
            triggerEvent('screen shake', (crochet*0.001*12)..',0.005', (crochet*0.001*12)..',0.005')
        end
    end
    if curStep == 1776 then 
        tweenShaderProperty('bloom2', 'effect', 0.25, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('bloom2', 'strength', 4, crochet*0.001*16, 'cubeIn')
    elseif curStep == 1792 then 
        tweenShaderProperty('bloom2', 'effect', 0, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('bloom2', 'strength', 0, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('scanline', 'strength', 1, crochet*0.001*1, 'cubeOut')
        tweenShaderProperty('caBlue', 'strength', 0.003, crochet*0.001*1, 'cubeOut')
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        perlinXRange = 0.04
        perlinYRange = 0.04
        perlinZRange = 1
        perlinSpeed = 0.7
    end
    if curStep == 2048 then 
        tweenShaderProperty('caBlue', 'strength', 0, crochet*0.001*1, 'cubeOut')

        tweenActorProperty('camGame', 'alpha', 0, crochet*0.001*16*4, 'cubeIn')
    end
end

function doZoomOnStep(step)
    if curStep == step then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
    elseif curStep == step-4 then 
        tweenShaderProperty('mirror', 'zoom', 0.8, crochet*0.001*4, 'cubeIn')
    end
end

function bloomBurst()
    setShaderProperty('bloom2', 'effect', 0.25)
    setShaderProperty('bloom2', 'strength', 3)
    tweenShaderProperty('bloom2', 'effect', 0, crochet*0.001*16, 'cubeOut')
    tweenShaderProperty('bloom2', 'strength', 0, crochet*0.001*16, 'cubeOut')
end