local parries = {}
local defX0 = 0
local defX1 = 0
local defX2 = 0
local defX3 = 0
local defX4 = 0
local defX5 = 0
function start()
	if playerKeyCount == 7 then
		setProperty('', 'playerManiaOffset', 1)
	end
end
function createPost()

	addCharacterToMap('dad', 'Wiik3EchoParry')
        
	makeAnimatedSprite('flamePunch', 'FireGlove', 0, 0)
	addActorAnimation('flamePunch', 'FireGlove', 'FireGlove', 24, true)
	playActorAnimation('flamePunch', 'FireGlove', true)
	setActorAlpha(0, 'flamePunch')

	local noteCount = getUnspawnNotes()
    for i = 0,noteCount-1 do 
        local nt = getUnspawnedNoteNoteType(i)
        local st = getUnspawnedNoteStrumtime(i)
        if getUnspawnedNoteMustPress(i) then 
			if nt == 'ParryNote' then 
				--if mechanics then 
					table.insert(parries, {st,false,false}) 
				--end
			end
        end
		if nt == 'ParryNote' then 
			setUnspawnedNoteSingAnimPrefix(i, 'dodge')
		end

    end

	if playerKeyCount == 5 then 
		if not middlescroll then 
			setActorX(getActorX(0)+640,4)
			setActorX(getActorX(1)+640,5)
			setActorX(getActorX(2)+640,7)
			setActorX(getActorX(3)+640,8)
		else 
			setActorX(_G['defaultStrum4X']+25,4)
			setActorX(_G['defaultStrum5X']+25,5)
			setActorX(_G['defaultStrum5X']+25+112,7)
			setActorX(_G['defaultStrum5X']+25+112+112,8)
		end
		defX0 = getActorX(4)
		defX1 = getActorX(5)
		defX2 = getActorX(7)
		defX3 = getActorX(8)
		setActorX(getActorX(5)+(112/2),6)
		setActorAlpha(0, 6)
	elseif playerKeyCount == 7 then 
		setProperty('', 'playerManiaOffset', 1)
		if not middlescroll then 
			setActorX(getActorX(0)+640,6)
			setActorX(getActorX(1)+640,7)
			setActorX(getActorX(2)+640,8)
			setActorX(getActorX(3)+640,10)
			setActorX(getActorX(4)+640,11)
			setActorX(getActorX(5)+640,12)
			
		else 
			
			setActorX(_G['defaultStrum6X']+25,6)
			setActorX(_G['defaultStrum7X']+25,7)
			local gap = getActorX(7)-getActorX(6)
			setActorX(_G['defaultStrum8X']+25,8)
			setActorX(_G['defaultStrum8X']+25+gap,10)
			setActorX(_G['defaultStrum8X']+25+gap+gap,11)
			setActorX(_G['defaultStrum8X']+25+gap+gap+gap,12)
		end
		defX0 = getActorX(6)
		defX1 = getActorX(7)
		defX2 = getActorX(8)
		defX3 = getActorX(10)
		defX4 = getActorX(11)
		defX5 = getActorX(12)
		setActorX(getActorX(8)+(getActorWidth(5)/2),9)
		setActorAlpha(0, 9)
	end
end

function onEventLoaded(name, pos, val1, val2)
	if string.lower(name) == 'change stage' then 
		if val1 == 'TKODark' then
			addCharacterToMap('dad', 'Wiik3EchoParryDark')
			trace('found tko dark stage for parry stuff')
		end
	end
end
function getParryMattName()
	if curStage == 'TKODark' then 
		return 'Wiik3EchoParryDark'
	end 
	return 'Wiik3EchoParry'
end


local parryAnimTime = 583 --needs to start at that time
local punchLateHitTiming = 150
local parrying = false
local parryCooldown = 0
local canParry = false
local didHitParry = false
local waitForNextParry = false

local charBeforeParry = ""

