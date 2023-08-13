
--Setup stuff-- dont mess with

local noteXPos = {}
local targetnoteXPos = {}
local noteYPos = {}
local targetnoteYPos = {}
local noteZPos = {}
local noteZScale = {}
local targetnoteZPos = {}
local noteAngle = {}
local targetnoteAngle = {}
local startSpeed = 1
local defaultZoom = 0.53
local curOpponent = 'opponent'


--based on code from andromeda engine, but with lua
local velChanges = {

	--step, speed mult
	{0, 1},
	{320, 0.8},
	{324, 0.5},
	{328, 1},
	{376, 1.3},
	{384, 1},
	{448, 0.8},
	{456, 1},
	{504, 0.9},
	{512, 1},
	{624, 1.2},
	{640, 1},
	{768, 1.25},
	{887, 0.9},
	{896, 1.2},
	{1000, 0.8},
	{1008, 0.65},
	{1015, 0.9},
	{1024, 1},
	{1056, 0.8},
	{1072, 1.1},
	{1088, 1},
	{1136, 1.2},
	{1152, 1},
	{1280, 1.2},
	{1392, 0.85},
	{1408, 0.95},

	{1504, 0.95},
	{1508, 0.9},
	{1512, 0.85},
	{1516, 0.8},
	{1520, 0.7},
	{1528, 0.6},

	{1536, 1},

	{1696, 1.2},
	{1700, 1},

	{1704, 1.2},
	{1708, 1},
	{1712, 1.2},
	{1716, 1},
	{1720, 1.2},
	{1724, 1},

	{1824, 0.9},
	{1840, 1.1},
	{1856, 1},

	{1904, 1.2},
	{1920, 1},

	{2048, 0.9},
	{2176, 1.1},
	{2240, 1},

	{2272, 0.9},
	{2280, 0.8},
	{2288, 0.95},
	{2296, 1},

	{2624, 0.8},
	{2632, 1},
	{2680, 1.2},
	{2688, 1},
	{2752, 0.8},
	{2760, 1},

	{2816, 1.3},
	{2828, 0.6},
}
local velMarkers = {

}
function mapVelChanges()

	for i = 1, #velChanges do  --convert from step to millseconds
		velChanges[i][1] = velChanges[i][1]*crochetUnscaled
	end


	local pos = 0

	velMarkers[1] = (velChanges[1][1]*velChanges[1][2])

	for i = 2, #velChanges do 
		pos = pos + ((velChanges[i][1]-velChanges[i-1][1])*velChanges[i-1][2]) --precalc scaled time
		velMarkers[i] = pos
	end
end
function getVelIdx(time)
	local idx = 1
	for i = 1, #velChanges do 
		if time >= velChanges[i][1] then 
			idx = i
		end
	end
	return idx
end
function getTime(time)

	local i = getVelIdx(time)

	local pos = velMarkers[i]
	pos = pos + ((time-velChanges[i][1])*(velChanges[i][2]));

	return pos

end

function getSpeed(time)
	local i = getVelIdx(time)
	return velChanges[i][2]
end


function createPost()
	mapVelChanges()
	showOnlyStrums = true
	startSpeed = getProperty('', 'speed')
	for i = 0, (keyCount+playerKeyCount)-1 do 
		table.insert(noteXPos, 0) --setup default pos and whatever
		table.insert(noteYPos, 0)
		table.insert(noteZPos, 0)
		table.insert(noteZScale, 1)
		table.insert(noteAngle, 0)
		table.insert(targetnoteXPos, 0)
		table.insert(targetnoteYPos, 0)
		table.insert(targetnoteZPos, 0)
		table.insert(targetnoteAngle, 0) --start angle at weird number for start
		noteXPos[i+1] = getActorX(i)
		targetnoteXPos[i+1] = getActorX(i)
		targetnoteYPos[i+1] = _G['defaultStrum'..i..'Y']
		noteYPos[i+1] = _G['defaultStrum'..i..'Y']


        
        makeSprite('note'..i, '', 0, 0)
        makeSprite('angle'..i, '', 0, 0)
		makeSprite('reverse'..i, '', 0, 0)
	end
    makeSprite('scale', '', 1, 1)

    makeSprite('playerAngle', '', 0, 0)
    makeSprite('opponentAngle', '', 0, 0)
    makeSprite('angle', '', 0, 0)

   

    makeSprite('global', '', 0, 0)
    makeSprite('player', '', 0, 0)
    makeSprite('opponent', '', 0, 0)

    makeSprite('noteRot', '', 0, 0)


	makeSprite('songPosOffset', '', 0, 0)

    setActorAlpha(0, 'global')


	initShader('mirror', 'MirrorRepeatEffect')
	setCameraShader('game', 'mirror')
	if modcharts then 
		setCameraShader('hud', 'mirror')
	end
	setShaderProperty('mirror', 'zoom', 1.0)
	defaultZoom = getProperty('', 'defaultCamZoom')
	--trace(defaultZoom)

	if opponentPlay then 
		curOpponent = 'player'
	end
