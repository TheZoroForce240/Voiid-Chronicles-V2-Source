function createPost()

    initShader('greyscale', 'GreyscaleEffect')
    setCameraShader('game', 'greyscale')
    setCameraShader('hud', 'greyscale')
    setShaderProperty('greyscale', 'strength', 1)

    initShader('blur', 'BlurEffect')
    setCameraShader('game', 'blur')
    setCameraShader('hud', 'blur')
    setShaderProperty('blur', 'strength', 1)

    initShader('bloom2', 'BloomEffect')
    setCameraShader('game', 'bloom2')
    setCameraShader('hud', 'bloom2')

    setShaderProperty('bloom2', 'effect', 0)
    setShaderProperty('bloom2', 'strength', 0)

    initShader('ca', 'ChromAbEffect')
    setCameraShader('game', 'ca')
    setCameraShader('hud', 'ca')
    setShaderProperty('ca', 'strength', 0.001)


    initShader('mirror', 'MirrorRepeatEffect')
    initShader('mirrorHUD', 'MirrorRepeatEffect')
	setCameraShader('game', 'mirror')
    if modcharts then 
        setCameraShader('hud', 'mirrorHUD')
    end
	
    setShaderProperty('mirror', 'zoom', 1)
    setShaderProperty('mirrorHUD', 'zoom', 1)

    initShader('scanline', 'ScanlineEffect')
    setCameraShader('hud', 'scanline')
    setShaderProperty('scanline', 'strength', 0)

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



    --setShaderProperty('bloom2', 'contrast', -1)
    --setCameraShader('hud', 'rain')

    --setProperty('camGame', 'alpha', 0)
    --setProperty('camHUD', 'alpha', 0)

