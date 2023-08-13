function start(song)
    triggerEvent('Add Camera Zoom','0.20','0')
end

function createPost()
    initShader('sobel', 'SobelEffect')
    setCameraShader('game', 'sobel')
    if modcharts then 
		setCameraShader('hud', 'sobel')
	end
    setShaderProperty('sobel', 'strength', 0)
    setShaderProperty('sobel', 'intensity', 3)

    initShader('greyscale', 'GreyscaleEffect')
    setCameraShader('game', 'greyscale')
    setCameraShader('hud', 'greyscale')
    setShaderProperty('greyscale', 'strength', 1)

    initShader('blur', 'BlurEffect')
    setCameraShader('game', 'blur')
    setCameraShader('hud', 'blur')
    setShaderProperty('blur', 'strength', 0)


    initShader('chrom', 'ChromAbEffect')
    setCameraShader('game', 'chrom')
    if modcharts then 
		setCameraShader('hud', 'chrom')
	end

    initShader('color', 'ColorOverrideEffect')
    setCameraShader('game', 'color')
    setCameraShader('hud', 'color')
    setShaderProperty('color', 'red', 0.0)
    setShaderProperty('color', 'green', 0.0)
    setShaderProperty('color', 'blue', 0.0)

    initShader('pixel', 'MosaicEffect')
    setCameraShader('game', 'pixel')
    if modcharts then 
		setCameraShader('hud', 'pixel')
	end
    setShaderProperty('pixel', 'strength', 0)

    initShader('scanline', 'ScanlineEffect')
    setCameraShader('game', 'scanline')
    setCameraShader('hud', 'scanline')
    setShaderProperty('scanline', 'strength', 0)
    setShaderProperty('scanline', 'smooth', true)
    setShaderProperty('scanline', 'pixelsBetweenEachLine', 1)

    initShader('mirror', 'MirrorRepeatEffect')
	setCameraShader('game', 'mirror')
    if modcharts then 
		setCameraShader('hud', 'mirror')
	end
	setShaderProperty('mirror', 'zoom', 0.1)
    setShaderProperty('mirror', 'angle', 45)

    initShader('palette', 'PaletteEffect')
	setCameraShader('game', 'palette')
    if modcharts then 
		setCameraShader('hud', 'palette')
	end
    --setShaderProperty('palette', 'strength', 1)
    --setShaderProperty('raymarch', 'y', 180)


    --setStageColorSwap('hue', 0.1)


    if modcharts then 
        local offscreen = -200
        if downscrollBool then 
            offscreen = 720+200
        end
        for i = 0,7 do 
            setActorY(offscreen, i)
        end
    end

    showOnlyStrums = true

    makeSprite('left', '', -1200, -720, 1)
    setObjectCamera('left', 'hud')
    makeGraphic('left', 160, 720, '0xFF000000')
    actorScreenCenter('left')
    setActorX(-160, 'left')

    makeSprite('right', '', -1200, -720, 1)
    setObjectCamera('right', 'hud')
    makeGraphic('right', 160, 720, '0xFF000000')
    actorScreenCenter('right')
    setActorX(1280, 'right')
end

function playerTwoSing(data, time, type)
    if getHealth() - 0.008 > 0.09 then
        setHealth(getHealth() - 0.008)
    else
        setHealth(0.035)
    end
end

local pixelMode = false

function songStart()
    tweenShaderProperty('color', 'red', 1.0, crochet*0.001*16*16, 'expoOut')
    tweenShaderProperty('color', 'green', 1.0, crochet*0.001*16*16, 'expoOut')
    tweenShaderProperty('color', 'blue', 1.0, crochet*0.001*16*16, 'expoOut')
    tweenShaderProperty('greyscale', 'strength', 0.0, crochet*0.001*16*16, 'expoOut')
    tweenShaderProperty('mirror', 'angle', 0.0, crochet*0.001*16*12, 'expoOut')
    tweenShaderProperty('mirror', 'zoom', 1.0, crochet*0.001*16*12, 'expoOut')
end

local offsetShit = {50, -50}

local offsetStuff = {50,50,50,50,-50,-50,-50,-50}

local offsetShit3 = {200,100,-100,200}

