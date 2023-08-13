local echos = {}
--punch anim to punch frame = 333ms
local punchFrame = 333

local echoDirectionFlip = false
function onEventLoaded(name, position, value1, value2)
    if not charsAndBGs then 
        return
    end
    if name == 'punch' then
        
        for i = 1,tonumber(value1) do                                                             --played anim, faded, removed
            table.insert(echos, {tonumber(position)+(crochet*4*(i-1)*tonumber(value2)),'whiteWiik3',false,false,false,punchFrame})
        end
    elseif name == 'slash' then
        
        for i = 1,tonumber(value1) do                                                             --played anim, faded, removed
            table.insert(echos, {tonumber(position)+(crochet*4*(i-1)*tonumber(value2)),'whiteWiik4',false,false,false,punchFrame})
        end
    end
end
function createPost()
    if not charsAndBGs then 
        return
    end
    
    local noteCount = getUnspawnNotes()
    for i = 0,noteCount-1 do 
        local nt = getUnspawnedNoteNoteType(i)
        local st = getUnspawnedNoteStrumtime(i)
        if getUnspawnedNoteMustPress(i) then 
            if nt == 'Wiik3Punch' then 
                table.insert(echos, {st,'purpleWiik3',false,false,false,punchFrame})
            elseif nt == 'Wiik4Sword' then 
                table.insert(echos, {st,'purpleWiik4',false,false,false,punchFrame})
            elseif nt == 'BoxingMatchPunch' then 
                table.insert(echos, {st,'purpleWiik2',false,false,false,650, false, false})
            end
        end

    end
    for i = 1,#echos do
        local animName = 'attack'
        local spritesheet = 'characters/MattStand_Attack'
        if echos[i][2] == 'whiteWiik3' then 
            spritesheet = 'characters/WhiteMattStand_Attack'
        elseif echos[i][2] == 'purpleWiik4' then
            spritesheet = 'characters/MattSlash'
            animName = 'mattslash'
        elseif echos[i][2] == 'purpleWiik2' then
            spritesheet = 'characters/Wiik_2_Echo'
            makeAnimatedSprite('splash'..i, 'characters/Splash', 0,0)
            addActorAnimation('splash'..i, 'splash', 'splash', 24, false)
            setActorVisible(false, 'splash'..i)

            makeAnimatedSprite('echoglove'..i, 'characters/EchoGlove', 0,0)
            addActorAnimation('echoglove'..i, 'echoglove', 'echoglove', 24, true)
            setActorVisible(false, 'echoglove'..i)
            setActorAngle(45, 'echoglove'..i)
        elseif echos[i][2] == 'whiteWiik4' then
            spritesheet = 'characters/WhiteMattSlash'
            animName = 'mattslash'
        end
        makeAnimatedSprite('echo'..i, spritesheet, 0,0)
        addActorAnimation('echo'..i, 'attack', animName, 24, false)
        setActorVisible(false, 'echo'..i)
        setActorScale(1.5, 'echo'..i)
        if songLower == 'final destination' or songLower == 'final destination old' then 
        --if math.random(0, 100) >= 50 then
            setActorFlipX(true, 'echo'..i)
            echoDirectionFlip = true
        end

       

        --trace('echo'..i)
    end
end

function update(elapsed)
    for i = 1,#echos do
        if songPos >= echos[i][1]-echos[i][6] and not echos[i][3] then 
            --play anim
            local offsetFromBFX = -900+70
            local offsetFromBFY = -100+40
            if echos[i][2] == 'whiteWiik3' then 
                --spritesheet = 'characters/WhiteMattStand_Attack'
            elseif echos[i][2] == 'purpleWiik4' then
                offsetFromBFX = -1000
                offsetFromBFY = -320
            elseif echos[i][2] == 'purpleWiik2' then
                --spritesheet = 'characters/Wiik_2_Echo'
                offsetFromBFY = -450+math.random(-150,100)
            elseif echos[i][2] == 'whiteWiik4' then
                offsetFromBFX = -1000
                offsetFromBFY = -320
            end
            setActorFlipX(echoDirectionFlip, 'echo'..i)
            if getActorFlipX('echo'..i) then 
                offsetFromBFX = offsetFromBFX+getActorWidth('echo'..i)+70
                if echos[i][2] == 'purpleWiik2' then
                    --spritesheet = 'characters/Wiik_2_Echo'
                    offsetFromBFX = offsetFromBFX + 1050
                end
            end

            setActorPos(getActorX('boyfriend')+offsetFromBFX+math.random(-100,150),getActorY('boyfriend')+offsetFromBFY+math.random(-20,20), 'echo'..i)
            setActorVisible(true, 'echo'..i)
            playActorAnimation('echo'..i, 'attack', true)
            echos[i][3] = true
            setActorLayer('echo'..i, getActorLayer('boyfriend')+1)

        end
        if echos[i][2] == 'purpleWiik2' then
            if songPos >= echos[i][1] and not echos[i][7] then 

                setActorPos(getActorX('echo'..i)+getActorWidth('echo'..i)-250,getActorY('echo'..i)+100, 'echoglove'..i)
                if getActorFlipX('echo'..i) then 
                    setActorPos(getActorX('echo'..i),getActorY('echo'..i)+100, 'echoglove'..i)
                end
                setActorVisible(true, 'echoglove'..i)
                playActorAnimation('echoglove'..i, 'echoglove', true)

                local targetx = getActorX('boyfriend')
                local targety = getActorY('boyfriend')+250

                local ang = math.atan2(getActorX('echoglove'..i)-targetx, getActorY('echoglove'..i)-targety)
                ang = ang/(math.pi/180)
                if getActorFlipX('echo'..i) then 
                    ang = ang-180
                end
                setActorAngle(ang+180, 'echoglove'..i)
                tweenActorProperty('echoglove'..i, 'x', targetx, 0.1)
                tweenActorProperty('echoglove'..i, 'y', targety, 0.1)
                echos[i][7] = true
            end

            if songPos >= echos[i][1]+100 and not echos[i][8] then 

                setActorVisible(false, 'echoglove'..i)
                setActorPos(getActorX('boyfriend')-130,getActorY('boyfriend')+190, 'splash'..i)
                setActorVisible(true, 'splash'..i)
                playActorAnimation('splash'..i, 'splash', true)
                setActorLayer('splash'..i, getActorLayer('boyfriend'))
                echos[i][8] = true
            end
        end

        if songPos >= echos[i][1]+500 and not echos[i][4] then 
            --play anim
            if echos[i][2] == 'purpleWiik2' then

            end
            tweenFadeOut('echo'..i, 0, 1)
            echos[i][4] = true
        end
        if songPos >= echos[i][1]+2500 and not echos[i][5] then 
            --play anim
            destroySprite('echo'..i)
            if echos[i][2] == 'purpleWiik2' then
                destroySprite('splash'..i)
                destroySprite('echoglove'..i)
            end
            --trace('remvoed echo'..i)
            echos[i][5] = true
        end
    end
end

function onEvent(name, position, value1, value2)
    if name == 'flip echo direction' then 
        echoDirectionFlip = not echoDirectionFlip
    end
end