function createPost()
	initShader('barrel', 'MirrorRepeatEffect')
	setCameraShader('game', 'barrel')
    if modcharts then 
		setCameraShader('hud', 'barrel')
	end
	--setShaderProperty('barrel', 'barrel', 0.0)
	setShaderProperty('barrel', 'zoom', 1.0)

    initShader('constrastShit', 'BloomEffect')
    setCameraShader('game', 'constrastShit')
    setCameraShader('hud', 'constrastShit')
    setShaderProperty('constrastShit', 'effect', 0)

    initShader('colorSwap', 'ColorSwapEffect')
    setCameraShader('game', 'colorSwap')
    setCameraShader('hud', 'colorSwap')
    initShader('grey', 'GreyscaleEffect')
    setCameraShader('game', 'grey')
    setCameraShader('hud', 'grey')
    --setShaderProperty('colorSwap', 'saturation', -0.9)
    --setShaderProperty('colorSwap', 'brightness', -0.7)
end
function stepHit()
    if curStep == 320 or curStep == 352 or curStep == 416 or curStep == 436 then 
        setShaderProperty('barrel', 'angle', 30.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 352-4 or curStep == 444 then 
        setShaderProperty('barrel', 'angle', -30.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 384 or curStep == 400 or curStep == 432 then 
        setShaderProperty('barrel', 'zoom', 2.5)
        tweenShaderProperty('barrel', 'zoom', 1.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 394 or curStep == 426 then 
        tweenShaderProperty('barrel', 'zoom', 1.35, crochet*0.001*2, 'cubeOut')
    elseif curStep == 394+2 or curStep == 426+2 then 
        tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*2, 'cubeOut')
    elseif curStep == 404 or curStep == 408 then 
        tweenShaderProperty('barrel', 'angle', -10.0, crochet*0.001*1, 'cubeIn')
    elseif curStep == 406 or curStep == 410 then 
        tweenShaderProperty('barrel', 'angle', 10.0, crochet*0.001*1, 'cubeIn')
    elseif curStep == 412 then 
        tweenShaderProperty('barrel', 'angle', 0, crochet*0.001*1, 'cubeIn')
    end

    if curStep == 464 or curStep == 464+8 then 
        setShaderProperty('barrel', 'angle', 30.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 464+4 or curStep == 464+12 then 
        setShaderProperty('barrel', 'angle', -30.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
    end

    if curStep == 640 then 
        setShaderProperty('barrel', 'angle', 45.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*2, 'cubeOut')
    elseif curStep == 638 then 
        tweenShaderProperty('barrel', 'zoom', 2.5, crochet*0.001*2, 'cubeIn')
    end

    if curStep == 656 then --go grayscale
        tweenShaderProperty('grey', 'strength', 1, crochet*0.001*2, 'cubeOut')
        --tweenShaderProperty('colorSwap', 'brightness', -0.6, crochet*0.001*2, 'cubeOut')
    elseif curStep == 668 then --fade back in
        tweenShaderProperty('grey', 'strength', 0, crochet*0.001*2, 'cubeOut')
        --tweenShaderProperty('colorSwap', 'brightness', 0, crochet*0.001*2, 'cubeOut')
    elseif curStep == 760 then --fade in slow
        tweenShaderProperty('grey', 'strength', 1, crochet*0.001*8, 'cubeIn')
        --tweenShaderProperty('colorSwap', 'brightness', -0.6, crochet*0.001*8, 'cubeIn')
    elseif curStep == 880 then --fade back in slow ig
        tweenShaderProperty('grey', 'strength', 0, crochet*0.001*16, 'cubeIn')
        --tweenShaderProperty('colorSwap', 'brightness', 0, crochet*0.001*16, 'cubeIn')
    end

    if curStep == 668 or curStep == 668+1 or curStep == 668+2 or curStep == 668+3 then 
        triggerEvent('Add Camera Zoom', 0.08, 0.08)
    elseif curStep == 668+4 then 
        setShaderProperty('barrel', 'angle', 30.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
    end




    if curStep == 416+320 or curStep == 436+320 then 
        setShaderProperty('barrel', 'angle', 30.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 444+320 then 
        setShaderProperty('barrel', 'angle', -30.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 384+320 or curStep == 400+320 or curStep == 432+320 then 
        setShaderProperty('barrel', 'zoom', 2.5)
        tweenShaderProperty('barrel', 'zoom', 1.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 394+320 or curStep == 426+320 then 
        tweenShaderProperty('barrel', 'zoom', 1.35, crochet*0.001*2, 'cubeOut')
    elseif curStep == 394+2+320 or curStep == 426+2+320 then 
        tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*2, 'cubeOut')
    elseif curStep == 404+320 or curStep == 408+320 then 
        tweenShaderProperty('barrel', 'angle', -10.0, crochet*0.001*1, 'cubeIn')
    elseif curStep == 406+320 or curStep == 410+320 then 
        tweenShaderProperty('barrel', 'angle', 10.0, crochet*0.001*1, 'cubeIn')
    elseif curStep == 412+320 then 
        tweenShaderProperty('barrel', 'angle', 0, crochet*0.001*1, 'cubeIn')
    end


    --transition to rev mixed section
    if curStep == 880 then 
        if not opponentPlay then 
            tweenShaderProperty('barrel', 'angle', -10.0, crochet*0.001*4, 'cubeIn')
        end
        
        tweenShaderProperty('barrel', 'zoom', 1.5, crochet*0.001*4, 'backIn')
    elseif curStep == 880+4 then 
        if not opponentPlay then 
        tweenShaderProperty('barrel', 'angle', -20.0, crochet*0.001*4, 'cubeIn')
        end
        tweenShaderProperty('barrel', 'zoom', 2.0, crochet*0.001*4, 'backIn')
    elseif curStep == 880+8 then 
        if not opponentPlay then 
        tweenShaderProperty('barrel', 'angle', -30.0, crochet*0.001*4, 'cubeIn')
        end
        tweenShaderProperty('barrel', 'zoom', 2.5, crochet*0.001*4, 'backIn')
    elseif curStep == 880+12 then 
        if not opponentPlay then 
        tweenShaderProperty('barrel', 'angle', -360.0, crochet*0.001*4, 'cubeIn')
        end
        tweenShaderProperty('barrel', 'zoom', 3.0, crochet*0.001*4, 'backIn')
        tweenShaderProperty('constrastShit', 'contrast', -1, crochet*0.001*4, 'cubeIn')
    end

    if curStep == 896 then 
        --flashCamera('hud', '0xFF000000', crochet*0.001*4)
        tweenShaderProperty('constrastShit', 'contrast', 1, crochet*0.001*4, 'cubeOut')
        setShaderProperty('barrel', 'angle', 0)
        tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*4, 'cubeIn')
    elseif curStep == 897 then 
        setShaderProperty('barrel', 'angle', 0)
    end

    if curStep == 912 or curStep == 912+6 or curStep == 963 then 
        setShaderProperty('barrel', 'angle', 45.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*3, 'cubeOut')
    elseif curStep == 912+3 or curStep == 963+3 then 
        setShaderProperty('barrel', 'angle', -45.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*3, 'cubeOut')
    elseif curStep == 920 then 
        setShaderProperty('barrel', 'zoom', 2.5)
        tweenShaderProperty('barrel', 'zoom', 1.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 924 or curStep == 924+1 or curStep == 924+2 or curStep == 924+3 then 
        triggerEvent('Add Camera Zoom', 0.08, 0.08)
    elseif curStep == 944 then 
        tweenShaderProperty('barrel', 'zoom', 1.7, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('barrel', 'angle', 20.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 944+4 then 
        tweenShaderProperty('barrel', 'zoom', 1.0, crochet*0.001*2, 'cubeOut')
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*2, 'cubeOut')
    end

    if curStep == 968 then 
        tweenShaderProperty('constrastShit', 'contrast', 0.8, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('barrel', 'zoom', 1.3, crochet*0.001*4, 'backIn')
    elseif curStep == 968+4 then 
        tweenShaderProperty('constrastShit', 'contrast', 0.6, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('barrel', 'zoom', 1.6, crochet*0.001*4, 'backIn')
    elseif curStep == 968+8 then 
        tweenShaderProperty('constrastShit', 'contrast', 0.4, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('barrel', 'zoom', 1.9, crochet*0.001*4, 'backIn')
    elseif curStep == 968+12 then 
        tweenShaderProperty('constrastShit', 'contrast', 0.2, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('barrel', 'zoom', 2.2, crochet*0.001*4, 'backIn')
    end

    if curStep == 984 then 
        setShaderProperty('barrel', 'angle', 45.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('barrel', 'zoom', 1.0, crochet*0.001*4, 'cubeOut')
        tweenShaderProperty('constrastShit', 'contrast', 1.0, crochet*0.001*4, 'cubeIn')
    elseif curStep == 984+4 then 
        setShaderProperty('barrel', 'angle', -45.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 984+8 then 
        tweenShaderProperty('barrel', 'zoom', 1.2, crochet*0.001*4, 'cubeOut')
    end

    if curStep == 1000 then 
        tweenShaderProperty('constrastShit', 'contrast', 0.8, crochet*0.001*4, 'backIn')
        tweenShaderProperty('barrel', 'angle', -10.0, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('barrel', 'zoom', 1.3, crochet*0.001*4, 'backIn')
    elseif curStep == 1000+4 then 
        tweenShaderProperty('constrastShit', 'contrast', 0.6, crochet*0.001*4, 'backIn')
        tweenShaderProperty('barrel', 'angle', -20.0, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('barrel', 'zoom', 1.6, crochet*0.001*4, 'backIn')
    elseif curStep == 1000+8 then 
        tweenShaderProperty('constrastShit', 'contrast', 0.4, crochet*0.001*4, 'backIn')
        tweenShaderProperty('barrel', 'angle', -30.0, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('barrel', 'zoom', 1.9, crochet*0.001*4, 'backIn')
    elseif curStep == 1000+12 then 
        tweenShaderProperty('constrastShit', 'contrast', 0.2, crochet*0.001*4, 'backIn')
        tweenShaderProperty('barrel', 'angle', -40.0, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('barrel', 'zoom', 2.2, crochet*0.001*4, 'backIn')
    elseif curStep == 1000+16 then 
        tweenShaderProperty('constrastShit', 'contrast', 0, crochet*0.001*4, 'backIn')
        tweenShaderProperty('barrel', 'angle', -60.0, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('barrel', 'zoom', 2.5, crochet*0.001*4, 'backIn')
    elseif curStep == 1000+20 then 
        tweenShaderProperty('constrastShit', 'contrast', -0.25, crochet*0.001*4, 'backIn')
        tweenShaderProperty('barrel', 'angle', -90.0, crochet*0.001*4, 'cubeIn')
        tweenShaderProperty('barrel', 'zoom', 2.8, crochet*0.001*4, 'backIn')
    end

    if curStep == 1028 then 
        tweenShaderProperty('constrastShit', 'contrast', 1, crochet*0.001*60, 'linear')
        setShaderProperty('barrel', 'angle', 0.0)
        setShaderProperty('barrel', 'zoom', 1.0)
    end

    if curStep == 1248 then 
        tweenShaderProperty('grey', 'strength', 1, crochet*0.001*32, 'linear')
        --tweenShaderProperty('colorSwap', 'brightness', -0.6, crochet*0.001*32, 'linear')
    end

    if curStep == 1272 then 
        setShaderProperty('barrel', 'angle', 25.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1272+4 then 
        setShaderProperty('barrel', 'angle', -25.0)
        tweenShaderProperty('barrel', 'angle', 0.0, crochet*0.001*4, 'cubeOut')
    elseif curStep == 1272+8 then 
        setShaderProperty('barrel', 'zoom', 0.8)
        tweenShaderProperty('barrel', 'zoom', 1.0, crochet*0.001*4, 'cubeOut')

        tweenShaderProperty('colorSwap', 'brightness', -1, crochet*0.001*64, 'linear')
    end

end