end
local tilts = {
    {}
}
local zooms = {
    {}
}
function stepHit()
    if curStep == 1 then 
        tweenActorProperty('black', 'alpha', 0, crochet*0.001*16*13.6, 'expoInOut')
        --tweenActorProperty('camHUD', 'alpha', 1, crochet*0.001*16*13.6, 'expoIn')
        tweenShaderProperty('blur', 'strength', 1, crochet*0.001*16*13.6, 'expoInOut')
    elseif curStep == 272 then 
        tweenActorProperty('black', 'alpha', 0, crochet*0.001*16*3, 'expoInOut')
        tweenShaderProperty('mirror', 'angle', -5, crochet*0.001*16*3, 'linear')
        tweenShaderProperty('mirrorHUD', 'angle', -5, crochet*0.001*16*3, 'linear')
    end
    if curStep == 234 then 
        tweenActorProperty('black', 'alpha', 1, crochet*0.001*8, 'expoInOut')
    end

    if curStep == 320 then 
        tilt(-15)
        bloomBurst()
        setShaderProperty('greyscale', 'strength', 0)
        setShaderProperty('ca', 'strength', 0)
        setShaderProperty('blur', 'strength', 0)
    end

    local section = math.floor(curStep/16)

    if (section >= 20 and section < 52) or (section >= 68 and section < 100) then 
        if curStep % 16 == 14 then 
            tweenShaderProperty('mirror', 'zoom', 0.85, crochet*0.001*2, 'cubeIn')
            tweenShaderProperty('mirrorHUD', 'zoom', 0.85, crochet*0.001*2, 'cubeIn')
        elseif curStep % 16 == 0 then 
            tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
            tweenShaderProperty('mirrorHUD', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        end
    end

    --probably not the best way of designing a modchart but i wanted to try it at least
    doTiltOnStep(348, 15)
    doTiltOnStep(352, -15)
    doZoomOnStep(380)
    doTiltOnStep(408, 15)
    doTiltOnStep(408+4, -15)
    doTiltOnStep(408+8, 15)
    doZoomOnStep(422)
    doZoomOnStep(422+6)
    doZoomOnStep(444)
    doTiltOnStep(464, 15)
    doTiltOnStep(464+12, 15)
    doTiltOnStep(464+16, -15)
    doZoomOnStep(508)
    doTiltOnStep(536, 15)
    doTiltOnStep(544, -15)
    doZoomOnStep(556)
    doZoomOnStep(572)
    doBurstOnStep(576)
    doZoomOnStep(604)
    doTiltOnStep(608, 15)
    doTiltOnStep(608+8, -15)
    doTiltOnStep(608+16, 15)
    doTiltOnStep(608+8+16, -15)

    doTiltOnStep(668, 15)
    doTiltOnStep(668+4, -20)
    doTiltOnStep(668+10, 20)
    doTiltOnStep(668+16, -20)
    doZoomOnStep(700)

    doTiltOnStep(728, 15)
    doTiltOnStep(728+8, -15)

    doTiltOnStep(764, -15)
    doTiltOnStep(764+4, 15)

    doTiltOnStep(792, -15)

    doZoomOnStep(812)

    if curStep == 816 then 
        tweenShaderProperty('mirror', 'zoom', 1.7, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('mirrorHUD', 'zoom', 1.7, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('greyscale', 'strength', 0.5, crochet*0.001*16, 'cubeOut')
    elseif curStep == 816+16 then 
        tilt(-20)
        setShaderProperty('bloom2', 'effect', 0.2)
        setShaderProperty('bloom2', 'strength', 2)
        setShaderProperty('ca', 'strength', 0.004)
        tweenShaderProperty('bloom2', 'effect', 0, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('bloom2', 'strength', 0, crochet*0.001*16, 'cubeOut')
        setShaderProperty('scanline', 'strength', 1)
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('mirrorHUD', 'zoom', 1, crochet*0.001*16, 'cubeOut')
    end

    if curStep == 1584 then 
        tweenShaderProperty('mirror', 'zoom', 1.7, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('mirrorHUD', 'zoom', 1.7, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*16, 'cubeOut')
    elseif curStep == 1584+16 then 
        tilt(-20)
        setShaderProperty('ca', 'strength', 0.01)
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('mirrorHUD', 'zoom', 1, crochet*0.001*16, 'cubeOut')
    elseif curStep == 1728 then 
        tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*16*6, 'cubeIn')
        tweenShaderProperty('ca', 'strength', 0, crochet*0.001*16*6, 'cubeIn')
    end

    doTiltOnStep(876, -15)
    doTiltOnStep(876+4, 15)

    doTiltOnStep(936, -15)
    doTiltOnStep(936+16, 15)

    doTiltOnStep(984, -15)

    doTiltOnStep(1020, -15)
    doTiltOnStep(1020+4, 15)

    doZoomOnStep(1116)

    doTiltOnStep(1120, -15)
    doTiltOnStep(1120+8, 15)
    doTiltOnStep(1120+16, -15)
    doTiltOnStep(1120+8+16, 15)

    doTiltOnStep(1180, -15)
    doTiltOnStep(1180+4, 15)
    doTiltOnStep(1180+4+6, -15)
    doTiltOnStep(1180+4+12, 15)

    doZoomOnStep(1212)

    doTiltOnStep(1240, 15)
    doTiltOnStep(1240+8, -15)

    
    doTiltOnStep(1276, -15)
    doTiltOnStep(1276+4, 15)

    doTiltOnStep(1304, -15)

    doZoomOnStep(1324)
    doZoomOnStep(1340)

    doTiltOnStep(1372, 15)
    doTiltOnStep(1372+4, -15)

    doZoomOnStep(1404)

    doTiltOnStep(1432, -15)
    doTiltOnStep(1432+4, 15)
    doTiltOnStep(1432+8, -15)

    doZoomOnStep(1446)
    doZoomOnStep(1452)
    doZoomOnStep(1468)

    doTiltOnStep(1488, 15)
    doTiltOnStep(1488+12, -15)
    doTiltOnStep(1488+16, 15)

    doZoomOnStep(1532)

    doTiltOnStep(1560, 15)
    doTiltOnStep(1560+8, -15)

    doZoomOnStep(1580)

    doTiltOnStep(1720, 15)

    doTiltOnStep(1744, -15)
    doTiltOnStep(1744+8, 15)
    doTiltOnStep(1744+16+8, -15)

    if curStep == 1056 then 
        tweenShaderProperty('mirror', 'zoom', 3, crochet*0.001*32, 'cubeIn')
        tweenShaderProperty('mirrorHUD', 'zoom', 3, crochet*0.001*32, 'cubeIn')
    elseif curStep == 1056+32 then 
        bloomBurst()
        setShaderProperty('scanline', 'strength', 0)
        setShaderProperty('greyscale', 'strength', 0)
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirrorHUD', 'zoom', 1, crochet*0.001*4, 'cubeOut')
    end

    if curStep == 1824 then 
        tweenShaderProperty('mirror', 'zoom', 3, crochet*0.001*32, 'cubeIn')
        tweenShaderProperty('mirrorHUD', 'zoom', 3, crochet*0.001*32, 'cubeIn')
        tweenShaderProperty('blur', 'strength', 30, crochet*0.001*32, 'cubeIn')
    elseif curStep == 1824+32 then 
        bloomBurst()
        setShaderProperty('scanline', 'strength', 1)
        setShaderProperty('ca', 'strength', 0.004)
        setShaderProperty('greyscale', 'strength', 0)
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirrorHUD', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('blur', 'strength', 0, crochet*0.001*4, 'cubeOut')
    end

    if (section >= 116 and section < 148) then 
        if curStep < 2360 then 
            if curStep % 16 == 14 then 
                tweenShaderProperty('mirror', 'zoom', 0.75, crochet*0.001*2, 'cubeIn')
                tweenShaderProperty('mirrorHUD', 'zoom', 0.75, crochet*0.001*2, 'cubeIn')
            elseif curStep % 16 == 0 then
                bloomBurst()
                tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
                tweenShaderProperty('mirrorHUD', 'zoom', 1, crochet*0.001*4, 'cubeOut')
            end
        end


        --[[if curStep % 128 > 32 then 
            if curStep % 32 < 16 then 
                if curStep % 16 == 4 then 
                    tweenShaderProperty('mirror', 'zoom', 0.85, crochet*0.001*1, 'cubeIn')
                elseif curStep % 6 == 0 then
                    tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*3, 'cubeOut')
                end
                if curStep % 16 == 10 then 
                    tweenShaderProperty('mirror', 'zoom', 0.85, crochet*0.001*1, 'cubeIn')
                elseif curStep % 12 == 0 then
                    tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*3, 'cubeOut')
                end
            else 
                if curStep % 16 == 12 then 
                    triggerEvent('add camera zoom', 0.1, 0.1)
                end
                if curStep % 128 < 64 then
                    if curStep % 16 == 14 then 
                        triggerEvent('add camera zoom', 0.1, 0.1)
                    end
                end
            end
        end]]--
    end


    doTiltOnStep(1856-4, -15)
    doTiltOnStep(1856, 15)
    doTiltOnStep(1856+6, -15)
    doTiltOnStep(1856+12, 15)
    doTiltOnStep(1856+16, -15)

    doTiltOnStep(1888-4, -15)
    doTiltOnStep(1888, 15)
    doTiltOnStep(1888+6, -15)
    doTiltOnStep(1888+12, 15)
    doTiltOnStep(1888+16, -15)

    doTiltOnStep(1920-4, -15)
    doTiltOnStep(1920, 15)

    doTiltOnStep(1936, -15)
    doTiltOnStep(1936+8, 15)
    doTiltOnStep(1936+16, -15)

    doZoomOnStep(1952+6)
    doZoomOnStep(1952+12)

    doTiltOnStep(1968, -15)
    doTiltOnStep(1968+8, 15)

    doZoomOnStep(1980)




    --doTiltOnStep(1984-4, -15)
    doTiltOnStep(1984, 15)
    doTiltOnStep(1984+6, -15)
    doTiltOnStep(1984+12, 15)
    doTiltOnStep(1984+16, -15)

    doTiltOnStep(2016-4, -15)
    doTiltOnStep(2016, 15)
    doTiltOnStep(2016+6, -15)
    doTiltOnStep(2016+12, 15)
    doTiltOnStep(2016+16, -15)

    doTiltOnStep(2048-4, -15)
    doTiltOnStep(2048, 15)

    
    doTiltOnStep(2064, -15)
    doTiltOnStep(2064+8, 15)
    doTiltOnStep(2064+16, -15)

    doZoomOnStep(2080+6)
    doZoomOnStep(2080+12)

    doTiltOnStep(2096, -15)
    doTiltOnStep(2096+8, 15)
    doZoomOnStep(2096+12)

    doZoomOnStep(2112+6)
    doZoomOnStep(2112+12)
    doZoomOnStep(2112+16+12)

    doZoomOnStep(2144+6)
    doZoomOnStep(2144+12)
    doZoomOnStep(2144+16+12)

    doZoomOnStep(2208+6)
    doZoomOnStep(2208+12)
    doZoomOnStep(2208+16+12)

    doZoomOnStep(2240+6)
    doZoomOnStep(2240+12)
    doZoomOnStep(2240+16+12)

    doZoomOnStep(2272+6)
    doZoomOnStep(2272+12)
    doZoomOnStep(2272+16+12)

    
    doZoomOnStep(2336+6)
    doZoomOnStep(2336+12)
    --doZoomOnStep(2336+16+12)


    if curStep == 2352 then 
        tweenShaderProperty('mirror', 'zoom', 1.7, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('mirrorHUD', 'zoom', 1.7, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('blur', 'strength', 30, crochet*0.001*16, 'cubeIn')
    elseif curStep == 2352+16 then 
        tilt(-20)
        setShaderProperty('scanline', 'strength', 0)
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('mirrorHUD', 'zoom', 1, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('blur', 'strength', 1, crochet*0.001*4, 'cubeOut')
    end

end
function doZoomOnStep(s)
    if curStep == s-1 then
        tweenShaderProperty('mirror', 'zoom', 0.85, crochet*0.001*1, 'cubeIn')
        tweenShaderProperty('mirrorHUD', 'zoom', 0.85, crochet*0.001*1, 'cubeIn')
    elseif curStep == s then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*3, 'cubeOut')
        tweenShaderProperty('mirrorHUD', 'zoom', 1, crochet*0.001*3, 'cubeOut')
    end
end
function doTiltOnStep(s, ang)
    if curStep == s then 
        tilt(ang*2)
    end
end
function doBurstOnStep(s)
    if curStep == s then 
        bloomBurst()
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

function tilt(ang)
    setShaderProperty('mirror', 'angle', ang)
    tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')

    setShaderProperty('mirrorHUD', 'angle', ang)
    tweenShaderProperty('mirrorHUD', 'angle', 0, crochet*0.001*4, 'cubeOut')
end