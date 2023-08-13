function playerTwoSing(data, time, type)

end


function createPost()


	initShader('mirror', 'MirrorRepeatEffect')
	initShader('mirrorHUD', 'MirrorRepeatEffect')
	setCameraShader('game', 'mirror')
    if modcharts then 
		setCameraShader('hud', 'mirrorHUD')
	end
	
	setShaderProperty('mirror', 'zoom', 1.0)
    setShaderProperty('mirrorHUD', 'zoom', 1.0)

    initShader('blur', 'BlurEffect')
    setCameraShader('game', 'blur')
    setCameraShader('hud', 'blur')
    setShaderProperty('blur', 'strength', 0)

	if not downscrollBool then 
		downscrollDiff = -1
	end
end

local noteScaleXThingy = {
    {{1.3,1,1,1}, 0},
    {{1,1,1.3,1}, 4},
    {{1,1.3,1,1}, 12},
    {{1.3,1,1,1}, 24},
    {{1,1,1,1.3}, 40},
    {{1,1.3,1,1}, 44},
    {{1,1,1.3,1}, 52}
}

local beats = {0, 24, 40, 64, 76, 88, 104, 108, 120}

function stepHit()

    if curStep >= 128 and curStep < 2528 then
        for i = 1, #noteScaleXThingy do
            if curStep % 64 == noteScaleXThingy[i][2] then --not actually doing the scale anymore that was just the og idea i had
                --trace('ashdjakshljdhjsdkla')
                if modcharts then 
                    for j = 0, #noteScaleXThingy[i][1]-1 do
                        if noteScaleXThingy[i][1][j+1] == 1.3 then
                            setActorY(getActorY(j)-15, j)
                            tweenActorProperty(j, 'y', _G['defaultStrum'..(j%4)..'Y'], crochet*0.001*8, 'quantIn')
                            setActorY(getActorY(j+keyCount)-15, j+keyCount)
                            tweenActorProperty(j+keyCount, 'y', _G['defaultStrum'..(j%4)..'Y'], crochet*0.001*8, 'quantIn')
                        end
                    end
                end


            end
        end
        if curStep > 16*16 then 
            for i = 1, #beats do
                if curStep % 128 == beats[i] then 
                    triggerEvent("add camera zoom", 0.08, 0.07)
                    setShaderProperty('blur', 'strength', 2)
                    tweenShaderProperty('blur', 'strength', 0, crochet*0.001*4, 'expoIn')
                end
            end
        end
    end

    if curStep == 240 then 
        tweenShaderProperty('mirror', 'y', 6, crochet*0.001*16, 'cubeIn')
        --tweenShaderProperty('mirror', 'x', 2, crochet*0.001*16, 'cubeIn')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*16, 'cubeOut')
    elseif curStep == 256 then 
        tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*8, 'cubeOut')
    end

    if curStep == 544 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 544+6 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 544+12 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    end

    if curStep == 576 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        --tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 576+32+8 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 576+32+8+16 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 696 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    end

    if curStep == 768 or curStep == 1536 or curStep == 1664 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 768+16 or curStep == 1536+16 or curStep == 1664+16 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 768+32 or curStep == 1536+32 or curStep == 1664+32 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
        triggerEvent("flip echo direction", "", "")
    end

    if curStep == 1664+32+6 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1664+32+12 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    end

    if curStep == 832 or curStep == 1600 or curStep == 1728 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 832+16 or curStep == 1600+16 or curStep == 1728+16 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 832+32 or curStep == 1600+32 or curStep == 1728+32  then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
        triggerEvent("flip echo direction", "", "")
    end
    if curStep == 912 then 
        tweenShaderProperty('mirror', 'x', -2, crochet*0.001*4, 'expoOut')
    elseif curStep == 952 then 
        tweenShaderProperty('mirror', 'x', -3, crochet*0.001*4, 'expoOut')
    end
    if curStep == 1728+32+8 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1728+32+16 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1728+32+20 then 
        tweenShaderProperty('mirror', 'x', 2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -40, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1728+32+24 then 
        tweenShaderProperty('mirror', 'x', 3, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -80, crochet*0.001*2, 'cubeOut')
    elseif curStep == 1728+32+24+2 then 
        tweenShaderProperty('mirror', 'x', 4, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -140, crochet*0.001*2, 'cubeOut')
    elseif curStep == 1728+32+24+2+2 then 
        tweenShaderProperty('mirror', 'x', 5, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -200, crochet*0.001*2, 'cubeOut')
    elseif curStep == 1728+32+24+2+2+2 then 
        tweenShaderProperty('mirror', 'x', 6, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -360, crochet*0.001*2, 'cubeOut')
    end

    if curStep == 1024 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1024+8 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1048 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 40, crochet*0.001*2, 'cubeOut')
    elseif curStep == 1048+2 then 
        tweenShaderProperty('mirror', 'x', 2, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 60, crochet*0.001*2, 'cubeOut')
    elseif curStep == 1048+4 then 
        tweenShaderProperty('mirror', 'x', 3, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 80, crochet*0.001*2, 'cubeOut')
    elseif curStep == 1056 then 
        tweenShaderProperty('mirror', 'x', 2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 60, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1056+8 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 40, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1080 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1080+4 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1080+8 then 
        tweenShaderProperty('mirror', 'x', -2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    end

    if curStep == 1104 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1104+16 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1104+32 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    end

    if curStep == 1152+8 then 
        tweenShaderProperty('mirror', 'x', -2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1152+16+8 then 
        tweenShaderProperty('mirror', 'x', -3, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1152+32+8 then 
        tweenShaderProperty('mirror', 'x', -2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1216 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1280 then 
        tweenShaderProperty('mirror', 'x', -2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1336 then 
        tweenShaderProperty('mirror', 'x', -3, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1336+8 then 
        tweenShaderProperty('mirror', 'x', -2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1376 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 30, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1376+16+8 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 60, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1376+16+8+4 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 90, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1376+16+8+4+4 then 
        tweenShaderProperty('mirror', 'x', 2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*4, 'cubeOut')

    elseif curStep == 1464 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1464+8 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1512 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1512+16 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
    end


    if curStep == 1656 then
        tweenShaderProperty('mirror', 'x', -2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 20, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1656+8 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -20, crochet*0.001*4, 'cubeOut')
    end


    if curStep == 1808 then
        tweenShaderProperty('mirror', 'x', 2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 40, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1808+16 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -40, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1808+32 then 
        tweenShaderProperty('mirror', 'x', 2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 50, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1808+32+8 then 
        tweenShaderProperty('mirror', 'x', 3, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 80, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1808+32+16 then 
        tweenShaderProperty('mirror', 'x', 4, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 180, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1808+32+32 then 
        tweenShaderProperty('mirror', 'x', 5, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 230, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1808+32+32+16 then 
        tweenShaderProperty('mirror', 'x', 6, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 290, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1808+32+32+32+8 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*4, 'cubeOut')
    end


    
    if curStep == 2048 then
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -40, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2048+16 then 
        tweenShaderProperty('mirror', 'x', -1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -80, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2048+32 then 
        tweenShaderProperty('mirror', 'x', -2, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -110, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2048+48 then 
        tweenShaderProperty('mirror', 'x', -3, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -140, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2048+48+8 then 
        tweenShaderProperty('mirror', 'x', -4, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -180, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2048+64 then 
        tweenShaderProperty('mirror', 'x', -5, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -230, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2048+64+16 then 
        tweenShaderProperty('mirror', 'x', -6, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -260, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2048+64+32 then 
        tweenShaderProperty('mirror', 'x', -7, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -300, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2048+64+32+16 then 
        tweenShaderProperty('mirror', 'x', -8, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -330, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2048+64+32+24 then 
        tweenShaderProperty('mirror', 'x', -9, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -360, crochet*0.001*4, 'cubeOut')
    end
    if curStep == 2176 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2208 then 
        tweenShaderProperty('mirror', 'x', 3, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 90, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2208+32 then 
        tweenShaderProperty('mirror', 'x', -3, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -90, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2208+32+16 then 
        tweenShaderProperty('mirror', 'x', -5, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -180, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2272 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -270, crochet*0.001*4, 'cubeOut')
    end


    if curStep == 2288 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2288+4 then 
        tweenShaderProperty('mirror', 'x', 3, crochet*0.001*4, 'expoOut')
        tweenShaderProperty('mirror', 'angle', -90, crochet*0.001*4, 'cubeOut')
    elseif curStep == 2288+8 then 
        tweenShaderProperty('mirror', 'x', -3, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 90, crochet*0.001*2, 'cubeOut')
    elseif curStep == 2288+10 then 
        tweenShaderProperty('mirror', 'x', -5, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 180, crochet*0.001*2, 'cubeOut')
    elseif curStep == 2288+12 then 
        tweenShaderProperty('mirror', 'x', 1, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 270, crochet*0.001*2, 'cubeOut')
    elseif curStep == 2288+14 then 
        tweenShaderProperty('mirror', 'x', 0, crochet*0.001*2, 'expoOut')
        tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*2, 'cubeOut')
    end





    if curStep == 988 then 
        tweenActorProperty('camHUD', 'alpha', 0.5, crochet*0.001*6, 'cubeIn')
        --tweenActorProperty('camGame', 'alpha', 0.35, crochet*0.001*6, 'cubeIn')
    elseif curStep == 1008 then 
        tweenActorProperty('camHUD', 'alpha', 1, crochet*0.001*8, 'cubeIn')
        --tweenActorProperty('camGame', 'alpha', 1, crochet*0.001*8, 'cubeIn')
    end

    if curStep == 1248 then 
        tweenShaderProperty('mirror', 'zoom', 1.6, crochet*0.001*8, 'expoOut')
        tweenShaderProperty('mirrorHUD', 'zoom', 1.6, crochet*0.001*8, 'expoOut')
    elseif curStep == 1268 then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*6, 'expoIn')
        tweenShaderProperty('mirrorHUD', 'zoom', 1, crochet*0.001*6, 'expoIn')
    end

    if curStep == 1752 then 
        tweenActorProperty('camHUD', 'alpha', 0.6, crochet*0.001*8, 'cubeIn')
        --tweenActorProperty('camGame', 'alpha', 0.35, crochet*0.001*8, 'cubeIn')
    elseif curStep == 1776 then 
        tweenActorProperty('camHUD', 'alpha', 1, crochet*0.001*12, 'cubeIn')
        --tweenActorProperty('camGame', 'alpha', 1, crochet*0.001*12, 'cubeIn')
    end

    
    if curStep == 2256 then 
        tweenShaderProperty('mirror', 'zoom', 1.6, crochet*0.001*12, 'expoIn')
        tweenShaderProperty('mirrorHUD', 'zoom', 1.6, crochet*0.001*12, 'expoIn')
    elseif curStep == 2288 then 
        tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'expoIn')
        tweenShaderProperty('mirrorHUD', 'zoom', 1, crochet*0.001*8, 'expoIn')
    end
end