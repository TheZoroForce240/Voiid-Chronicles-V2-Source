
local fade = 1
local targetFade = 0
function createPost()

    if mobile then 
        return
    end

    initShader('colorFill', 'ColorFillEffect')
    setActorShader('dad', 'colorFill')
    setActorShader('boyfriend', 'colorFill')
    setActorShader('girlfriend', 'colorFill')

    setShaderProperty('colorFill', 'fade', 1)

    --makeSprite('colorBG', '', 0,0)
    --makeGraphicRGB('colorBG', 1500/getCamZoom(),1000/getCamZoom(), '0,0,0')
    --actorScreenCenter('colorBG')
    --setActorScroll(0,0,'colorBG')
    --setActorLayer('colorBG', 0)

    makeSprite('colorBG', '', 0,0)
    makeGraphicRGB('colorBG', 3000/getCamZoom(),3000/getCamZoom(), '255,255,255')
    actorScreenCenter('colorBG')
    setActorScroll(0,0,'colorBG')
    setActorAlpha(0, 'colorBG')
    setActorLayer('colorBG', getActorLayer('girlfriend'))
end
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end
local enabled = false
function onEvent(name, position, value1, value2)

    if mobile then 
        return
    end
    if string.lower(name) == "colorfill" then
        
        enabled = not enabled
        local charCol = split(value1, ",")
        --local str = easeStuff[2]
        --trace(charCol)
        local easeStuff = split(value2, ",")
        if enabled then 
            --targetFade = 0
            
            setActorColorRGB('colorBG', charCol[4]..','..charCol[5]..','..charCol[6])
            
            setShaderProperty('colorFill', 'red', tonumber(charCol[1]))
            setShaderProperty('colorFill', 'green', tonumber(charCol[2]))
            setShaderProperty('colorFill', 'blue', tonumber(charCol[3]))
            tweenShaderProperty('colorFill', 'fade', 0, tonumber(easeStuff[1]), easeStuff[2])
            tweenActorProperty('colorBG', 'alpha', 1, tonumber(easeStuff[1]), easeStuff[2])
        else 
            tweenShaderProperty('colorFill', 'fade', 1, tonumber(easeStuff[1]), easeStuff[2])
            tweenActorProperty('colorBG', 'alpha', 0, tonumber(easeStuff[1]), easeStuff[2])
            --targetFade = 1
        end
    end
end