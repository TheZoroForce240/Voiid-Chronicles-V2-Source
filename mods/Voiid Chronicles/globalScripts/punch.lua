local songHasPunches = false
function createPost()
    --make sprites
    if songHasPunches then 

   
        for i = 1,3 do 
            makeAnimatedSprite('punch'..i, 'punch'..i, 0, 0, 1)
            setObjectCamera('punch'..i, 'hud')
            addActorAnimation('punch'..i,'punch'..i,'punch'..i,24,false)
            playActorAnimation('punch'..i, 'punch'..i)
            actorScreenCenter('punch'..i)
            setActorAlpha(0, 'punch'..i)
        end
        makeText('msText', '', 0,0,32)
        setObjectCamera('msText', 'hud')
        actorScreenCenter('msText')
        setActorY(450, 'msText')
        setActorAlpha(0, 'msText')

        makeText('punchesLeft', '', 0,0,48)
        setObjectCamera('punchesLeft', 'hud')
        actorScreenCenter('punchesLeft')
        setActorY(300, 'punchesLeft')
        --setActorAlpha(0, 'punchesLeft')
    end    
end
local punches = {}
local punchEarlyHitTiming = 160 --anim time = 666ms
local punchLateHitTiming = 160
local dodging = false
local dodgeCooldown = 0
local canBeDodged = false
local punchAlphas = {0,0,0}
local punchAlphaLerpSpeed = 0.2
local punchTime = 0

local fadeOutDelay = 0




function onEventLoaded(name, position, value1, value2)
    if name == 'punch' or name == 'slash' then
        songHasPunches = true
        if mechanics then 
                                    --time            punch number        beat timing    played anim, punches left, punches hit
            table.insert(punches, {tonumber(position),getPunchIdx(tonumber(value1)),tonumber(value2),false,tonumber(value1),0})
        end
    end

end
function lerp(a, b, ratio)
	return a + ratio * (b - a); --the funny lerp
end
function update(elapsed)

    if not songHasPunches then 
        return
    end

    canBeDodged = false
    
    if #punches > 0 then 
        local beatTiming = punches[1][3]*(crochetUnscaled*4) --leather engine is dumb and puts crochet as stepcrochet when thats not right

        if punches[1][1]-beatTiming < songPos then
            --show punch
            punchAlphas[punches[1][2]] = 1
            punchAlphaLerpSpeed = 17
            fadeOutDelay = 0
            punchTime = punches[1][1] + ((punches[1][6])*beatTiming)
            setActorText('punchesLeft', punches[1][5])
            actorScreenCenter('punchesLeft')
            setActorY(300, 'punchesLeft')
            if punchTime-punchEarlyHitTiming < songPos and songPos < punchTime+punchLateHitTiming then
                --can be hit during this time
                canBeDodged = true
                if not punches[1][4] and punchTime <= songPos then 
                    punches[1][4] = true
                    playActorAnimation('punch'..punches[1][2], 'punch'..punches[1][2],true)

                end
                if punchTime <= songPos then 
                    if bot or opponentPlay then
                        tryDodge(true)
                    end
                end
            end
            if songPos > punchTime+punchLateHitTiming then --miss
                
                setHealth(getHealth()-2)
                triggerEvent('ca burst', '0.013', '0.015')
                --trace("missed punch")
                setActorAlpha(1, 'msText')
                setActorText('msText', "miss")
                actorScreenCenter('msText')
                setActorTextColor('msText', 'RED')
                setActorY(450, 'msText')
                punchRemove()
            end
        end
    end




    if not dodging then 
        if justPressedDodgeKey() and not (bot or opponentPlay) then 
            tryDodge(false)
        end
    else 
        dodgeCooldown = dodgeCooldown - (1000*elapsed)
        if dodgeCooldown <= 0 then 
            dodgeCooldown = 0
            dodging = false
        end
    end

    if fadeOutDelay > 0 then 
        fadeOutDelay = fadeOutDelay - (1000*elapsed)
    else 
        for i = 1,3 do 
            setActorAlpha(lerp(getActorAlpha('punch'..i), punchAlphas[i], elapsed*punchAlphaLerpSpeed), 'punch'..i)
        end
    end


    setActorAlpha(lerp(getActorAlpha('msText'), 0, elapsed*8), 'msText')



    

end
function tryDodge(botplay)
    dodging = true
    dodgeCooldown = 500
    playDodge()
    if canBeDodged then 
        
        punchRemove()
        triggerEvent('ca burst', '0.007', '0.01')        
        dodging = false
        dodgeCooldown = 0
        local ms = -math.floor(punchTime-songPos)
        local text = ms.."ms"
        if botplay then 
            text = text.." (BOT)"
        end
        setActorAlpha(1, 'msText')
        setActorText('msText', text)
        actorScreenCenter('msText')
        setActorTextColor('msText', 'WHITE')
        setActorY(450, 'msText')
        --trace("dodged punch"..ms.."ms")
    end
end
function playerOneSing(data, time, noteType)
    dodgeCooldown = 0 --should be a bit fairer with parry notes
end

function punchRemove() --try to remove a punch from the list, wont remove if theres still extra punches left
    punches[1][5] = punches[1][5] - 1
    punches[1][6] = punches[1][6] + 1
    
    if punches[1][5] <= 0 then 
        setActorText('punchesLeft', "")
        fadeOutDelay = 500
        punchAlphas[punches[1][2]] = 0
        table.remove(punches, 1)
        return true --if removed
    else 
        punches[1][4] = false --reset anim
    end
    return false --if not removed
end

function getPunchIdx(idx)
    return ((idx-1)%3)+1
end
local dodgeAnim = 0
local dodgeMap = {
	{'singLEFT', 'dodgeLEFT'},
	{'singDOWN', 'dodgeDOWN'},
	{'singUP', 'dodgeUP'},
	{'singRIGHT', 'dodgeRIGHT'}
}
function playDodge()
	dodgeAnim = dodgeAnim + 1
	local anim = dodgeAnim%4 --loop each time
    playCharacterAnimation('boyfriend', dodgeMap[anim+1][2], true)
    setCharacterPreventDanceForAnim('boyfriend', true)
end