end
local noteScale = 1
function lerp(a, b, ratio)
	return a + ratio * (b - a); --the funny lerp
end
local defaultNoteScale = -1

local defaultWidth = -1
local defaultSusWidth = -1
local defaultSusHeight = -1
local defaultSusEndHeight = -1

local noteRotX = 0
local targetNoteRotX = 0

function getNoteX(i)
    local pos = targetnoteXPos[i+1] + getActorX('global') + getActorX('note'..i)
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
    end
    pos = pos + getActorX(p)
    return pos
end
function getNoteY(i)
    local pos = targetnoteYPos[i+1] + getActorY('global') + getActorY('note'..i)
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
    end
    pos = pos + getActorY(p)

	local scrollSwitch = 520
	if downscrollBool then 
		scrollSwitch = -520
	end
	pos = pos + (getActorY('reverse'..i)*scrollSwitch)

    return pos
end
function getNoteZ(i)
    local pos = getActorAngle('global') + getActorAngle('note'..i)
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
    end
    pos = pos + getActorAngle(p)
    return pos
end
function getNoteAngle(i)
    local pos = getActorAngle('angle') + getActorAngle('angle'..i)
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
    end
    pos = pos + getActorAlpha(p..'Angle')
    return pos
end
function getNoteAlpha(i)
    local pos = getActorAlpha('global') * getActorAlpha('note'..i)
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
    end
    pos = pos * getActorAlpha(p)
    return pos
end

function getNoteDist(i)
	local dist = -0.45 

	dist = dist * (1-(getActorY('reverse'..i)*2));
	if downscrollBool then 
		dist = dist * -1
	end
	return dist
end

function updatePost(elapsed)
	if not modcharts then 
		return
	end
	local songSpeed = getProperty('', 'speed')
	local songVisualPos = getTime(songPos) + getActorX('songPosOffset')

	noteScale = getActorX('scale')
	noteRotX = getActorX('noteRot')

	--drunk = lerp(drunk, drunkLerp, elapsed*5)

	local currentBeat = (songPos / 1000)*(bpm/60)

	for i = 0,(keyCount+playerKeyCount)-1 do 
		noteXPos[i+1] = getNoteX(i)
		noteYPos[i+1] = getNoteY(i)
		noteZPos[i+1] = getNoteZ(i)

		local thisnotePosX = noteXPos[i+1] + getXOffset(i, 0)
		local thisnotePosY = noteYPos[i+1]
		local thisnotePosZ = (noteZPos[i+1]*0.001)-1
		--local thisnotePosX = noteXPos[i+1]
		--local thisnotePosY = noteYPos[i+1]
		--local thisnotePosZ = (noteZPos[i+1]/1000)-1

		--noteAngle[i+1] = lerp(noteAngle[i+1], targetnoteAngle[i+1], elapsed*lerpSpeedAngle)
		setActorModAngle(getNoteAngle(i), i)
        setActorAlpha(getNoteAlpha(i), i)

		local totalNotePos = calculatePerspective(thisnotePosX, thisnotePosY, thisnotePosZ)
		
		--setActorX(noteXPos[i+1], i)
		--setActorY(noteYPos[i+1], i)
		setActorX(totalNotePos[1], i)
		setActorY(totalNotePos[2], i)
		
		noteZScale[i+1] = totalNotePos[3]
		setActorScaleXY(noteScale * (1/-noteZScale[i+1]), noteScale * (1/-noteZScale[i+1]), i)
		if getPlayingActorAnimation(i) == 'confirm' then 
			setActorScaleXY(noteScale*1.45 * (1/-noteZScale[i+1]), noteScale*1.45 * (1/-noteZScale[i+1]), i) --confirm is weird ig
		end
		
	end
	local s = getSpeed(songPos)
	local noteCount = getRenderedNotes()
	if noteCount>0 then 
		for i = 0, noteCount-1 do 
			local data = getRenderedNoteType(i)
			if getRenderedNoteHit(i) then 
				data = data + keyCount --player notes
			end
			if defaultWidth == -1 then 
				defaultWidth = getRenderedNoteWidth(i)
			end
			if defaultNoteScale == -1 then 
				defaultNoteScale = getRenderedNoteScaleX(i)
			end
			local offsetX = getRenderedNoteOffsetX(i)
			local strumTime = getRenderedNoteStrumtime(i)
			local dist = getNoteDist(data)
			if dist > 0 then --downscroll
				if isRenderedNoteSustainEnd(i) then 
					strumTime = getRenderedNotePrevNoteStrumtime(i)
				end
			end
			
			strumTime = getTime(strumTime)
			local curPos = ((songVisualPos-strumTime)) * songSpeed
			offsetX = offsetX + getXOffset(data, curPos)
			local thisnoteYPos = noteYPos[data+1]
			thisnoteYPos = thisnoteYPos + (dist*curPos) - (getRenderedNoteOffsetY(i))
			if dist > 0 then --downscroll
				if isRenderedNoteSustainEnd(i) then 
					thisnoteYPos = thisnoteYPos - (getRenderedNoteHeight(i))+2
				end
			--else 
				--thisnoteYPos = thisnoteYPos - (0.45*curPos) - (getRenderedNoteOffsetY(i))
			end
            
			local thisnoteXPos = noteXPos[data+1]+offsetX
			local thisnotePosZ = (noteZPos[data+1]*0.001)-1
			local totalNotePos = calculatePerspective(thisnoteXPos, thisnoteYPos, thisnotePosZ)

            local zScale = (1/-totalNotePos[3])

            local alpha = getNoteAlpha(data)

			if not isSustain(i) then 
				--setRenderedNoteScale(getRenderedNoteWidth(i)*,getRenderedNoteHeight(i)*noteScale * (1/-totalNotePos[3]), i)
				setRenderedNoteScaleX(defaultNoteScale*noteScale * zScale, i)
				setRenderedNoteScaleY(defaultNoteScale*noteScale * zScale, i)
				setRenderedNoteAlpha(alpha,i)
				setRenderedNoteAngle(getNoteAngle(data),i)
			else
				--offsetX = 37 * (1/-totalNotePos[3]) * (defaultWidth/112)
				setRenderedNoteAlpha(alpha*0.6,i)
				if defaultSusWidth == -1 then 
					defaultSusWidth = getRenderedNoteWidth(i)
				end
				if isRenderedNoteSustainEnd(i) then --sustain ends
					setRenderedNoteScale(defaultSusWidth*noteScale * zScale,1, i)
					setRenderedNoteScaleY(getRenderedNoteSustainScaleY(i)* zScale, i)
				else 
					setRenderedNoteScale(defaultSusWidth*noteScale * zScale,1, i)
					setRenderedNoteScaleY(getRenderedNoteSustainScaleY(i)* zScale * (songSpeed/startSpeed) * s, i)
				end

				setRenderedNoteAngle(0,i)
				--susOffset = 37*noteScale
			end
			
			setRenderedNotePos(totalNotePos[1],totalNotePos[2], i)
		end
	end

