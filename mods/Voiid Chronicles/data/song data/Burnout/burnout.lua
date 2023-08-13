local doNoteTrail = false
function createPost()

    initShader('greyscale', 'GreyscaleEffect')
    setCameraShader('game', 'greyscale')
    setCameraShader('hud', 'greyscale')
    setShaderProperty('greyscale', 'strength', 1)

    initShader('bloom2', 'BloomEffect')
    setCameraShader('game', 'bloom2')
    setCameraShader('hud', 'bloom2')

    setShaderProperty('bloom2', 'effect', 0)
    setShaderProperty('bloom2', 'strength', 0)

    initShader('pixel', 'MosaicEffect')
    setCameraShader('game', 'pixel')
    
    setShaderProperty('pixel', 'strength', 0)

    initShader('mirror', 'MirrorRepeatEffect')
    initShader('mirror2', 'MirrorRepeatEffect')
	setCameraShader('game', 'mirror')
    setCameraShader('game', 'mirror2')
    if modcharts then 
        setCameraShader('hud', 'pixel')

        setCameraShader('hud', 'mirror')
        setCameraShader('hud', 'mirror2')
        
    end
	
    setShaderProperty('mirror', 'zoom', 0.5)
    setShaderProperty('mirror2', 'zoom', 1)
    setShaderProperty('mirror', 'angle', -45)

    initShader('vignette', 'VignetteEffect')
    setCameraShader('hud', 'vignette')
    setCameraShader('game', 'vignette')
    setShaderProperty('vignette', 'strength', 10)
    setShaderProperty('vignette', 'size', 0.5)
    
    makeSprite('black', '', 0, 0, 1)
    setObjectCamera('black', 'hud')
    makeGraphic('black', 4000, 2000, '0xFF000000')
    actorScreenCenter('black')
    setActorAlpha(1, 'black')

end
local bursts = {
    128,
    256,
    512,
    656,
    662,
    704,
    768,
    896,
    1024,
    1280,
    1408,
    1424,
    1430,
    1472,
    1520,
    1664
}
local tilts = {
    {656, 20},
    {662, -20},
    {1424, 20},
    {1430, -20}
}

