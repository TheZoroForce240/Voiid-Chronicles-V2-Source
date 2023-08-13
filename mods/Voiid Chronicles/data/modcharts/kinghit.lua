
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

function createPost()
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

		if i >= keyCount then 
			local note = i 
			if i > 6 then 
				note = i-1
			end
			if middlescroll then 
				--noteXPos[i+1] = getActorX(note-keyCount)+(windowWidth/2)
				--targetnoteXPos[i+1] = getActorX(note-keyCount)+(windowWidth/2)
				noteXPos[i+1] = noteXPos[i+1] +25
				targetnoteXPos[i+1] = targetnoteXPos[i+1] +25
			else 
				noteXPos[i+1] = getActorX(note-keyCount)+(windowWidth/2)
				targetnoteXPos[i+1] = getActorX(note-keyCount)+(windowWidth/2)
			end

		end


		

	end
	if middlescroll then 
		noteXPos[7+1] = getActorX(5)+112+25
		targetnoteXPos[7+1] = getActorX(5)+112+25
		noteXPos[8+1] = getActorX(5)+112+112+25
		targetnoteXPos[8+1] = getActorX(5)+112+112+25
		noteXPos[6+1] = getActorX(5)+25
		targetnoteXPos[6+1] = getActorX(5)+(112*0.5)+25
	else 
		noteXPos[6+1] = getActorX(5)
		targetnoteXPos[6+1] = getActorX(5)+(112*0.75)
	end
	--defaultZoom = getProperty('', 'defaultCamZoom')
	--trace(defaultZoom)

	initShader('grey', 'GreyscaleEffect')
    setCameraShader('game', 'grey')
    setCameraShader('hud', 'grey')
    setShaderProperty('grey', 'strength', 0)

	initShader('barrel', 'BarrelBlurEffect')
	setCameraShader('game', 'barrel')
	setCameraShader('hud', 'barrel')
	setShaderProperty('barrel', 'barrel', 0.0)
	setShaderProperty('barrel', 'zoom', 1.0)
	setShaderProperty('barrel', 'doChroma', true)

	setProperty('', 'cameraZoomSpeed', 1.5)
	if opponentPlay then 
		setProperty('', 'camZooming', true)
	end
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
local lerpSpeedX = 8
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

	for i = 0,(keyCount+playerKeyCount)-1 do 
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
			local songSpeed = getProperty('', 'speed')
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
				if defaultSusHeight == -1 then 
					defaultSusHeight = getRenderedNoteScaleY(i)
				end
				if isRenderedNoteSustainEnd(i) then --sustain ends
					if defaultSusEndHeight == -1 then 
						defaultSusEndHeight = getRenderedNoteScaleY(i)
					end
					
					setRenderedNoteScale(defaultSusWidth*noteScale * (1/-totalNotePos[3]),1, i)
					setRenderedNoteScaleY(defaultSusEndHeight* (1/-totalNotePos[3]), i)
				else 
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
	if curStep == 1 then 
		setShaderProperty('bloom', 'brightness', -1.3)
		tweenShaderProperty('bloom', 'brightness', 0, crochet*0.001*128, 'cubeIn')
	elseif curStep == 128 or curStep == 896 or curStep == 1024 or curStep == 1408 or curStep == 1536 or curStep == 2944 or curStep == 3456 then
		triggerEvent('Camera Flash','White','1')
		setShaderProperty('bloom', 'contrast', 1.5)
		triggerEvent('vignette', 15, 0.8)
		setProperty('', 'defaultCamZoom', defaultZoom*1.75)
		triggerEvent('change camera speed', 2.5)
		modchartState = 1
	elseif curStep == 256 or curStep == 512 or curStep == 640 or curStep == 768 or curStep == 1280 or curStep == 2432 or curStep == 3712 or curStep == 3840 then
		triggerEvent('Camera Flash','White','1')
		setShaderProperty('bloom', 'contrast', 0.5)
		triggerEvent('vignette', 15, 0.8)
		setProperty('', 'defaultCamZoom', defaultZoom*1.25)
		triggerEvent('change camera speed', 1.5)
		modchartState = 2
	elseif curStep == 368 or curStep == 1136+16 or curStep == 1664 or curStep == 2688 or curStep == 3200 then
		tweenShaderProperty('bloom', 'contrast', 1, crochet*0.001*16, 'cubeIn')
		triggerEvent('vignette', 10, 0.4)
		tweenShaderProperty('bloom', 'brightness', 0, crochet*0.001*16, 'cubeIn')
		setProperty('', 'defaultCamZoom', defaultZoom)
		triggerEvent('change camera speed', 0.5)
		modchartState = 0
	elseif curStep == 2176 then 
		triggerEvent('Camera Flash','White','1')
		setShaderProperty('bloom', 'contrast', 0.5)
		setShaderProperty('bloom', 'brightness', -0.2)
		triggerEvent('vignette', 25, 0.8)
		setProperty('', 'defaultCamZoom', defaultZoom*1.5)
		triggerEvent('change camera speed', 1)
		modchartState = 3
	end

	if curStep == 872 or curStep == 1384 or curStep == 3688 then 
		tweenShaderProperty('grey', 'strength', 1, crochet*0.001*8, 'cubeIn')
	elseif curStep == 888 or curStep == 1400 or curStep == 3704 then 
		tweenShaderProperty('grey', 'strength', 0, crochet*0.001*8, 'cubeIn')
	end
	if curStep == 1120 or curStep == 1632 or curStep == 2912 or curStep == 3424 then 
		tweenShaderProperty('grey', 'strength', 1, crochet*0.001*16, 'cubeIn')
	elseif curStep == 1136 or curStep == 1648 or curStep == 2928 or curStep == 3440 then 
		tweenShaderProperty('grey', 'strength', 0, crochet*0.001*12, 'cubeIn')
	end
	if curStep == 1952 or curStep == 2080 then 
		tweenShaderProperty('grey', 'strength', 1, crochet*0.001*16, 'cubeIn')
	elseif curStep == 1984 or curStep == 2112 then 
		tweenShaderProperty('grey', 'strength', 0, crochet*0.001*32, 'cubeIn')
	end
	
	local section = math.floor(curStep/16)
	if (section >= 24 and section < 104) or (section >= 136 and section < 200) or (section >= 216 and section < 232) then 
		if curStep % 64 == 0 then 
			triggerEvent('Add Camera Zoom', 0.1, -0.1)
			doModchartShit()
		end
		if curStep % 64 == 16 or curStep % 64 == 40 or curStep % 64 == 48 then 
			triggerEvent('Add Camera Zoom', 0.07, 0.07)
			doModchartShit()
		end
		if section % 16 == 15 then 
			if curStep % 16 == 8 or curStep % 16 == 12 then 
				triggerEvent('Add Camera Zoom', 0.07, 0.07)
				doModchartShit()
			end
		end
	end