local swap = 1

function stepHit()
    local section = math.floor(curStep/16)
    local secStep = curStep%16
    local doubleSecStep = curStep%32

    if secStep == 0 then 
        sectionHit(section)
    end

    if (section >= 64 and section < 80) or (section >= 96 and section < 110) then 
        if doubleSecStep == 0 or doubleSecStep == 8 then 
            triggerEvent('add camera zoom', 0.2, 0.1)
        end
        if doubleSecStep == 16 or doubleSecStep == 22 or doubleSecStep == 28 then 
            
            if modcharts then 
                for i = 0, 7 do
                    if doubleSecStep == 28 then 
                        tweenActorProperty(i..'', 'modAngle', 0, crochet*0.001*4, 'cubeOut')

                    else 
                        tweenActorProperty(i..'', 'modAngle', offsetStuff[i+1]*-swap, crochet*0.001*4, 'cubeOut')
                    end
                end
            end
            setShaderProperty('chrom', 'strength', 0.02*swap)
            tweenShaderProperty('chrom', 'strength', 0, crochet*0.001*4, 'cubeOut')
            setShaderProperty('mirror', 'angle', 20.0*swap)
            swap = swap * -1
            tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*6, 'expoOut')
            triggerEvent('add camera zoom', 0.2, 0.1)

        end
    end
    if (section >= 112 and section < 120) then 
        if doubleSecStep == 0 or doubleSecStep == 12 or doubleSecStep == 20 then 
            triggerEvent('add camera zoom', 0.2, 0.1)

            
            swap = swap * -1
            setShaderProperty('mirror', 'angle', 30.0*swap)
            tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
            setShaderProperty('chrom', 'strength', 0.01*swap)
            tweenShaderProperty('chrom', 'strength', 0, crochet*0.001*4, 'cubeOut')

            --[[if modcharts then 
                for i = 0, 3 do 
                    setActorX(getActorX(i)+offsetShit[(i%2)+1], i)
                    setActorX(getActorX(i+4)+offsetShit[(i%2)+1], i+4)
                    if middlescroll then 
                        tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"], crochet*0.001*4, 'cubeOut')
                        tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"], crochet*0.001*4, 'cubeOut')
                    else 
                        tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"]+100, crochet*0.001*4, 'cubeOut')
                        tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"]-100, crochet*0.001*4, 'cubeOut')
                    end


                    setActorAngle(getActorAngle(i)+offsetShit[(i%2)+1], i)
                    setActorAngle(getActorAngle(i+4)+offsetShit[(i%2)+1], i+4)
                    tweenActorProperty(i, 'angle', 0, crochet*0.001*4, 'expoOut')
                    tweenActorProperty(i+4, 'angle', 0, crochet*0.001*4, 'expoOut')
                end
            end]]--
        end
    end
    if (section >= 120 and section < 126) then 
        if secStep == 0 or secStep == 8 then 
            swap = swap * -1
            triggerEvent('add camera zoom', 0.2, 0.1)
            
            if secStep == 6 then 
                setShaderProperty('mirror', 'angle', 20.0*swap)
                tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*2, 'cubeOut')
 
            else 

                setShaderProperty('chrom', 'strength', 0.02*swap)
                tweenShaderProperty('chrom', 'strength', 0, crochet*0.001*4, 'cubeOut')
                setShaderProperty('mirror', 'angle', 20.0*swap)
                tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
            end

        end
    end
    if section == 126 then 
        if curStep % 2 == 0 then 
            swap = swap * -1
            triggerEvent('add camera zoom', 0.2, 0.1)


            setShaderProperty('chrom', 'strength', 0.02*swap)
            tweenShaderProperty('chrom', 'strength', 0, crochet*0.001*2, 'cubeOut')

            setShaderProperty('mirror', 'angle', 20.0*swap)
            tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*2, 'cubeOut')
        end
    end

    if section >= 162 and section < 178 then 
        if doubleSecStep == 12 and section ~= 47 then 
            setShaderProperty('mirror', 'angle', 0)
            swap = swap * -1
            tweenShaderProperty('mirror', 'angle', 30.0*swap, crochet*0.001*4, 'expoIn')
            if modcharts then 
                for i = 0, 3 do 
                    tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"]+100*swap, crochet*0.001*4, 'expoIn')
                    tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"]-100*swap, crochet*0.001*4, 'expoIn')
                end
            end
            tweenShaderProperty('blur', 'strength', 10, crochet*0.001*4, 'expoIn')
            tweenShaderProperty('chrom', 'strength', 0.02, crochet*0.001*4, 'expoIn')
        end
        if doubleSecStep == 16 then 
            tweenShaderProperty('mirror', 'angle', 0.0, crochet*0.001*16, 'expoOut')
            if modcharts then 
                for i = 0, 3 do 
                    tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"], crochet*0.001*16, 'expoOut')
                    tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"], crochet*0.001*16, 'expoOut')
                end
            end
            tweenShaderProperty('blur', 'strength', 0.0, crochet*0.001*16, 'expoOut')
            tweenShaderProperty('chrom', 'strength', 0.0, crochet*0.001*16, 'expoOut')
        end

        if curStep % 128 == 30 or curStep % 128 == 40 or curStep % 128 == 60 or curStep % 128 == 64 or curStep % 128 == 76 or curStep % 128 == 88 or curStep % 128 == 92 or curStep % 128 == 104 or curStep % 128 == 116 then 
            triggerEvent('add camera zoom', 0.1, 0.1)
        end
    end

    if section >= 130 and section < 162 then 
        if curStep % 64 == 52 or curStep % 64 == 12 or curStep % 64 == 20 or curStep % 64 == 26 or doubleSecStep == 0 then 
            triggerEvent('add camera zoom', 0.1, 0.1)
            swap = swap * -1
            setShaderProperty('chrom', 'strength', 0.02*swap)
            tweenShaderProperty('chrom', 'strength', 0, crochet*0.001*4, 'cubeOut')

            --if section >= 146 then 
            if modcharts then 
                for i = 0,7 do 
                    local off = 30*swap
                    if i % 2 == 0 then 
                        off = off * -1
                    end
                    setActorY(getActorY(i)+off, i)
                    tweenActorProperty(i, 'y', _G["defaultStrum"..i.."Y"], crochet*0.001*4, 'expoOut')
                end
            end
            --else 
                
            --end


            --setShaderProperty('mirror', 'y', 0.1*swap)
            --tweenShaderProperty('mirror', 'y', 0, crochet*0.001*4, 'expoOut')
        end
    end

    if section >= 32 and section < 48 then 
        if doubleSecStep == 12 and section ~= 178 then
            setShaderProperty('mirror', 'angle', 0)
            swap = swap * -1
            tweenShaderProperty('mirror', 'angle', 30.0*swap, crochet*0.001*4, 'expoIn')
            tweenShaderProperty('blur', 'strength', 10, crochet*0.001*4, 'expoIn')
        end
        if doubleSecStep == 16 then 
            tweenShaderProperty('mirror', 'angle', 0.0, crochet*0.001*16, 'expoOut')
            tweenShaderProperty('blur', 'strength', 0.0, crochet*0.001*16, 'expoOut')
        end

        if curStep % 128 == 30 or curStep % 128 == 40 or curStep % 128 == 60 or curStep % 128 == 64 or curStep % 128 == 76 or curStep % 128 == 88 or curStep % 128 == 92 or curStep % 128 == 104 or curStep % 128 == 116 then 
            triggerEvent('add camera zoom', 0.1, 0.1)
        end
    end

    if (section >= 16 and section < 30) or (section >= 80 and section < 94) then 
        if secStep == 8 or doubleSecStep == 0 then 
            if modcharts then 
            for i = 0, 3 do 
                setActorX(getActorX(i)+offsetShit[(i%2)+1], i)
                setActorX(getActorX(i+4)+offsetShit[(i%2)+1], i+4)
                tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"], crochet*0.001*8, 'expoOut')
                tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"], crochet*0.001*8, 'expoOut')

                setActorAngle(getActorAngle(i)+offsetShit[(i%2)+1], i)
                setActorAngle(getActorAngle(i+4)+offsetShit[(i%2)+1], i+4)
                tweenActorProperty(i, 'angle', 0, crochet*0.001*8, 'expoOut')
                tweenActorProperty(i+4, 'angle', 0, crochet*0.001*8, 'expoOut')
            end
            end
            triggerEvent('add camera zoom', 0.05, 0.05)
        end
        if doubleSecStep == 20 then 
            triggerEvent('add camera zoom', 0.1, 0.1)
        end
    end

    if section == 30 and modcharts then 
        if secStep % 8 == 0 then  
            for i = 0, 3 do 
                setActorX(getActorX(i)+offsetShit[(i%2)+1], i)
                setActorX(getActorX(i+4)+offsetShit[(i%2)+1], i+4)
                tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"], crochet*0.001*4, 'expoOut')
                tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"], crochet*0.001*4, 'expoOut')

                setActorAngle(getActorAngle(i)+offsetShit[(i%2)+1], i)
                setActorAngle(getActorAngle(i+4)+offsetShit[(i%2)+1], i+4)
                tweenActorProperty(i, 'angle', 0, crochet*0.001*4, 'expoOut')
                tweenActorProperty(i+4, 'angle', 0, crochet*0.001*4, 'expoOut')
            end
        elseif secStep % 8 == 4 then 
            for i = 0, 3 do 
                setActorX(getActorX(i)-offsetShit[(i%2)+1], i)
                setActorX(getActorX(i+4)-offsetShit[(i%2)+1], i+4)
                tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"], crochet*0.001*4, 'expoOut')
                tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"], crochet*0.001*4, 'expoOut')

                setActorAngle(getActorAngle(i)-offsetShit[(i%2)+1], i)
                setActorAngle(getActorAngle(i+4)-offsetShit[(i%2)+1], i+4)
                tweenActorProperty(i, 'angle', 0, crochet*0.001*4, 'expoOut')
                tweenActorProperty(i+4, 'angle', 0, crochet*0.001*4, 'expoOut')
            end
        end
    elseif section == 31 and modcharts then 
        if secStep < 12 then 
            if secStep % 4 == 0 then  
                for i = 0, 3 do 
                    setActorX(getActorX(i)+offsetShit[(i%2)+1], i)
                    setActorX(getActorX(i+4)+offsetShit[(i%2)+1], i+4)
                    tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"], crochet*0.001*2, 'expoOut')
                    tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"], crochet*0.001*2, 'expoOut')
    
                    setActorAngle(getActorAngle(i)+offsetShit[(i%2)+1], i)
                    setActorAngle(getActorAngle(i+4)+offsetShit[(i%2)+1], i+4)
                    tweenActorProperty(i, 'angle', 0, crochet*0.001*2, 'expoOut')
                    tweenActorProperty(i+4, 'angle', 0, crochet*0.001*2, 'expoOut')
                end
            elseif secStep % 4 == 2 then 
                for i = 0, 3 do 
                    setActorX(getActorX(i)-offsetShit[(i%2)+1], i)
                    setActorX(getActorX(i+4)-offsetShit[(i%2)+1], i+4)
                    tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"], crochet*0.001*2, 'expoOut')
                    tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"], crochet*0.001*2, 'expoOut')
    
                    setActorAngle(getActorAngle(i)-offsetShit[(i%2)+1], i)
                    setActorAngle(getActorAngle(i+4)-offsetShit[(i%2)+1], i+4)
                    tweenActorProperty(i, 'angle', 0, crochet*0.001*2, 'expoOut')
                    tweenActorProperty(i+4, 'angle', 0, crochet*0.001*2, 'expoOut')
                end
            end
        end
        
    end

    if curStep == 512-16 then 
        if not opponentPlay then
        tweenShaderProperty('mirror', 'angle', -360.0, crochet*0.001*16, 'expoIn')
        end
        tweenShaderProperty('mirror', 'zoom', 0.6, crochet*0.001*16, 'expoIn')
        tweenShaderProperty('sobel', 'strength', 1.0, crochet*0.001*16, 'expoIn')
    elseif curStep == 512 then 
        tweenShaderProperty('mirror', 'zoom', 1.0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('sobel', 'strength', 0.0, crochet*0.001*8, 'expoOut')
    end

    if curStep == 736 then 
        --tweenShaderProperty('mirror', 'angle', -360.0, crochet*0.001*16, 'expoIn')
        tweenShaderProperty('mirror', 'zoom', 4, crochet*0.001*16*2, 'expoIn')
    elseif curStep == 760 or curStep == 2328 then 
        if not opponentPlay then
        tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*8, 'cubeIn')
        end
    elseif curStep == 768 then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'expoOut')
    end


    if curStep == 896 or curStep == 916 or curStep == 928 or curStep == 940 or curStep == 948 or curStep == 954 or curStep == 960 or curStep == 980 then 
        triggerEvent('add camera zoom', 0.1, 0.1)
    end
    if section == 62 then 
        if curStep % 16 == 0 then 
            triggerEvent('add camera zoom', 0.1, 0.1)
            if modcharts then 
                for i = 0, 3 do 
                    setActorY(getActorY(i)+offsetShit3[(i%4)+1], i)
                    setActorY(getActorY(i+4)-offsetShit3[(i%4)+1], i+4)
                    tweenActorProperty(i, 'y', _G["defaultStrum"..i.."Y"], crochet*0.001*4, 'expoOut')
                    tweenActorProperty(i+4, 'y', _G["defaultStrum"..(i+4).."Y"], crochet*0.001*4, 'expoOut')
                end
            end
        end
        if curStep % 16 == 8 then 
            triggerEvent('add camera zoom', 0.1, 0.1)
            if modcharts then 
                for i = 0, 3 do 
                    setActorY(getActorY(i)-offsetShit3[(i%4)+1], i)
                    setActorY(getActorY(i+4)+offsetShit3[(i%4)+1], i+4)
                    tweenActorProperty(i, 'y', _G["defaultStrum"..i.."Y"], crochet*0.001*4, 'expoOut')
                    tweenActorProperty(i+4, 'y', _G["defaultStrum"..(i+4).."Y"], crochet*0.001*4, 'expoOut')
                end
            end
        end
    end
    if section == 63 then 
        if curStep % 8 == 0 then 
            triggerEvent('add camera zoom', 0.1, 0.1)
            if modcharts then 
                for i = 0, 3 do 
                    setActorY(getActorY(i)+offsetShit3[(i%4)+1], i)
                    setActorY(getActorY(i+4)-offsetShit3[(i%4)+1], i+4)
                    tweenActorProperty(i, 'y', _G["defaultStrum"..i.."Y"], crochet*0.001*4, 'expoOut')
                    tweenActorProperty(i+4, 'y', _G["defaultStrum"..(i+4).."Y"], crochet*0.001*4, 'expoOut')
                end
            end
        end
        if curStep % 8 == 4 then 
            triggerEvent('add camera zoom', 0.1, 0.1)
            if modcharts then 
                for i = 0, 3 do 
                    setActorY(getActorY(i)-offsetShit3[(i%4)+1], i)
                    setActorY(getActorY(i+4)+offsetShit3[(i%4)+1], i+4)
                    tweenActorProperty(i, 'y', _G["defaultStrum"..i.."Y"], crochet*0.001*4, 'expoOut')
                    tweenActorProperty(i+4, 'y', _G["defaultStrum"..(i+4).."Y"], crochet*0.001*4, 'expoOut')
                end
            end
        end
    end

    if curStep == 768 then 
        tweenShaderProperty('bloom', 'brightness', -0.1, crochet*0.001*8, 'expoOut')
    elseif curStep == 1024 then 
        tweenShaderProperty('bloom', 'brightness', 0.05, crochet*0.001*8, 'expoOut')
        tweenShaderProperty('scanline', 'strength', 1, crochet*0.001*8, 'expoOut')
    elseif curStep == 1280 then 
        tweenShaderProperty('bloom', 'brightness', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('scanline', 'strength', 0, crochet*0.001*4, 'expoOut')
    end

    if curStep == 2072 then 
        if not opponentPlay then
        tweenShaderProperty('mirror', 'angle', -360.0, crochet*0.001*8, 'expoIn')
        end
        tweenShaderProperty('mirror', 'zoom', 0.6, crochet*0.001*8, 'expoIn')
        tweenShaderProperty('sobel', 'strength', 1.0, crochet*0.001*8, 'expoIn')
        if modcharts then 
            for i = 0,7 do 
                tweenActorProperty(i, 'y', _G["defaultStrum0Y"], crochet*0.001*8, 'expoIn')
            end
        end
    elseif curStep == 2080 then 
        tweenShaderProperty('mirror', 'zoom', 1.0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('sobel', 'strength', 0.0, crochet*0.001*16, 'expoOut')
        showOnlyStrums = false

    end

    if curStep == 2856 then 
        tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*16, 'expoOut')
    elseif curStep == 2864 then 
        setShaderProperty('sobel', 'strength', 1.0)
        setShaderProperty('greyscale', 'strength', 1.0)
        tweenShaderProperty('sobel', 'strength', 0.0, crochet*0.001*16, 'expoOut')
        tweenActorProperty('camHUD', 'alpha', 0, crochet*0.001*16*4, 'cubeInOut')

        tweenShaderProperty('bloom', 'brightness', 0, crochet*0.001*8, 'expoOut')
        tweenShaderProperty('scanline', 'strength', 0, crochet*0.001*8, 'expoOut')
    end

    if curStep == 2580 then 
        tweenShaderProperty('mirror', 'zoom', 2, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2584 then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'cubeIn')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*8, 'cubeIn')
    elseif curStep == 2592 then 
        setShaderProperty('sobel', 'strength', 1.0)
        tweenShaderProperty('sobel', 'strength', 0.0, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('bloom', 'brightness', 0.05, crochet*0.001*8, 'expoOut')
        tweenShaderProperty('scanline', 'strength', 1, crochet*0.001*8, 'expoOut')
        setStageColorSwap('hue', 0.1)
    end

    if curStep == 2336 then 
        setShaderProperty('sobel', 'strength', 1.0)
        tweenShaderProperty('sobel', 'strength', 0.0, crochet*0.001*16, 'cubeOut')
    end


    if curStep == 2464 then 
        setShaderProperty('sobel', 'strength', 1.0)
        setShaderProperty('greyscale', 'strength', 1.0)
        tweenShaderProperty('sobel', 'strength', 0.0, crochet*0.001*16, 'cubeOut')
        tweenShaderProperty('greyscale', 'strength', 0.0, crochet*0.001*16*8, 'cubeIn')
    end

    if section == 127 then 
        if secStep == 0 then 
            tweenShaderProperty('mirror', 'zoom', 1.5, crochet*0.001*2, 'cubeOut')
        elseif secStep == 4 then 
            tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*2, 'cubeOut')
        elseif secStep == 8 then 
            tweenShaderProperty('palette', 'paletteSize', 4, crochet*0.001*2, 'cubeOut')
            tweenShaderProperty('pixel', 'strength', 20, crochet*0.001*2, 'cubeOut')
        elseif secStep == 10 then 
            tweenShaderProperty('mirror', 'angle', 30, crochet*0.001*2, 'cubeOut')
        elseif secStep == 12 then
            tweenShaderProperty('palette', 'paletteSize', 3, crochet*0.001*2, 'cubeOut')
            tweenShaderProperty('pixel', 'strength', 40, crochet*0.001*2, 'cubeOut')
        elseif secStep == 14 then
            --tweenShaderProperty('raymarch', 'y', 180+65, crochet*0.001*2, 'cubeOut')
            tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
            tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*2, 'cubeOut')
        end
    end