end

function getXOffset(data, curPos)

	local xOffset = 0
	--if drunk ~= 0 then 
	--	xOffset = xOffset + drunk * (math.cos( ((songPos*0.001) + ((data%keyCount)*0.2) + (curPos*0.45)*(10/720)) * (drunkSpeed*0.2)) * 112*0.5);
	--end

	return xOffset
end

--the funny perspective math

local zNear = 0
local zFar = 1000
local zRange = zNear - zFar 
local tanHalfFOV = math.tan(math.pi/4) -- math.pi/2 = 90 deg, then half again

function calculatePerspective(x,y,z)

	if (z >= 1) then
		z = 1 --stop weird shit
	end

	x = x - (1280/2) + (defaultWidth/2)
	y = y - (720/2) + (defaultWidth/2)

	local zPerspectiveOffset = (z+(2 * zFar * zNear / zRange));

	local xPerspective = x*(1/tanHalfFOV);
	local yPerspective = y/(1/tanHalfFOV);
	xPerspective = xPerspective/-zPerspectiveOffset;
	yPerspective = yPerspective/-zPerspectiveOffset;

	xPerspective = xPerspective + (1280/2) - (defaultWidth/2)
	yPerspective = yPerspective + (720/2) - (defaultWidth/2)

	return {xPerspective,yPerspective,zPerspectiveOffset}
end
local rad = math.pi/180;
--the funny spherical to cartesian for 3d angles
function getCartesianCoords3D(theta, phi, radius)

	local x = 0
	local y = 0
	local z = 0

	x = math.cos(theta*rad)*math.sin(phi*rad);
	y = math.cos(phi*rad);
	z = math.sin(theta*rad)*math.sin(phi*rad);
	x = x*radius;
	y = y*radius;
	z = z*radius;

	return {x,y,z/1000}
end

--https://stackoverflow.com/questions/5294955/how-to-scale-down-a-range-of-numbers-with-a-known-min-and-max-value
function scale(valueIn, baseMin, baseMax, limitMin, limitMax)
	return ((limitMax - limitMin) * (valueIn - baseMin) / (baseMax - baseMin)) + limitMin
end


function playerTwoSing(data, time, type)
	
end

local downscrollDiff = -1

