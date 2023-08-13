
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

function createPost()
	startSpeed = getProperty('', 'speed')
	for i = 0, (keyCount*2)-1 do 
		table.insert(noteXPos, 0) --setup default pos and whatever
		table.insert(noteYPos, 0)
		table.insert(noteZPos, 0)
		table.insert(noteZScale, 1)
		table.insert(noteAngle, 0)
		table.insert(targetnoteXPos, 0)
		table.insert(targetnoteYPos, 0)
		table.insert(targetnoteZPos, 0)
		table.insert(targetnoteAngle, 0) 
		noteXPos[i+1] = getActorX(i)
		targetnoteXPos[i+1] = getActorX(i)
		targetnoteYPos[i+1] = _G['defaultStrum'..i..'Y']
		noteYPos[i+1] = _G['defaultStrum'..i..'Y']
	end

	initShader('barrel', 'MirrorRepeatEffect')

	initShader('barrelHUD', 'MirrorRepeatEffect')
	setCameraShader('game', 'barrel')
	if modcharts then 
		setCameraShader('hud', 'barrelHUD')
	end
	--setShaderProperty('barrel', 'barrel', 0.0)
	setShaderProperty('barrel', 'zoom', 1.0)
	--setShaderProperty('barrelHUD', 'barrel', 0.0)
	setShaderProperty('barrelHUD', 'zoom', 1.0)

	initShader('constrastShit', 'BloomEffect')
    setCameraShader('game', 'constrastShit')
    setCameraShader('hud', 'constrastShit')
    setShaderProperty('constrastShit', 'effect', 0)

	if opponentPlay then 
		setProperty('', 'camZooming', true)
	end

	--tweenShaderProperty('barrel', 'x', 5, crochet*0.001*64, 'cubeOut')
end
local noteScale = 1
function lerp(a, b, ratio)
	return a + ratio * (b - a); --the funny lerp
end
local defaultNoteScale = -1
local lerpX = true
local lerpY = false
local lerpAngle = true
local lerpScale = true

local defaultWidth = -1
local defaultSusWidth = -1
local defaultSusHeight = -1
local defaultSusEndHeight = -1

local notesSeen = {}

local noteRotX = 0
local targetNoteRotX = 0

local lerpSpeedScale = 5
local lerpSpeedX = 4
local lerpSpeedY = 10
local lerpSpeedZ = 4
local lerpSpeedAngle = 3
local lerpSpeednoteRotX = 5

local drunkLerp = 0
local drunk = 0
local drunkSpeed = 8