end

function sectionHit(section)

    if section == 8 then 
        if modcharts then 
        tweenActorProperty(0, 'y', _G["defaultStrum0Y"], crochet*0.001*16*2, 'expoOut')
        tweenActorProperty(7, 'y', _G["defaultStrum0Y"], crochet*0.001*16*2, 'expoOut')
        end
        --tweenShaderProperty('mirror', 'angle', -180.0, crochet*0.001*16*6, 'linear')
        --tweenShaderProperty('mirror', 'zoom', 2.0, crochet*0.001*16*6, 'linear')
    elseif section == 10 then 
        if modcharts then 
        tweenActorProperty(1, 'y', _G["defaultStrum0Y"], crochet*0.001*16*2, 'expoOut')
        tweenActorProperty(6, 'y', _G["defaultStrum0Y"], crochet*0.001*16*2, 'expoOut')
        end
    elseif section == 12 then 
        if modcharts then 
        tweenActorProperty(2, 'y', _G["defaultStrum0Y"], crochet*0.001*16*2, 'expoOut')
        tweenActorProperty(5, 'y', _G["defaultStrum0Y"], crochet*0.001*16*2, 'expoOut')
        end

    elseif section == 14 then 
        if modcharts then 
        tweenActorProperty(3, 'y', _G["defaultStrum0Y"], crochet*0.001*16*2, 'expoOut')
        tweenActorProperty(4, 'y', _G["defaultStrum0Y"], crochet*0.001*16*2, 'expoOut')
        end
        if not opponentPlay then
            tweenShaderProperty('mirror', 'angle', -720.0, crochet*0.001*16*2, 'expoIn')
            tweenShaderProperty('mirror', 'zoom', 10.0, crochet*0.001*16*2, 'expoIn')
        else 
            tweenShaderProperty('mirror', 'zoom', 5.0, crochet*0.001*16*2, 'expoIn')
        end
        tweenShaderProperty('sobel', 'strength', 1.0, crochet*0.001*16*2, 'expoIn')
    elseif section == 16 then 
        tweenShaderProperty('sobel', 'strength', 0.0, crochet*0.001*8, 'expoOut')
        tweenShaderProperty('mirror', 'zoom', 1.0, crochet*0.001*4, 'expoOut')
        showOnlyStrums = false
    end
    

    if section == 95 then 
        pixelMode = true
        tweenShaderProperty('palette', 'strength', 1, crochet*0.001*16, 'expoIn')
        tweenShaderProperty('pixel', 'strength', 6.0, crochet*0.001*16, 'expoOut')

        if not middlescroll then 
            for i = 0, 3 do 
                tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"]+100, crochet*0.001*16, 'expoIn')
                tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"]-100, crochet*0.001*16, 'expoIn')
            end
        end

        tweenActorProperty('left', 'x', 0, crochet*0.001*16, 'expoIn')
        tweenActorProperty('right', 'x', 1280-160, crochet*0.001*16, 'expoIn')
        tweenShaderProperty('scanline', 'strength', 1, crochet*0.001*16, 'expoIn')
    elseif section == 127 then 
        pixelMode = false
        --tweenShaderProperty('pixel', 'strength', 10.0, crochet*0.001*16, 'cubeOut')
        for i = 0, 3 do 
            tweenActorProperty(i, 'x', _G["defaultStrum"..i.."X"], crochet*0.001*16, 'expoIn')
            tweenActorProperty(i+4, 'x', _G["defaultStrum"..(i+4).."X"], crochet*0.001*16, 'expoIn')
        end
        tweenActorProperty('left', 'x', -160, crochet*0.001*16, 'expoIn')
        tweenActorProperty('right', 'x', 1280, crochet*0.001*16, 'expoIn')

        runHaxeCode([[
            FlxG.camera.targetOffset.x = 0;
            FlxG.camera.targetOffset.y = 0;
        ]])
        tweenShaderProperty('scanline', 'strength', 0, crochet*0.001*16, 'expoIn')
        tweenShaderProperty('palette', 'strength', 0, crochet*0.001*16, 'expoIn')
    elseif section == 128 then 
        tweenShaderProperty('pixel', 'strength', 0.0, crochet*0.001*1, 'cubeOut')
        --tweenShaderProperty('raymarch', 'x', 0, crochet*0.001*1, 'cubeOut')
        --tweenShaderProperty('raymarch', 'y', 180, crochet*0.001*1, 'cubeOut')
        if modcharts and not opponentPlay then 
            local offscreen = -200
            if downscrollBool then 
                offscreen = 720+200
            end
            for i = 0,7 do 
                setActorY(offscreen, i)
            end
        end
        showOnlyStrums = true
    end


    

end
function updatePost(elapsed)


    if pixelMode then 
        runHaxeCode([[
            FlxG.camera.targetOffset.x = (FlxG.camera.scroll.x % 6);
            FlxG.camera.targetOffset.y = (FlxG.camera.scroll.y % 6);
        ]])
    end
end