function songStart()

    if downscrollBool then 
        downscrollDiff = 1
    end

    setActorX(-400, 'opponent')
    setActorX(400, 'player')

    setActorY(-400*downscrollDiff, 'opponent')
    setActorY(-400*downscrollDiff, 'player')

    local time = crochet*0.001*4*16*4
    local ease = 'cubeInOut'

    for i = 0,3 do 
		--if not middlescroll then 
			setActorX(((0-(i+1+1))+4)*-20, 'note'..i)
			setActorX((i+1)*20, 'note'..(i+4))
	
			setActorAngle(((0-(i+1+1))+4)*300, 'note'..i)
			setActorAngle((i+1)*300, 'note'..(i+4))
	
			setActorAngle(((0-(i))+4)*-360, 'angle'..i)
			setActorAngle((i+1)*-360, 'angle'..(i+4))
		--else 
			--[[if i < 2 then 
				setActorX(((0-(i+1+1))+4)*-20, 'note'..(i+4))
				setActorAngle(((0-(i+1+1))+4)*300, 'note'..(i+4))
				setActorAngle(((0-(i))+4)*-360, 'angle'..(i+4))
			else 
				setActorX((i+1)*20, 'note'..(i+4))
				setActorAngle((i+1)*300, 'note'..(i+4))		
				setActorAngle((i+1)*-360, 'angle'..(i+4))
			end]]--
			

		--end
 

        tweenActorProperty('note'..i, 'x', 0, time, ease)
        tweenActorProperty('note'..(i+4), 'x', 0, time, ease)
        tweenActorProperty('note'..i, 'angle', 0, time, ease)
        tweenActorProperty('note'..(i+4), 'angle', 0, time, ease)
        tweenActorProperty('angle'..i, 'angle', 0, time, ease)
        tweenActorProperty('angle'..(i+4), 'angle', 0, time, ease)
    end

    tweenActorProperty('opponent', 'x', 0, time, ease)
    tweenActorProperty('player', 'x', 0, time, ease)
    tweenActorProperty('opponent', 'y', 0, time, ease)
    tweenActorProperty('player', 'y', 0, time, ease)

    tweenActorProperty('global', 'alpha', 1, time, ease)

	tweenActorProperty('camGame', 'zoom', 0.9, time, ease)

end

function funnySpeedChange(to, time)
	--[[local curSpeed = getProperty('', 'speed')
	triggerEvent("change scroll speed", ''..to, '0')
	--setActorX((crochet*4*to) - (crochet*4*curSpeed), 'songPosOffset')
	setActorX(-((1000*time*curSpeed) - (1000*time*to)), 'songPosOffset')
	tweenActorProperty('songPosOffset', 'x', 0, time, 'linear')]]--
end