function updatePost(elapsed)
	if not modcharts then 
		return
	end
	if lerpScale then 
		noteScale = lerp(noteScale, 1, elapsed*lerpSpeedScale)
	end
	noteRotX = lerp(noteRotX, targetNoteRotX, elapsed*lerpSpeednoteRotX)

	drunk = lerp(drunk, drunkLerp, elapsed*5)

	local currentBeat = (songPos / 1000)*(bpm/60)

	for i = 0,(keyCount*2)-1 do 
		noteXPos[i+1] = lerp(noteXPos[i+1], targetnoteXPos[i+1], elapsed*lerpSpeedX)
		noteYPos[i+1] = lerp(noteYPos[i+1], targetnoteYPos[i+1], elapsed*lerpSpeedY)
		noteZPos[i+1] = lerp(noteZPos[i+1], targetnoteZPos[i+1], elapsed*lerpSpeedZ)

		local thisnotePosX = noteXPos[i+1] + getXOffset(i, 0)
		local thisnotePosY = noteYPos[i+1]
		local noteRotPos = getNoteRot(thisnotePosX, thisnotePosY, noteRotX)

		thisnotePosX = noteRotPos[1]
		thisnotePosY = noteRotPos[2]
		local thisnotePosZ = noteRotPos[3]+(noteZPos[i+1]/1000)
		--local thisnotePosX = noteXPos[i+1]
		--local thisnotePosY = noteYPos[i+1]
		--local thisnotePosZ = (noteZPos[i+1]/1000)-1

		noteAngle[i+1] = lerp(noteAngle[i+1], targetnoteAngle[i+1], elapsed*lerpSpeedAngle)
		setActorModAngle(noteAngle[i+1], i)

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
    local songSpeed = getProperty('', 'speed')
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
			if downscrollBool then 
				if isRenderedNoteSustainEnd(i) then 
					strumTime = getRenderedNotePrevNoteStrumtime(i)
				end
			end
			
			local curPos = ((songPos-strumTime)*songSpeed)
			offsetX = offsetX + getXOffset(data, curPos)
			local thisnoteYPos = noteYPos[data+1]
			if downscrollBool then 
				thisnoteYPos = thisnoteYPos + (0.45*curPos) - (getRenderedNoteOffsetY(i))
				if isRenderedNoteSustainEnd(i) then 
					thisnoteYPos = thisnoteYPos - (getRenderedNoteHeight(i))+2
				end
			else 
				thisnoteYPos = thisnoteYPos - (0.45*curPos) - (getRenderedNoteOffsetY(i))
			end
			local thisnoteXPos = noteXPos[data+1]+offsetX
			
			local noteRotPos = getNoteRot(thisnoteXPos, thisnoteYPos, noteRotX)
	
			thisnoteXPos = noteRotPos[1]
			thisnoteYPos = noteRotPos[2]
			local thisnotePosZ = noteRotPos[3]+(noteZPos[data+1]/1000)
			local totalNotePos = calculatePerspective(thisnoteXPos, thisnoteYPos, thisnotePosZ)

			if not isSustain(i) then 
				--setRenderedNoteScale(getRenderedNoteWidth(i)*,getRenderedNoteHeight(i)*noteScale * (1/-totalNotePos[3]), i)
				setRenderedNoteScaleX(defaultNoteScale*noteScale * (1/-totalNotePos[3]), i)
				setRenderedNoteScaleY(defaultNoteScale*noteScale * (1/-totalNotePos[3]), i)
				setRenderedNoteAlpha(1,i)
				setRenderedNoteAngle(noteAngle[data+1],i)
			else
				--offsetX = 37 * (1/-totalNotePos[3]) * (defaultWidth/112)
				setRenderedNoteAlpha(0.6,i)
				if defaultSusWidth == -1 then 
					defaultSusWidth = getRenderedNoteWidth(i)
				end

				if isRenderedNoteSustainEnd(i) then --sustain ends
					if defaultSusEndHeight == -1 then 
						defaultSusEndHeight = getRenderedNoteScaleY(i)
					end
					
					setRenderedNoteScale(defaultSusWidth*noteScale * (1/-totalNotePos[3]),1, i)
					setRenderedNoteScaleY(defaultSusEndHeight* (1/-totalNotePos[3]), i)
				else 
                    if defaultSusHeight == -1 then 
                        defaultSusHeight = getRenderedNoteScaleY(i)
                    end
					setRenderedNoteScale(defaultSusWidth*noteScale * (1/-totalNotePos[3]),1, i)
					setRenderedNoteScaleY(defaultSusHeight* (1/-totalNotePos[3])* (songSpeed/startSpeed), i)
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
	if drunk ~= 0 then 
		xOffset = xOffset + drunk * (math.cos( ((songPos*0.001) + ((data%keyCount)*0.2) + (curPos*0.45)*(10/720)) * (drunkSpeed*0.2)) * 112*0.5);
	end

	return xOffset
end


function getSustainAngle(i)

	local data = getRenderedNoteType(i)
	local mustPress = getRenderedNoteHit(i)
	if mustPress then 
		data = data + keyCount --player notes
	end

	local noteYPos = ((songPos-getRenderedNoteStrumtime(i))*songSpeed)
	local nextYPos = noteYPos + crochet

	local noteOffsetX = getXOffset(data, noteYPos)
	local nextOffsetX = getXOffset(data, nextYPos)

	local thisNoteX = getRenderedNoteCalcX(i)+noteOffsetX
	local nextNoteX = getRenderedNoteCalcX(i)+nextOffsetX

	local thisNoteY = getRenderedNoteY(i)
	

	local ang = 0
	if downscrollBool then 
		local nextNoteY = getRenderedNoteY(i) + (0.45*crochet*songSpeed)
		ang = math.deg(math.atan2( (nextNoteY-thisNoteY), (nextNoteX-thisNoteX) ) - (math.pi/2))
		--debugPrint(ang)
	else 
		local nextNoteY = getRenderedNoteY(i) - (0.45*crochet*songSpeed)
		ang = math.deg(math.atan2( (nextNoteY-thisNoteY), (nextNoteX-thisNoteX) ) + (math.pi/2))
	end
	return ang
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
function getNoteRot(XPos, YPos, rotX)
	local x = 0
	local y = 0
	local z = -1

	--fucking math
	local strumRotX = getCartesianCoords3D(rotX,90, XPos-(1280/2))
	x = strumRotX[1]+(1280/2)
	local strumRotY = getCartesianCoords3D(90,0, YPos-(720/2))
	y = strumRotY[2]+(720/2)
	--notePosY = _G['default'..strum..'Y'..i%keyCount]+strumRot[2]
	z = z + strumRotX[3] + strumRotY[3]
	return {x,y,z}