end
local flipShit = 1
function doModchartShit()
	flipShit = flipShit * -1
	if modchartState == 2 then 
		drunk = 0.4
		noteScale = noteScale + 0.25
	elseif modchartState == 0 then 
		drunk = 0.05
		noteScale = noteScale + 0.25
	elseif modchartState == 3 then 
		drunk = 0.05
		noteScale = noteScale + 0.15
		for i = 0,8 do 
			local zShit = 50
			if getCorrectStrum(i) % 2 == 0 then 
				zShit = -50
			end
			noteZPos[i+1] = zShit*flipShit
		end
	elseif modchartState == 1 then 
		drunk = 0.05
		noteScale = noteScale + 0.25
		for i = 0,8 do 
			local zShit = 45
			if getCorrectStrum(i) % 2 == 0 then 
				zShit = -45
			end
			noteAngle[i+1] = zShit*flipShit
		end
	end

	if curStep >= 2176 then 
		setShaderProperty('barrel', 'barrel', 0.5)
		tweenShaderProperty('barrel', 'barrel', 0.15, crochet*0.001*4, 'cubeOut')
	end
end
function getCorrectStrum(i)
	if i > 6 then 
		i = i - 1
	end
	return i
end

local trailCount = 0
function playerOneSing(data, time, type)
	if curStep >= 2176 then 
		local trail = 'trail'..trailCount
		destroySprite(trail)
        makeSpriteCopy(trail, 'boyfriend')
        tweenFadeOut(trail, 0, crochet*0.001*12)
		tweenActorProperty(trail, 'x', getActorX(trail)+math.random(-80,80), crochet*0.001*12, 'cubeOut')
		tweenActorProperty(trail, 'y', getActorY(trail)+math.random(-80,80), crochet*0.001*12, 'cubeOut')
        setActorLayer(trail, getActorLayer('boyfriend')-1)
        trailCount = trailCount + 1
        if trailCount >= 50 then
            trailCount = 0
        end
	end
end

function playerTwoSing(data, time, type)

end
function onEvent(name, time, val1, val2)
	if name == 'parryNoteStart' then 
		for i = 4,8 do 
			if i < 6 then 
				targetnoteXPos[i+1] = targetnoteXPos[i+1]-(112*0.5)
			elseif i > 6 then 
				targetnoteXPos[i+1] = targetnoteXPos[i+1]+(112*0.5)
			end
		end
	elseif name == 'parryNoteEnd' then 
		for i = 4,8 do 
			if i > 6 then 
				targetnoteXPos[i+1] = targetnoteXPos[i+1]-(112*0.5)
			elseif i < 6 then 
				targetnoteXPos[i+1] = targetnoteXPos[i+1]+(112*0.5)
			end
		end
	end
end