function stepHit(curStep)

	if curStep % 32 == 0 then 
		--funnySpeedChange(2.3, 1)	
	end
	if curStep % 32 == 16 then 
		--funnySpeedChange(3.2, 1)
	end
	
    if curStep == 248 then 
        --tweenActorProperty('player', 'angle', -500, 2, 'cubeOut')
        tweenActorProperty('playerAngle', 'angle', -360, crochet*0.001*4, 'cubeOut')
        tweenActorProperty('opponentAngle', 'angle', -360, crochet*0.001*8, 'cubeIn')
		if not middlescroll then 
        tweenActorProperty('opponent', 'x', 320, crochet*0.001*8, 'cubeIn')
		end
    elseif curStep == 252 then 
        tweenActorProperty('player', 'y', 400*downscrollDiff, crochet*0.001*8, 'cubeOut')
    elseif curStep == 256 then 
		if not middlescroll then 
        setActorX(-320, 'player')
		end
		showOnlyStrums = false
    elseif curStep == 376-8 then
		if not (opponentPlay) then 
			tweenActorProperty('opponent', 'y', -1280*downscrollDiff, crochet*0.001*12, 'expoInOut')
			tweenActorProperty('opponent', 'angle', 1000, crochet*0.001*12, 'expoInOut')
		end
		if opponentPlay then 
			tweenActorProperty(curOpponent, 'alpha', 0.15, crochet*0.001*8, 'expoInOut')
		end

    elseif curStep == 376 then
        
        tweenActorProperty('player', 'y', 0, crochet*0.001*8, 'cubeOut')
    end

    if curStep == 476 then 
		if not (opponentPlay) then 
			setActorAlpha(0, 'opponent')
			setActorY(0, 'opponent')
			setActorAngle(0, 'opponent')
			setActorX(-112*2, 'note0')
			setActorX(-112*2, 'note1')
			setActorX(112*2, 'note2')
			setActorX(112*2, 'note3')

			setActorAngle(-400, 'note0')
			setActorAngle(-200, 'note1')
			setActorAngle(-200, 'note2')
			setActorAngle(-400, 'note3')

			for i = 0, 3 do 
				tweenActorProperty('note'..i, 'angle', 0, crochet*0.001*8, 'cubeIn')
			end
		
			tweenActorProperty(curOpponent, 'alpha', 1, crochet*0.001*8, 'expoInOut')
		else 
			
		end

		if opponentPlay then 
			tweenActorProperty(curOpponent, 'alpha', 0.15, crochet*0.001*8, 'expoInOut')
		end



        
    elseif curStep == 504 then 
        for i = 0, 3 do 
            tweenActorProperty('note'..i, 'x', 0, crochet*0.001*8, 'cubeIn')
            tweenActorProperty('note'..i, 'angle', 0, crochet*0.001*8, 'cubeIn')
            tweenActorProperty('note'..(i+4), 'angle', -500, crochet*0.001*8, 'cubeIn')
        end
        tweenActorProperty('note4', 'x', 112+56, crochet*0.001*8, 'cubeIn')
        tweenActorProperty('note5', 'x', 56, crochet*0.001*8, 'cubeIn')
        tweenActorProperty('note6', 'x', -56, crochet*0.001*8, 'cubeIn')
        tweenActorProperty('note7', 'x', -112-56, crochet*0.001*8, 'cubeIn')

    elseif curStep == 512 then 
        tweenActorProperty('note4', 'x', 0, crochet*0.001*16, 'cubeOut')
        tweenActorProperty('note5', 'x', 0, crochet*0.001*16, 'cubeOut')
        tweenActorProperty('note6', 'x', 0, crochet*0.001*16, 'cubeOut')
        tweenActorProperty('note7', 'x', 0, crochet*0.001*16, 'cubeOut')
        tweenActorProperty(curOpponent, 'alpha', 0.15, crochet*0.001*8, 'expoInOut')
    elseif curStep == 544+8 then 
		
    elseif curStep == 560 then 
        for i = 0, 3 do 
            tweenActorProperty('note'..i, 'angle', -500, crochet*0.001*16, 'cubeOut')
            tweenActorProperty('note'..(i+4), 'angle', 0, crochet*0.001*16, 'cubeOut')
        end
    end

	if curStep == 620 or curStep == 1900 then 
        for i = 0, 3 do 
            tweenActorProperty('note'..i, 'angle', 0, crochet*0.001*4, 'cubeOut')
        end
		tweenActorProperty(curOpponent, 'alpha', 1, crochet*0.001*4, 'expoInOut')
		if not middlescroll then 
		tweenActorProperty('opponent', 'x', 320-112-112, crochet*0.001*16, 'cubeOut')
		tweenActorProperty('player', 'x', -320+112+112, crochet*0.001*16, 'cubeOut')
		end
		setProperty('', 'cameraSpeed', 3)
		tweenStageColorSwap('hue', 0.1, crochet*0.001*4, 'cubeIn')
	elseif curStep == 640 or curStep == 1920 then 
		tweenActorProperty(curOpponent, 'alpha', 0.15, crochet*0.001*4, 'expoInOut')
		if not middlescroll then 
		tweenActorProperty('opponent', 'x', 320, crochet*0.001*16, 'cubeIn')
		tweenActorProperty('player', 'x', -320, crochet*0.001*16, 'cubeIn')
		end

		--tweenActorProperty('player', 'angle', -500, crochet*0.001*16, 'cubeIn')
		for i = 0, 3 do 
			if opponentPlay then 
				tweenActorProperty('reverse'..(i+4), 'y', 1, crochet*0.001*16, 'cubeOut')
			else 
				tweenActorProperty('reverse'..(i), 'y', 1, crochet*0.001*16, 'cubeOut')
			end
			
		end
		setProperty('', 'cameraSpeed', 1.5)
		tweenStageColorSwap('hue', 0, crochet*0.001*4, 'cubeOut')
		
	elseif curStep == 688 or curStep == 1200 or curStep == 1968 then 
		setProperty('', 'cameraSpeed', 1.5)
		for i = 0, 3 do 
			if opponentPlay then 
				tweenActorProperty('reverse'..(i+4), 'y', 0, crochet*0.001*4, 'cubeOut')
				tweenActorProperty('reverse'..(i), 'y', 1, crochet*0.001*4, 'cubeOut')
			else 
				tweenActorProperty('reverse'..(i+4), 'y', 1, crochet*0.001*4, 'cubeOut')
				tweenActorProperty('reverse'..(i), 'y', 0, crochet*0.001*4, 'cubeOut')
			end

		end
		
	elseif curStep == 672 or curStep == 704 then 
		for i = 0, 3 do 
			--tweenActorProperty('reverse'..(i+4), 'y', 1, crochet*0.001*16, 'cubeOut')
			--tweenActorProperty('reverse'..(i), 'y', 0, crochet*0.001*16, 'cubeOut')
		end
	elseif curStep == 736 then 
		tweenActorProperty('player', 'angle', -500, crochet*0.001*4, 'cubeOut')
		for i = 0, 3 do 
			tweenActorProperty('reverse'..(i+4), 'y', 0, crochet*0.001*4, 'cubeOut')
			tweenActorProperty('reverse'..(i), 'y', 0, crochet*0.001*4, 'cubeOut')
		end

		tweenActorProperty('note0', 'x', 0, crochet*0.001*4, 'cubeIn')
        tweenActorProperty('note1', 'x', 0, crochet*0.001*4, 'cubeIn')
        tweenActorProperty('note2', 'x', 0, crochet*0.001*4, 'cubeIn')
        tweenActorProperty('note3', 'x', 0, crochet*0.001*4, 'cubeIn')
	elseif curStep == 752 then 
		if not middlescroll then 
		tweenActorProperty('player', 'x', -320+112+112, crochet*0.001*8, 'cubeOut')
		end
		tweenActorProperty('opponent', 'angle', 0, crochet*0.001*16, 'cubeIn')
	elseif curStep == 760 then 
		if not middlescroll then 
		tweenActorProperty('opponent', 'x', 320-112-112, crochet*0.001*8, 'cubeOut')
		end
		tweenActorProperty('player', 'angle', 0, crochet*0.001*4, 'cubeOut')
	end


	if curStep == 768 then 
		setProperty('', 'cameraSpeed', 2.5)
		setProperty('', 'defaultCamZoom', 0.8)
		tweenStageColorSwap('hue', 0.05, crochet*0.001*4, 'cubeIn')
		tweenActorProperty(curOpponent, 'alpha', 1, crochet*0.001*4, 'expoInOut')
		if not middlescroll then 
		tweenActorProperty('opponent', 'x', 320+56, crochet*0.001*16*7.5, 'expoIn')
		end
		tweenActorProperty('note4', 'x', 112+112+56, crochet*0.001*16*7.5, 'expoIn')
		tweenActorProperty('note5', 'x', 112+56+28, crochet*0.001*16*7.5, 'expoIn')
		tweenActorProperty('note6', 'x', 56+28, crochet*0.001*16*7.5, 'expoIn')
	elseif curStep == 888 then 
		if not middlescroll then 
		tweenActorProperty('opponent', 'x', 320-112-112, crochet*0.001*4, 'cubeOut')
		end
		tweenActorProperty('note4', 'x', 0, crochet*0.001*4, 'cubeOut')
		tweenActorProperty('note5', 'x', 0, crochet*0.001*4, 'cubeOut')
		tweenActorProperty('note6', 'x', 0, crochet*0.001*4, 'cubeOut')
	elseif curStep == 896 then 
		if not middlescroll then 
		tweenActorProperty('player', 'x', -320-56, crochet*0.001*16*7.5, 'expoIn')
		end
		tweenActorProperty('note3', 'x', -112-112-56, crochet*0.001*16*7.5, 'expoIn')
		tweenActorProperty('note2', 'x', -112-56-28, crochet*0.001*16*7.5, 'expoIn')
		tweenActorProperty('note1', 'x', -56-28, crochet*0.001*16*7.5, 'expoIn')
	elseif curStep == 1016 then 
		tweenActorProperty('player', 'x', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('opponent', 'x', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('note3', 'x', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('note2', 'x', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('note1', 'x', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('player', 'alpha', 0, crochet*0.001*8, 'expoOut')
		setProperty('', 'cameraSpeed', 1.5)
		setProperty('', 'defaultCamZoom', defaultZoom)
		tweenStageColorSwap('hue', 0, crochet*0.001*4, 'cubeIn')
	end

	if curStep == 1056 then 
		tweenActorProperty('player', 'alpha', 1, crochet*0.001*8, 'expoOut')
	elseif curStep == 1056+8 then 
		if not middlescroll then 
		tweenActorProperty('player', 'x', -640, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('opponent', 'x', 640, crochet*0.001*8, 'cubeOut')
		end
	end

	if curStep == 1132 then 
		if not middlescroll then 
		tweenActorProperty('player', 'x', -320-112-112, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('opponent', 'x', 320+112+112, crochet*0.001*8, 'cubeOut')
		end
		setProperty('', 'cameraSpeed', 3)
		tweenStageColorSwap('hue', 0.1, crochet*0.001*4, 'cubeIn')
	elseif curStep == 1152 then 
		setProperty('', 'cameraSpeed', 1.5)
		tweenStageColorSwap('hue', 0, crochet*0.001*4, 'cubeOut')
		tweenActorProperty(curOpponent, 'alpha', 0.15, crochet*0.001*4, 'expoInOut')
		if not middlescroll then 
		tweenActorProperty('player', 'x', -320, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('opponent', 'x', 320, crochet*0.001*8, 'cubeOut')
		end
		for i = 0, 3 do 
			if opponentPlay then 
				tweenActorProperty('reverse'..(i), 'y', 0, crochet*0.001*16, 'cubeOut')
			else 
				tweenActorProperty('reverse'..(i), 'y', 1, crochet*0.001*16, 'cubeOut')
			end
			
		end
	elseif curStep == 1248 then 
		for i = 0, 3 do 
			tweenActorProperty('reverse'..(i+4), 'y', 0, crochet*0.001*4, 'cubeOut')
			tweenActorProperty('reverse'..(i), 'y', 0, crochet*0.001*4, 'cubeOut')
		end
	elseif curStep == 1264 or curStep == 1328 then 
		tweenActorProperty('player', 'x', 0, crochet*0.001*8, 'cubeOut')
		tweenActorProperty(curOpponent, 'alpha', 1, crochet*0.001*4, 'expoInOut')
	elseif curStep == 1264+8 or curStep == 1328+8 then 
		tweenActorProperty('opponent', 'x', 0, crochet*0.001*8, 'cubeOut')
	elseif curStep == 1312 then 
		if not middlescroll and not opponentPlay then 
		tweenActorProperty('player', 'x', -640, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('opponent', 'x', 640, crochet*0.001*8, 'cubeOut')
		end
	elseif curStep == 1392 then 
		if not middlescroll then 
		tweenActorProperty('player', 'x', -320, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('opponent', 'x', 320, crochet*0.001*8, 'cubeOut')
		end
		tweenActorProperty(curOpponent, 'alpha', 0.15, crochet*0.001*4, 'expoInOut')
		tweenShaderProperty('mirror', 'angle', 30, crochet*0.001*8, 'cubeOut')
	elseif curStep == 1392+8 then 
		tweenShaderProperty('mirror', 'angle', -30, crochet*0.001*8, 'cubeOut')
	elseif curStep == 1392+16 then 
		tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeOut')
	end



	if curStep == 248 then 
		if not opponentPlay then 
		tweenShaderProperty('mirror', 'zoom', 10, crochet*0.001*8, 'cubeIn')
		end
	elseif curStep == 248+8 then 
		tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
		flashCamera('game', '#FFFFFF', 1)
	end
	if curStep == 504 then 
		if not opponentPlay then 
			tweenShaderProperty('mirror', 'zoom', 0.2, crochet*0.001*8, 'cubeIn')
		end
		
	elseif curStep == 504+8 then 
		tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
		flashCamera('game', '#FFFFFF', 1)
	end
	--[[if curStep == 760 then 
		tweenShaderProperty('mirror', 'zoom', 10, crochet*0.001*8, 'cubeIn')
	elseif curStep == 760+8 then 
		tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
	end]]--
	if curStep == 1272 then 
		if not opponentPlay then 
		tweenShaderProperty('mirror', 'zoom', 10, crochet*0.001*6, 'cubeIn')
		end
	elseif curStep == 1272+6 then 
		tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
		flashCamera('game', '#FFFFFF', 1)
	end
	if curStep == 1008 then 
		if not opponentPlay then 
		tweenShaderProperty('mirror', 'zoom', 0.2, crochet*0.001*16, 'cubeIn')
		end
	elseif curStep == 1008+16 then 
		tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
		flashCamera('game', '#FFFFFF', 1)
	end
	if curStep == 1520 then 
		if not opponentPlay then 
			tweenShaderProperty('mirror', 'zoom', 10, crochet*0.001*16, 'cubeIn')
			tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*16, 'cubeIn')
		end

	elseif curStep == 1520+16 then 
		tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
		tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*2, 'cubeOut')
		flashCamera('game', '#FFFFFF', 1)
	end

	if curStep == 1536 then 
		tweenActorProperty('player', 'x', 0, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('opponent', 'x', 0, crochet*0.001*8, 'cubeOut')
		tweenActorProperty(curOpponent, 'alpha', 1, crochet*0.001*4, 'expoInOut')
	end

	if curStep == 1692 then 
		tweenStageColorSwap('hue', -0.05, crochet*0.001*4, 'cubeIn')
	elseif curStep == 1728 then 
		tweenStageColorSwap('hue', 0, crochet*0.001*4, 'cubeOut')
	end

	if curStep == 1692 or curStep == 1692+8 or curStep == 1692+16 or curStep == 1692+24 then 
		if not middlescroll then 
		tweenActorProperty('player', 'x', -320+112+112, crochet*0.001*4, 'backIn')
		tweenActorProperty('opponent', 'x', 320-112-112, crochet*0.001*4, 'backIn')
		end
	elseif curStep == 1692+4 or curStep == 1692+4+8 or curStep == 1692+4+16 or curStep == 1692+4+24 then 
		tweenActorProperty('player', 'x', 0, crochet*0.001*4, 'backOut')
		tweenActorProperty('opponent', 'x', 0, crochet*0.001*4, 'backOut')
	end
	if curStep == 1724 then 
		if not middlescroll then 
		tweenActorProperty('player', 'x', -320, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('opponent', 'x', 320, crochet*0.001*8, 'cubeOut')
		end
		tweenActorProperty(curOpponent, 'alpha', 0.15, crochet*0.001*4, 'expoInOut')
	elseif curStep == 1760 then 
		for i = 0, 3 do 
			if opponentPlay then 
				tweenActorProperty('reverse'..(i+4), 'y', 0, crochet*0.001*4, 'cubeOut')
				tweenActorProperty('reverse'..(i), 'y', 1, crochet*0.001*4, 'cubeOut')
			else 
				tweenActorProperty('reverse'..(i+4), 'y', 1, crochet*0.001*4, 'cubeOut')
				tweenActorProperty('reverse'..(i), 'y', 0, crochet*0.001*4, 'cubeOut')
			end

		end
	elseif curStep == 1776 then 
		for i = 0, 3 do 
			if opponentPlay then 
				tweenActorProperty('reverse'..(i+4), 'y', 1, crochet*0.001*4, 'cubeOut')
				tweenActorProperty('reverse'..(i), 'y', 0, crochet*0.001*4, 'cubeOut')
			else 
				tweenActorProperty('reverse'..(i+4), 'y', 0, crochet*0.001*4, 'cubeOut')
				tweenActorProperty('reverse'..(i), 'y', 1, crochet*0.001*4, 'cubeOut')
			end

		end
	elseif curStep == 1824 then 
		tweenActorProperty('player', 'x', 0, crochet*0.001*4, 'cubeOut')
	elseif curStep == 1832 then 
		tweenActorProperty('opponent', 'x', 0, crochet*0.001*4, 'cubeOut')
		tweenActorProperty(curOpponent, 'alpha', 1, crochet*0.001*4, 'cubeOut')
		for i = 0, 3 do 
			tweenActorProperty('reverse'..(i+4), 'y', 0, crochet*0.001*4, 'cubeOut')
			tweenActorProperty('reverse'..(i), 'y', 0, crochet*0.001*4, 'cubeOut')
		end
	elseif curStep == 1848 then 
		for i = 0, 3 do 
			tweenActorProperty('reverse'..(i+4), 'y', 0, crochet*0.001*8, 'cubeOut')
		end
	end

	if curStep == 1984 then 
		for i = 0, 3 do 
			tweenActorProperty('reverse'..(i+4), 'y', 0, crochet*0.001*4, 'cubeOut')
			tweenActorProperty('reverse'..(i), 'y', 0, crochet*0.001*4, 'cubeOut')
		end
		
	elseif curStep == 2048 then 
		tweenStageColorSwap('hue', -0.05, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('player', 'x', 0, crochet*0.001*16, 'cubeOut')
		tweenActorProperty('opponent', 'x', 0, crochet*0.001*16, 'cubeOut')
		tweenActorProperty(curOpponent, 'alpha', 1, crochet*0.001*16, 'cubeOut')
	elseif curStep == 2064 or curStep == 2128 then 
		if not middlescroll then 
		tweenActorProperty('player', 'x', -640, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('opponent', 'x', 640, crochet*0.001*8, 'cubeOut')
		end
	elseif curStep == 2096 or curStep == 2160 then 
		tweenActorProperty('player', 'x', 0, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('opponent', 'x', 0, crochet*0.001*8, 'cubeOut')
	elseif curStep == 2176 then 
		tweenStageColorSwap('hue', 0.05, crochet*0.001*4, 'cubeIn')
		setProperty('', 'cameraSpeed', 3)
	elseif curStep == 2272 then 
		tweenStageColorSwap('hue', 0, crochet*0.001*4, 'cubeIn')
		setProperty('', 'cameraSpeed', 1.5)
		if not middlescroll then 
		tweenActorProperty('player', 'x', -320, crochet*0.001*16, 'cubeOut')
		tweenActorProperty('opponent', 'x', 320, crochet*0.001*16, 'cubeOut')
		end
		tweenActorProperty(curOpponent, 'alpha', 0.15, crochet*0.001*16, 'cubeOut')
	elseif curStep == 2304 then 
		
	elseif curStep == 2544 then 
		tweenActorProperty(curOpponent, 'alpha', 1, crochet*0.001*4, 'cubeOut')
		tweenActorProperty('opponent', 'x', 0, crochet*0.001*4, 'cubeOut')
	elseif curStep == 2552 then 
		tweenActorProperty('player', 'x', 0, crochet*0.001*4, 'cubeOut')
	end

	if curStep == 2784 or curStep == 2784+16 then 
		setProperty('', 'defaultCamZoom', 0.8)
		tweenShaderProperty('mirror', 'angle', 10, crochet*0.001*8, 'cubeOut')
	elseif curStep == 2784+8 or curStep == 2784+24 then 
		tweenShaderProperty('mirror', 'angle', -10, crochet*0.001*8, 'cubeOut')
	elseif curStep == 2816 then 
		tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*16, 'cubeOut')
	elseif curStep == 2828 then 
		tweenActorProperty('player', 'x', -1280, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('opponent', 'x', 1280, crochet*0.001*4, 'cubeIn')
	end
end

