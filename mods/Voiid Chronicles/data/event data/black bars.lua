local layerShit = 0
function createPost()
    makeSprite('topBar', '', -1200, -720, 1)
    setObjectCamera('topBar', 'hud')
    makeGraphic('topBar', 4000, 720, '0xFF000000')
    actorScreenCenter('topBar')
    setActorY(-720, 'topBar')

    makeSprite('bottomBar', '', -1200, 720, 1)
    setObjectCamera('bottomBar', 'hud')
    makeGraphic('bottomBar', 4000, 720, '0xFF000000')
    actorScreenCenter('bottomBar')
    setActorY(720, 'bottomBar')
    layerShit = getActorLayer('topBar')
end
function onEvent(name, position, value1, value2)
    if string.lower(name) == "black bars" then
        local height = tonumber(value1)
        tweenPos('topBar', getActorX('topBar'), height-720, 0.5)
        tweenPos('bottomBar', getActorX('topBar'), -height+720, 0.5)
        setActorLayer('topBar', layerShit)
        setActorLayer('bottomBar', layerShit)
        if value2 == '2' then 
            setActorLayer('topBar', 0)
            setActorLayer('bottomBar', 0)
        elseif value2 == '1' then 
            for i=0,7 do
                if downscrollBool then 
                    --112 = note width
                    local pos = 720-height-112
                    if pos >= strumLineY-56 then 
                        pos = strumLineY-56
                    end
                    tweenPosYAngle(i, pos, 360, 0.5)
                else 
                    local pos = height
                    if pos <= strumLineY-56 then 
                        pos = strumLineY-56
                    end
                    tweenPosYAngle(i, pos, 360, 0.5)
                end
                
            end
        end
    end
end