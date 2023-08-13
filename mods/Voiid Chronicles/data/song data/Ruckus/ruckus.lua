local defaultCamZoom = 1
function start()
    defaultCamZoom = getProperty('camGame', 'zoom')
    --setSongPosition('156000')
end
function createPost()
    
    initShader('smoke', 'PerlinSmokeEffect')
    setCameraShader('game', 'smoke')

    initShader('greyscale', 'GreyscaleEffect')
    setCameraShader('game', 'greyscale')
    setCameraShader('hud', 'greyscale')
    setShaderProperty('greyscale', 'strength', 1)

    initShader('blur', 'BlurEffect')
    setCameraShader('game', 'blur')
    setCameraShader('hud', 'blur')
    setShaderProperty('blur', 'strength', 7)

    initShader('bloom2', 'BloomEffect')
    setCameraShader('game', 'bloom2')
    setCameraShader('hud', 'bloom2')

    setShaderProperty('bloom2', 'effect', 0)
    setShaderProperty('bloom2', 'strength', 0)

    initShader('ca', 'ChromAbEffect')
    setCameraShader('game', 'ca')
    setCameraShader('hud', 'ca')
    setShaderProperty('ca', 'strength', 0.004)

    initShader('mirror', 'MirrorRepeatEffect')
	setCameraShader('game', 'mirror')
    setShaderProperty('mirror', 'zoom', 1)
    setShaderProperty('mirror', 'angle', -30)

    initShader('scanline', 'ScanlineEffect')
    setCameraShader('hud', 'scanline')
    setShaderProperty('scanline', 'strength', 1)
    setShaderProperty('scanline', 'pixelsBetweenEachLine', 10)

    --setCameraShader('hud', 'smoke')
    setShaderProperty('smoke', 'waveStrength', 0.02)

    makeSprite('black', '', 0, 0, 1)
    setObjectCamera('black', 'hud')
    makeGraphic('black', 4000, 2000, '0xFF000000')
    actorScreenCenter('black')
    setActorAlpha(1, 'black')
    if opponentPlay then 
        setActorAlpha(0, 'black')
    end
end
function stepHit()
    local section = math.floor(curStep/16)
    if section >= 140 and section < 155 then
        if section % 2 == 0 then
            if curStep % 16 == 0 or curStep % 16 == 6 or curStep % 16 == 12 then 
                tweenShaderProperty('mirror', 'zoom', 1.3, crochet*0.001*3, 'cubeIn')
            elseif curStep % 16 == 3 or curStep % 16 == 9 or curStep % 16 == 15 then 
                tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*3, 'cubeOut')
            end
        end

        if curStep % 16 == 0 then 
            setShaderProperty('bloom2', 'effect', 0.25)
            setShaderProperty('bloom2', 'strength', 3)
            tweenShaderProperty('bloom2', 'effect', 0, crochet*0.001*16, 'cubeOut')
            tweenShaderProperty('bloom2', 'strength', 0, crochet*0.001*16, 'cubeOut')
        end

    end
    if curStep == 64 then 
        tweenShaderProperty('blur', 'strength', 0, crochet*0.001*16*2, 'cubeOut')
    elseif curStep == 112 then 
        tweenShaderProperty('mirror', 'zoom', 3, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('blur', 'strength', 6, crochet*0.001*8, 'cubeOut')
        tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*16, 'cubeIn')
    elseif curStep == 112+8 then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'cubeIn')
        tweenShaderProperty('blur', 'strength', 0, crochet*0.001*8, 'cubeIn')
    elseif curStep == 112+16 then 
        bloomBurst()
        setShaderProperty('scanline', 'strength', 0)
    end
    if curStep == 256 or curStep == 1344 or curStep == 1472 then 
        bloomBurst()
    end

    if curStep == 368 or curStep == 1584 then 
        tweenShaderProperty('mirror', 'zoom', 2, crochet*0.001*8, 'cubeOut')
    elseif curStep == 368+8 or curStep == 1584+8 then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'cubeIn')
        tweenShaderProperty('mirror', 'angle', -25, crochet*0.001*8, 'cubeIn')
    elseif curStep == 368+16 or curStep == 1584+16 then 
        bloomBurst()
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*8, 'cubeOut')
    end
    if section == 31 or section == 107 or section == 139 then 
        if curStep % 4 == 0 then 
            setShaderProperty('ca', 'strength', 0.005)
            setShaderProperty('blur', 'strength', 6)
            tweenShaderProperty('blur', 'strength', 0, crochet*0.001*3, 'cubeIn')
        end
    end
    if curStep == 512 or curStep == 640 or curStep == 1728 or curStep == 1856 then 
        setShaderProperty('scanline', 'strength', 1)
        setShaderProperty('bloom2', 'effect', 0.25)
        setShaderProperty('bloom2', 'strength', 3)
        tweenShaderProperty('bloom2', 'effect', 0, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('bloom2', 'strength', 0, crochet*0.001*16, 'cubeOut')
    end




    if curStep == 1200 then 
        tweenShaderProperty('mirror', 'zoom', 2, crochet*0.001*8, 'cubeOut')
    elseif curStep == 1200+8 then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'cubeIn')
    elseif curStep == 1200+16 then 
        setShaderProperty('greyscale', 'strength', 0)
        bloomBurst()
        setShaderProperty('scanline', 'strength', 0)
    end

    funnySection(curStep)
    if curStep < 2240 then 
        funnySection(curStep-1216)
    end

    if curStep == 2240 then 
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        --bloomBurst()
        setShaderProperty('scanline', 'strength', 1)
        setShaderProperty('blur', 'strength', 0.5)
    end

    if curStep == 2480 then 
        tweenShaderProperty('mirror', 'zoom', 2, crochet*0.001*8, 'cubeOut')
    elseif curStep == 2480+8 then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'cubeIn')
    elseif curStep == 2480+16 then 
        bloomBurst()
        setShaderProperty('scanline', 'strength', 0)
    end
    