function update(elapsed)
	if #parries > 0 then 
        if parries[1][1]-parryAnimTime < songPos then
            if not parries[1][2] then 
				if not waitForNextParry then
					triggerEvent('parryNoteStart')
					if playerKeyCount == 5 then 
						setActorX(defX0,4)
						setActorX(defX1,5)
						setActorX(defX2,7)
						setActorX(defX3,8)
						setActorX(getActorX(5)+(112/2),6)
						setActorAlpha(0, 6)
						tweenActorProperty(4, 'x', defX0-(112/2), crochet*0.001*4, 'cubeOut')
						tweenActorProperty(5, 'x', defX1-(112/2), crochet*0.001*4, 'cubeOut')
						tweenActorProperty(7, 'x', defX2+(112/2), crochet*0.001*4, 'cubeOut')
						tweenActorProperty(8, 'x', defX3+(112/2), crochet*0.001*4, 'cubeOut')
						tweenActorProperty(6, 'alpha', 1, crochet*0.001*4, 'cubeIn')
					elseif playerKeyCount == 7 then 
						setActorX(defX0,6)
						setActorX(defX1,7)
						setActorX(defX2,8)
						setActorX(defX3,10)
						setActorX(defX4,11)
						setActorX(defX5,12)
						local as = getActorWidth(5)
						setActorX(getActorX(8)+(getActorWidth(5)/2),9)
						setActorAlpha(0, 9)
						tweenActorProperty(6, 'x', defX0-(as/2), crochet*0.001*4, 'cubeOut')
						tweenActorProperty(7, 'x', defX1-(as/2), crochet*0.001*4, 'cubeOut')
						tweenActorProperty(8, 'x', defX2-(as/2), crochet*0.001*4, 'cubeOut')
						tweenActorProperty(10, 'x', defX3+(as/2), crochet*0.001*4, 'cubeOut')
						tweenActorProperty(11, 'x', defX4+(as/2), crochet*0.001*4, 'cubeOut')
						tweenActorProperty(12, 'x', defX5+(as/2), crochet*0.001*4, 'cubeOut')
						tweenActorProperty(9, 'alpha', 1, crochet*0.001*4, 'cubeIn')
					end
				end
				waitForNextParry = false --reset

				if #parries > 1 then
					--trace(parries[1][1])
					--trace(parries[2][1])
					if parries[2][1]-parries[1][1] < 144+(crochet*8)+parryAnimTime then
						waitForNextParry = true --keep the notes seperated until after the next fireball
						trace('waiting for next parry')
					end
				end


				
				
				charBeforeParry = player2
				if curStage == 'TKODark' then 
					charBeforeParry = 'TKOMattDark'
				end

                --play anim
                triggerEvent('change character', 'dad', getParryMattName())
                playCharacterAnimation('dadCharacter1', 'fistThrow')
                setCharacterPreventDanceForAnim('dadCharacter1', true)
                --trace('play anim')
                tweenActorProperty('dadCharacter1', 'x', getActorX('dadCharacter1')-450, parryAnimTime*0.001, 'cubeOut')
                parries[1][2] = true
            end

            if parries[1][1]-100 < songPos and songPos < parries[1][1]+(punchLateHitTiming*1.5) then
                --can be hit during this time
                if not parries[1][3] then
                    --show flaming punch
                    setActorAlpha(1, 'flamePunch')
                    setActorY(getActorY('dadCharacter1')+40, 'flamePunch')
                    setActorX(getActorX('dadCharacter1')-150, 'flamePunch')
                    tweenActorProperty('dadCharacter1', 'x', getActorX('dadCharacter1')+450, parryAnimTime*0.001, 'cubeIn')
                    local distToBF = math.abs((getActorX('flamePunch')+getActorWidth('flamePunch')) - getActorX('boyfriend'))
                    tweenActorProperty('flamePunch', 'x', getActorX('flamePunch')+10000, punchLateHitTiming*0.001*15, 'linear')
                    --trace('show punch')
                    parries[1][3] = true
                end
                --canParry = true
                --if parries[1][1] <= songPos then 
                --    if bot then 
                --        tryParry()
                --    end
                --end
            end
            --if parries[1][1]-(144) < songPos and songPos < parries[1][1]+(144) then
            --    canParry = true
            --end
            if songPos > parries[1][1]+(144) then --miss
                if not didHitParry then 
                    --setHealth(getHealth()-2)

                    didHitParry = true
                    --trace('missed parry')
					if not waitForNextParry then 
						if playerKeyCount == 5 then 
							tweenActorProperty(4, 'x', defX0, crochet*0.001*2, 'cubeIn')
							tweenActorProperty(5, 'x', defX1, crochet*0.001*2, 'cubeIn')
							tweenActorProperty(7, 'x', defX2, crochet*0.001*2, 'cubeIn')
							tweenActorProperty(8, 'x', defX3, crochet*0.001*2, 'cubeIn')
							tweenActorProperty(6, 'alpha', 0, crochet*0.001*2, 'cubeOut')
						elseif playerKeyCount == 7 then 
							tweenActorProperty(6, 'x', defX0, crochet*0.001*2, 'cubeIn')
							tweenActorProperty(7, 'x', defX1, crochet*0.001*2, 'cubeIn')
							tweenActorProperty(8, 'x', defX2, crochet*0.001*2, 'cubeIn')
							tweenActorProperty(10, 'x', defX3, crochet*0.001*2, 'cubeIn')
							tweenActorProperty(11, 'x', defX4, crochet*0.001*2, 'cubeIn')
							tweenActorProperty(12, 'x', defX5, crochet*0.001*2, 'cubeIn')
							tweenActorProperty(9, 'alpha', 0, crochet*0.001*2, 'cubeOut')
						end
						triggerEvent('parryNoteEnd')
					end
                end


            end
            if songPos > parries[1][1]+(parryAnimTime) then --miss
                --setHealth(getHealth()-2)
                parryRemove()
            end
        end
    end
end

function tryParry()  
    
end

function parryRemove()
    table.remove(parries, 1)
    didHitParry = false
    triggerEvent('change character', 'dad', charBeforeParry)




	if #parries > 0 then 
        if parries[1][1]-parryAnimTime-1000 >= songPos then
			
		end
	end
end