end
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

local modchartState = 0
function stepHit()
	--setShaderProperty('barrel', 'zoom', 6)
	
	local section = math.floor(curStep/16)
	--if section < then 
    if curStep % 32 == 0 or curStep % 32 == 6 or curStep % 32 == 12 or curStep % 32 == 16 or curStep % 32 == 24 then 
        triggerEvent('Add Camera Zoom', 0.01, 0.01)
        doModchartShit(0)
    end
    if section == 15 or section == 31 or section == 95 then 
        if curStep % 16 == 10 or curStep % 16 == 12 or curStep % 16 == 14 then 
            triggerEvent('Add Camera Zoom', 0.01, 0.01)
            doModchartShit(0)
        end
    end
	if (section >= 16 and section < 64) or (section >= 72 and section < 112) or (section >= 120 and section < 128) or (section >= 144 and section < 160) then 
		if curStep % 16 == 0 then 
			triggerEvent('Add Camera Zoom', 0.03, 0.03)
		end
		if curStep % 16 == 8 then 
			triggerEvent('Add Camera Zoom', 0.05, -0.05)
			doModchartShit(1)
		end
		if curStep % 16 == 4 or curStep % 16 == 12 then 
			triggerEvent('Add Camera Zoom', 0.015, 0.015)
		end
	end

	if section == 64+3 or section == 112+3 or section == 144+3 then 
		if curStep % 16 == 12 or curStep % 16 == 14 then 
			triggerEvent('Add Camera Zoom', 0.05, 0.05)
			noteScale = noteScale + 0.2
			setShaderProperty('barrel', 'zoom', 1.15)
			tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*2, 'cubeIn')

			if curStep % 16 == 12 then 
				tweenShaderProperty('barrel', 'x', -0.5, crochet*0.001*2, 'cubeOut')
			else 
				tweenShaderProperty('barrel', 'x', 0, crochet*0.001*2, 'cubeOut')
			end
			--doModchartShit(2)
		end
	end
	if section == 64+4 or section == 112+4 or section == 144+4 then 
		if curStep % 16 == 0 then
			tweenShaderProperty('barrel', 'x', 0.5, crochet*0.001*2, 'cubeOut')
			
			if section == 64+4 then 
				tweenShaderProperty('barrel', 'y', -3, crochet*0.001*4, 'cubeOut')
			elseif section == 112+4 then
				tweenShaderProperty('barrel', 'y', -1.5, crochet*0.001*4, 'cubeOut')
			else 
				tweenShaderProperty('barrel', 'y', -2, crochet*0.001*4, 'cubeOut')
			end
			
		end
	end
	if section == 64+7 or section == 112+7 or section == 144+7 then 
		if curStep % 16 == 8 or curStep % 16 == 12 or curStep % 16 == 14 then 
			triggerEvent('Add Camera Zoom', 0.05, 0.05)
			noteScale = noteScale + 0.2
			setShaderProperty('barrel', 'zoom', 1.15)
			tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*2, 'cubeIn')
			--doModchartShit(2)
		end

		if curStep % 16 == 8 then 
			tweenShaderProperty('barrel', 'x', 0.5, crochet*0.001*4, 'cubeOut')
		elseif curStep % 16 == 12 then 
			tweenShaderProperty('barrel', 'x', -0.5, crochet*0.001*2, 'cubeOut')
		elseif curStep % 16 == 14 then 
			tweenShaderProperty('barrel', 'x', 0, crochet*0.001*2, 'cubeOut')
		end
	end
	if section == 64+8 or section == 112+8 or section == 144+8 then 
		if curStep % 16 == 0 then
			if section == 112+8 then 
				tweenShaderProperty('barrel', 'y', -9, crochet*0.001*16*7, 'linear')
			elseif section == 144+8 then 
				tweenShaderProperty('barrel', 'x', 9, crochet*0.001*16*7, 'linear')
			else 
				--tweenShaderProperty('barrel', 'x', 9, crochet*0.001*16*7, 'linear')
			end
			if not opponentPlay then 
				tweenShaderProperty('barrelHUD', 'x', 0.25, crochet*0.001*8, 'cubeOut')
			end
			
		end
	end

	if section == 144+12 then 
		if curStep % 16 == 0 then
			tweenShaderProperty('barrel', 'y', -3, crochet*0.001*4, 'cubeOut')
		end
	end
	if section == 112+12 then 
		if curStep % 16 == 0 then
			tweenShaderProperty('barrel', 'x', 3, crochet*0.001*4, 'cubeOut')
		end
	end
	if section == 64+12 then 
		if curStep % 16 == 0 then
			tweenShaderProperty('barrel', 'y', 2, crochet*0.001*4, 'cubeOut')
		end
	end
	if section == 64+15 or section == 112+15 or section == 144+15 then 
		if curStep % 16 == 0 then
			tweenShaderProperty('barrel', 'x', 0, crochet*0.001*16, 'cubeIn')
			tweenShaderProperty('barrel', 'y', 0, crochet*0.001*16, 'cubeIn')
			tweenShaderProperty('barrelHUD', 'x', 0, crochet*0.001*16, 'cubeIn')
			tweenShaderProperty('barrelHUD', 'y', 0, crochet*0.001*16, 'cubeIn')
			tweenShaderProperty('barrel', 'zoom', 1.5, crochet*0.001*16, 'cubeOut')
			tweenShaderProperty('barrelHUD', 'zoom', 1.5, crochet*0.001*16, 'cubeOut')
		end
	end
	if section == 64+16 or section == 112+16 or section == 144+16 then 
		if curStep % 16 == 0 then
			tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*16, 'cubeOut')
			tweenShaderProperty('barrelHUD', 'zoom', 1, crochet*0.001*16, 'cubeOut')
		end
	end
	if curStep == 1000 then 
		tweenShaderProperty('barrel', 'zoom', 1.5, crochet*0.001*16, 'cubeOut')
		tweenShaderProperty('barrelHUD', 'zoom', 1.5, crochet*0.001*16, 'cubeOut')
	elseif curStep == 1016 then 
		tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*4, 'cubeIn')
		tweenShaderProperty('barrelHUD', 'zoom', 1, crochet*0.001*4, 'cubeIn')
	end
	if curStep == 1769 then 
		tweenShaderProperty('barrel', 'zoom', 1.5, crochet*0.001*16, 'cubeOut')
		tweenShaderProperty('barrelHUD', 'zoom', 1.5, crochet*0.001*16, 'cubeOut')
	elseif curStep == 1784 then 
		tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*4, 'cubeIn')
		tweenShaderProperty('barrelHUD', 'zoom', 1, crochet*0.001*4, 'cubeIn')
	end

	if curStep == 2288 or curStep == 2288+4 or curStep == 2288+4+4 or curStep == 2288+4+4+2 or curStep == 2288+4+4+2+2 or curStep == 2288+4+4+2+2+2 then 
		triggerEvent('Add Camera Zoom', 0.05, 0.05)
		noteScale = noteScale + 0.4
		setShaderProperty('barrel', 'zoom', 2)
		tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*2, 'cubeIn')

		setShaderProperty('barrelHUD', 'zoom', 2)
		tweenShaderProperty('barrelHUD', 'zoom', 1, crochet*0.001*2, 'cubeIn')
	end
	if curStep == 248 then 
		setShaderProperty('barrel', 'zoom', 1.2)
		setShaderProperty('barrelHUD', 'zoom', 1.2)
	elseif curStep == 250 then 
		setShaderProperty('barrel', 'zoom', 1.4)
		setShaderProperty('barrelHUD', 'zoom', 1.4)
	elseif curStep == 252 then 
		setShaderProperty('barrel', 'zoom', 1.6)
		setShaderProperty('barrelHUD', 'zoom', 1.6)
	elseif curStep == 254 then 
		setShaderProperty('barrel', 'zoom', 1.8)
		setShaderProperty('barrelHUD', 'zoom', 1.8)
	elseif curStep == 256 then 
		tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*2, 'cubeIn')
		tweenShaderProperty('barrelHUD', 'zoom', 1, crochet*0.001*2, 'cubeIn')
	end

	if curStep == 2656 then 
		tweenShaderProperty('barrel', 'zoom', 1.2, crochet*0.001*128, 'linear')
		tweenShaderProperty('barrel', 'angle', 20, crochet*0.001*128, 'linear')
		tweenShaderProperty('barrelHUD', 'zoom', 1.2, crochet*0.001*128, 'linear')
		tweenShaderProperty('barrelHUD', 'angle', 20, crochet*0.001*128, 'linear')
		tweenShaderProperty('constrastShit', 'contrast', -0.05, crochet*0.001*128, 'linear')
	end


	if curStep == 768 then 
		tweenShaderProperty('barrel', 'x', -0.5, crochet*0.001*8, 'expoIn')
	elseif curStep == 768+64 then 
		tweenShaderProperty('barrel', 'x', 0.5, crochet*0.001*8, 'expoIn')
	elseif curStep == 768+64+64 then 
		tweenShaderProperty('barrel', 'x', -0.5, crochet*0.001*8, 'expoIn')
	elseif curStep == 768+64+64+64 then 
		tweenShaderProperty('barrel', 'x', 0.5, crochet*0.001*8, 'expoIn')
	end

	if curStep == 1600 then 
		tweenShaderProperty('barrel', 'x', 0.5, crochet*0.001*8, 'expoIn')
	elseif curStep == 1600-64 then 
		tweenShaderProperty('barrel', 'x', -0.5, crochet*0.001*8, 'expoIn')
	elseif curStep == 1600+64 then 
		tweenShaderProperty('barrel', 'x', -0.5, crochet*0.001*8, 'expoIn')
	elseif curStep == 1600+64+64 then 
		tweenShaderProperty('barrel', 'x', 0.5, crochet*0.001*8, 'expoIn')
	elseif curStep == 1600+64+64+64 then 
		tweenShaderProperty('barrel', 'x', 0, crochet*0.001*8, 'expoIn')
	end

	if section == 64 then 
		if curStep % 16 == 0 then
			tweenShaderProperty('barrel', 'x', 0, crochet*0.001*8, 'cubeIn')
		end
	end