local arrowSpins = {
    {128, 360},
    {192, -360},
    {256, 360},
    {320, -360},
    {512, 360},
    {544, -360},
    {640, 360},
    {672, -360},
    {896, 360},
    {960, -360},
    {1024, 360},
    {1088, -360},
    {1280, 360},
    {1312, -360},
    {1408, 360},
    {1440, -360},
    {1536, 360},
    {1568, -360},
    {1600, 360},
    {1632, -360},
    {1664, 360},
}
local shakes = {
    616,744,1384
}
function stepHit()

    doNoteTrail = false
    if modcharts then 
        if (curStep >= 614 and curStep < 638) or (curStep >= 655 and curStep < 657) or (curStep >= 661 and curStep < 663) 
        or (curStep >= 743 and curStep < 769) or (curStep >= 1383 and curStep < 1406) 
        or (curStep >= 1423 and curStep < 1425) or (curStep >= 1429 and curStep < 1431) or (curStep >= 1520) then 
        doNoteTrail = true
        end
    end


    local section = math.floor(curStep/16)

    if section > 0 and section < 92 then 
        if curStep % 32 == 0 then 
            tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        elseif curStep % 32 == 28 then 
            tweenShaderProperty('mirror', 'zoom', 0.95, crochet*0.001*4, 'cubeIn')
        end

        if curStep % 32 == 20 then 
            tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        elseif curStep % 32 == 16 then 
            tweenShaderProperty('mirror', 'zoom', 0.95, crochet*0.001*4, 'cubeIn')
        end
    end

    if curStep == 240 or curStep == 1008 then 
        tweenShaderProperty('mirror2', 'zoom', 0.9, crochet*0.001*16, 'cubeIn')
    elseif curStep == 240+16 or curStep == 1008+16 then 
        tweenShaderProperty('mirror2', 'zoom', 1, crochet*0.001*4, 'cubeOut')
    end
    if curStep == 496 or curStep == 1264 then 
        tweenShaderProperty('mirror2', 'zoom', 0.9, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('mirror2', 'angle', 45, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('pixel', 'strength', 45, crochet*0.001*16, 'cubeIn')
    elseif curStep == 496+16 or curStep == 1264+16 then 
        tweenShaderProperty('mirror2', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirror2', 'angle', 0, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('pixel', 'strength', 0, crochet*0.001*4, 'cubeOut')
    end

    if curStep == 624 or curStep == 1392 then 
        tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*16, 'cubeOut')
    elseif curStep == 624+16 or curStep == 1392+16 then
        tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*2, 'cubeOut')
    end

    if curStep == 752 then 
        tweenShaderProperty('mirror2', 'angle', 60, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*16, 'cubeOut')
    elseif curStep == 752+16 then 
        tweenShaderProperty('mirror2', 'angle', 0, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*64, 'cubeIn')
    end

    for i = 1, #bursts do 
        if curStep == bursts[i] then 
            bloomBurst()
        end
    end
    for i = 1, #tilts do 
        if curStep == tilts[i][1]-2 then 
            tweenShaderProperty('mirror', 'angle', tilts[i][2], crochet*0.001*2, 'cubeIn')
        elseif curStep == tilts[i][1] then 
            tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*3, 'cubeOut')
        end
    end

    if curStep == 1504 then 
        tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*16, 'cubeIn')
    elseif curStep == 1648 then
        tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*16, 'cubeOut')
    end

    if modcharts then 

        if curStep == 768 or curStep == 1664 then 
            for i = 0, (keyCount+playerKeyCount)-1 do 
                setActorVelocityX(((math.random()*2)-1)*200, i) --explodey
                setActorVelocityY((math.random()*-300)-200, i)
                setActorAccelerationY(800, i)
            end
            setProperty('noteBG', 'visible', false)
        elseif curStep == 864 then
            for i = 0, (keyCount+playerKeyCount)-1 do 
                setActorVelocityX(0, i)
                setActorVelocityY(0, i)
                setActorAccelerationY(0, i)
                tweenActorProperty(i, 'x', _G["defaultStrum"..i..'X'], crochet*0.001*32, 'expoOut')
                tweenActorProperty(i, 'y', _G["defaultStrum"..i..'Y'], crochet*0.001*32, 'expoOut')
            end
            setProperty('noteBG', 'visible', true)
        end

        for i = 1, #arrowSpins do 
            if curStep == arrowSpins[i][1] then 
                for j = 0, (keyCount+playerKeyCount)-1 do
                    tweenActorProperty(j, 'modAngle', arrowSpins[i][2], crochet*0.001*16, 'expoOut')
                end
            
            elseif curStep == arrowSpins[i][1]+17 then
                for j = 0, (keyCount+playerKeyCount)-1 do 
                    setActorModAngle(0, j) --reset
                end
            end
        end

        for i = 1, #shakes do 
            if curStep == shakes[i] then 
                for j = 0, (keyCount+playerKeyCount)-1 do
                    tweenActorProperty(j, 'x', _G["defaultStrum"..j..'X']+30, crochet*0.001*2, 'expoOut')
                end
            elseif curStep == shakes[i]+2 then
                for j = 0, (keyCount+playerKeyCount)-1 do
                    tweenActorProperty(j, 'x', _G["defaultStrum"..j..'X']-30, crochet*0.001*2, 'expoOut')
                end
            elseif curStep == shakes[i]+4 then
                for j = 0, (keyCount+playerKeyCount)-1 do
                    tweenActorProperty(j, 'x', _G["defaultStrum"..j..'X']+30, crochet*0.001*2, 'expoOut')
                end
            elseif curStep == shakes[i]+6 then
                for j = 0, (keyCount+playerKeyCount)-1 do
                    tweenActorProperty(j, 'x', _G["defaultStrum"..j..'X']-30, crochet*0.001*2, 'expoOut')
                end
            elseif curStep == shakes[i]+8 then
                for j = 0, (keyCount+playerKeyCount)-1 do
                    tweenActorProperty(j, 'x', _G["defaultStrum"..j..'X'], crochet*0.001*2, 'expoOut')
                end
            end
        end

    end
end




function songStart()
    setActorAlpha(0, 'black')
    tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*16, 'cubeOut')
    tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*12, 'cubeOut')

    tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*16*6, 'cubeIn')
end

function doZoomOnStep(s)
    if curStep == s-4 then
        tweenShaderProperty('mirror', 'zoom', 0.9, crochet*0.001*4, 'cubeIn')
    elseif curStep == s then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
    end
end
function bloomBurst()
    setShaderProperty('bloom2', 'effect', 0.25)
    setShaderProperty('bloom2', 'strength', 3)
    setShaderProperty('ca', 'strength', 0.005)
    tweenShaderProperty('bloom2', 'effect', 0, crochet*0.001*16, 'cubeOut')
    tweenShaderProperty('bloom2', 'strength', 0, crochet*0.001*16, 'cubeOut')
    tweenShaderProperty('ca', 'strength', 0, crochet*0.001*16, 'cubeOut')
end
local noteTrailCount = 0
local noteTrailCap = 50
function playerOneSingExtra(data, id, noteType, isSus)
    if not isSus and doNoteTrail then 
        makeNoteTrail(data, id, noteType)
    end
end
function playerTwoSingExtra(data, id, noteType, isSus)
    if not isSus and doNoteTrail then 
        makeNoteTrail(data, id, noteType)
    end
end

function makeNoteTrail(data, id, noteType)

    local trail = 'noteTrail'..noteTrailCount

    local yVal = 150
    if not downscrollBool then 
        yVal = yVal * -1
    end

    destroySprite(trail)
    makeNoteCopy(trail, id)
    setActorAlpha(0.6, trail)
    tweenActorProperty(trail, 'y', getActorY(trail)+yVal, crochet*0.001*16, 'linear')
    tweenActorProperty(trail, 'alpha', 0, crochet*0.001*16, 'expoInOut')

    setObjectCamera(trail, 'hud')

    noteTrailCount = noteTrailCount + 1
    if noteTrailCount > noteTrailCap then 
        noteTrailCount = 0
    end
end