end

function funnySection(step)
    if step == 752 then 
        tweenShaderProperty('mirror', 'zoom', 1.5, crochet*0.001*4, 'cubeOut')
    elseif step == 752+8 then 
        setShaderProperty('scanline', 'strength', 0)
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*4, 'cubeOut')
    elseif step == 768 then 
        tweenShaderProperty('blur', 'strength', 2, crochet*0.001*4, 'cubeOut')
        bloomBurst()
        setShaderProperty('mirror', 'angle', 45)
        setShaderProperty('greyscale', 'strength', 0)
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*8, 'cubeOut')
    elseif step == 776 then 
        tweenShaderProperty('mirror', 'zoom', 1.5, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*4, 'cubeOut')
    elseif step == 776+4 then 
        tweenShaderProperty('mirror', 'zoom', 0.8, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('mirror', 'angle', -40, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*4, 'cubeIn')
    elseif step == 776+8 then 
        bloomBurst()
        tweenShaderProperty('mirror', 'zoom', 1.5, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*4, 'cubeIn')
    elseif step == 776+12 then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
    elseif step == 776+16 then 
        tweenShaderProperty('mirror', 'zoom', 2, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirror', 'angle', 35, crochet*0.001*4, 'cubeOut')
    elseif step == 776+20 then
        bloomBurst() 
        tweenShaderProperty('mirror', 'zoom', 1.4, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirror', 'angle', 15, crochet*0.001*4, 'cubeOut')
    elseif step == 800 then 
        tweenShaderProperty('mirror', 'zoom', 0.8, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
        triggerEvent('screen shake', (crochet*0.001*8)..',0.005', (crochet*0.001*8)..',0.005')
    elseif step == 808 or step == 808+8 then 
        tweenShaderProperty('mirror', 'zoom', 1.5, crochet*0.001*4, 'cubeIn')
    elseif step == 812 or step == 812+8 then 
        bloomBurst()
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
    end
    if step == 840 then 
        tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*4, 'cubeOut')
    elseif step == 848 then 
        tweenShaderProperty('mirror', 'zoom', 3, crochet*0.001*16, 'cubeInOut')
        tweenShaderProperty('mirror', 'angle', -360, crochet*0.001*18, 'cubeIn')
    elseif step == 864 or step == 880 then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
        bloomBurst()
        setShaderProperty('greyscale', 'strength', 0)
    elseif step == 888 then 
        tweenShaderProperty('mirror', 'zoom', 0.6, crochet*0.001*4, 'cubeOut')
    elseif step == 904 then 
        
        bloomBurst()
        setShaderProperty('greyscale', 'strength', 1)
        setShaderProperty('mirror', 'angle', -45)
        setShaderProperty('mirror', 'zoom', 2)
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*8, 'cubeIn')
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'cubeIn')
    elseif step == 912 then 
        bloomBurst()
        setShaderProperty('greyscale', 'strength', 0)
        
    elseif step == 928 then 
        bloomBurst()
        tweenShaderProperty('mirror', 'zoom', 0.7, crochet*0.001*4, 'cubeOut')
        triggerEvent('screen shake', (crochet*0.001*12)..',0.005', (crochet*0.001*12)..',0.005')
    elseif step == 940 then 
        setShaderProperty('greyscale', 'strength', 1)
    elseif step == 940+4 then 
        bloomBurst()
        setShaderProperty('greyscale', 'strength', 0)
        tweenShaderProperty('mirror', 'zoom', 1.7, crochet*0.001*4, 'cubeOut')
        triggerEvent('screen shake', (crochet*0.001*12)..',0.005', (crochet*0.001*12)..',0.005')
    elseif step == 968 then 
        setShaderProperty('greyscale', 'strength', 1)
        tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
    end

    if step == 992 then 
        tweenShaderProperty('mirror', 'angle', -45, crochet*0.001*12, 'expoIn')
    elseif step == 992+12 then 
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirror', 'zoom', 1.7, crochet*0.001*4, 'cubeOut')
    elseif step == 992+16 then 
        tweenShaderProperty('mirror', 'angle', 45, crochet*0.001*16, 'expoIn')
    elseif step == 992+32 then 
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*4, 'cubeOut')
        setShaderProperty('greyscale', 'strength', 1)
        bloomBurst()
        setShaderProperty('scanline', 'strength', 1)
        setShaderProperty('blur', 'strength', 0)
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


function songStart()
    tweenShaderProperty('blur', 'strength', 2, crochet*0.001*16*2, 'cubeOut')
    tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*16*2, 'cubeOut')
    tweenActorProperty('black', 'alpha', 0, crochet*0.001*16*4, 'cubeOut')
end