end
local flipShit = 1
local flipShit2 = 1
function doModchartShit(state)
    flipShit = flipShit * -1
    if state == 0 then 
        for i = 0,7 do 
            noteAngle[i+1] = 20*flipShit
        end
        noteScale = noteScale - 0.1
	elseif state == 1 then 
		flipShit2 = flipShit2 * -1
        for i = 0,3 do 
			if flipShit2 == -1 then 
				local note = (0-i)+keyCount
				noteXPos[i+1] = noteXPos[i+1] + (15 * note)
				
				noteXPos[i+1+keyCount] = noteXPos[i+1+keyCount] - (15 * i)
			else 
				noteXPos[i+1] = noteXPos[i+1] - (15 * i)
				local note = (0-i)+keyCount
				noteXPos[i+1+keyCount] = noteXPos[i+1+keyCount] + (15 * note)
			end

        end
        noteScale = noteScale + 0.25
	elseif state == 2 then 
		flipShit2 = flipShit2 * -1
		for i = 0,3 do 
			if flipShit2 == -1 then 
				local note = (0-i)+keyCount
				noteZPos[i+1] = noteZPos[i+1] + (50 * note)
				
				noteZPos[i+1+keyCount] = noteZPos[i+1+keyCount] - (50 * i)
			else 
				noteZPos[i+1] = noteZPos[i+1] - (50 * i)
				local note = (0-i)+keyCount
				noteZPos[i+1+keyCount] = noteZPos[i+1+keyCount] + (50 * note)
			end
		end
    end

end