local bleedTime = 0
local bleedDamage = 0.2
local xOffsets = {50, 20, 15, -10}
local yOffsets = {-20, -10, 40, -20}
function createPost()
	local noteCount = getUnspawnNotes()
    for i = 0,noteCount-1 do 
        local nt = getUnspawnedNoteNoteType(i)
        local st = getUnspawnedNoteStrumtime(i)
		local nd = getSingDirectionID(getUnspawnedNoteNoteData(i))
		if nt == 'VoiidBullet' and not getUnspawnedNoteSustainNote(i) then 
			setUnspawnedNoteXOffset(i, xOffsets[nd+1] * getUnspawnedNoteScaleX(i)) --set offset, make sure its scales with it so it matches with extra keys
			setUnspawnedNoteYOffset(i, yOffsets[nd+1] * getUnspawnedNoteScaleX(i)) --doing it inside here because each bullet needs a specific offset lol
		end
		if nt == 'VoiidBullet' then 
			setUnspawnedNoteSingAnimPrefix(i, 'dodge')
		end
    end

	initShader('bleed', 'VignetteEffect')
    setCameraShader('hud', 'bleed')
    setShaderProperty('bleed', 'strength', 15)
    setShaderProperty('bleed', 'size', 0.0)
	setShaderProperty('bleed', 'red', 255)
end
local tracerCount = 0
function playerOneSing(data, time, noteType) --the	
	if noteType == 'VoiidBullet' then
		playCharacterAnimation('dad', 'shoot', true)
		setCharacterPreventDanceForAnim('dad', true)
		makeTracer()
	end
end
function playerOneMiss(data, time, noteType) --the	
	if noteType == 'VoiidBullet' then
		playCharacterAnimation('dad', 'shoot', true)
		setCharacterPreventDanceForAnim('dad', true)
		makeTracer()
		bleedTime = bleedTime + 5
	end
end
function makeTracer()

	local sprName = 'tracer'..tracerCount
	destroySprite(sprName)
	makeSprite(sprName, '', getActorX('dad')+460, getActorY('dad')+140)
	makeGraphic(sprName, 5000, 5, 'ffffff')
	tweenActorProperty(sprName, 'alpha', 0, 1, 'cubeOut')

	setActorLayer(sprName, getActorLayer('dad'))

	setActorLayer('boyfriend', getActorLayer(sprName))

	setActorAngle(10 + (math.random()*2), sprName)
	setActorOriginX(0, sprName)

	tracerCount = tracerCount + 1
	if tracerCount > 30 then 
		tracerCount = 0;
	end
end

function lerp(a, b, ratio)
	return a + ratio * (b - a); --the funny lerp
end
local vigSize = 0

function update(elapsed)
	if bleedTime > 0 then 
		
		bleedTime = bleedTime - elapsed
		
		local damage = bleedDamage*elapsed
		local healthAfter = getHealth() - damage
		if healthAfter > 0.01+damage then
			setHealth(healthAfter)
		else
			--setHealth(damage)
		end
	end

	local targetVigSize = bleedTime*0.05
	if targetVigSize < 0 then 
		targetVigSize = 0 
	end
	vigSize = lerp(vigSize, targetVigSize, elapsed*8)
	setShaderProperty('bleed', 'size', vigSize)
end