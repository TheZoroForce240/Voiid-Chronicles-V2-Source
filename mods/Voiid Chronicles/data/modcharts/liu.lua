function create()
    setProperty('', 'playCountdown', false)
end
function createPost()
    makeSprite('black', '', 0, 0, 1)
    setObjectCamera('black', 'hud')
    makeGraphic('black', 4000, 2000, '0xFF000000')
    actorScreenCenter('black')
    tweenActorProperty('black', 'alpha', 0, 1.5, 'quadIn')
end
local three = {160}
local two = {168,172,173,174}
local one = {176,180}
local go = {184, 186, 188, 190,191,192,220,222,224,248,252}
function stepHit()
    --3
    for i = 1,#three do 
        if curStep == three[i] then 

        end
    end

    for i = 1,#two do 
        if curStep == two[i] then 
            triggerEvent('2')
        end
    end
    for i = 1,#one do 
        if curStep == one[i] then 
            triggerEvent('1')
        end
    end
    for i = 1,#go do 
        if curStep == go[i] then 
            triggerEvent('go')
        end
    end
end