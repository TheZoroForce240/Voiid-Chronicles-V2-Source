
function start(song)
	if opponentPlay then 
		for i=4,7 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 1000,getActorAngle(i) + 1000, 0.1, 'setDefault')
			print(song)
		end
	else 
		for i=0,3 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 1000,getActorAngle(i) + 1000, 0.1, 'setDefault')
			print(song)
		end
	end

end
function songStart()
	
	--resumeLuaVideo()
	setLuaVideoTime(0)
	setLuaVideoHide(false)
	setProperty('', 'canPause', false)
	setProperty('', 'inCutscene', true)
end
function create()
	triggerEvent('vignette', 25, 0.5)
	setProperty('camGame', 'alpha', 0)
	setProperty('camHUD', 'alpha', 0)
	setProperty('', 'playCountdown', false)
	showOnlyStrums = true
	startLuaVideo("rejectedcutscene_noaudio", "mp4")
	setLuaVideoHide(true)
	--pauseLuaVideo()
end
function createShaders()
    initShader('greyscale', 'GreyscaleEffect')
    setCameraShader('game', 'greyscale')
    setCameraShader('hud', 'greyscale')
    setShaderProperty('greyscale', 'strength', 0)

    initShader('barrel', 'BarrelBlurEffect')
	setCameraShader('game', 'barrel')
	if modcharts then 
		setCameraShader('hud', 'barrel')
	end
	setShaderProperty('barrel', 'zoom', 1.0)
	setShaderProperty('barrel', 'barrel', 0.0)
    --setShaderProperty('barrel', 'angle', 720.0)
	makeSprite('barrelOffset', '', 0, 0) --so i can tween while still having the perlin stuff
	setActorAlpha(0, 'barrelOffset')

	makeSprite('barrelShit', '', 0, 0)
	setActorAlpha(0, 'barrelShit')

    initShader('blur', 'BlurEffect')
    setCameraShader('game', 'blur')
	if modcharts then 
		setCameraShader('hud', 'blur')
	end
   
    setShaderProperty('blur', 'strength', 0)
end
local perlinX = 0
local perlinY = 0
local perlinZ = 0

local perlinSpeed = 0.2

local perlinXRange = 0.12
local perlinYRange = 0.12
local perlinZRange = 10
local blur = 0


local count = 0
local countTime = 0
function updateShit(elapsed)

    perlinX = perlinX + elapsed*math.random()*perlinSpeed
	perlinY = perlinY + elapsed*math.random()*perlinSpeed
	perlinZ = perlinZ + elapsed*math.random()*perlinSpeed
    --local noiseX = perlin.noise(perlinX, 0, 0)
	--trace(perlin(perlinX, 0, 0)*0.1)
    setShaderProperty('barrel', 'x', ((-0.5 + perlin(perlinX, 0, 0))*perlinXRange)+getActorX('barrelOffset'))
	setShaderProperty('barrel', 'y', ((-0.5 + perlin(0, perlinY, 0))*perlinYRange)+getActorY('barrelOffset'))
	setShaderProperty('barrel', 'angle', ((-0.5 + perlin(0, 0, perlinZ))*perlinZRange)+getActorAngle('barrelOffset'))

    blur = lerp(blur, 0, elapsed*6)
    setShaderProperty('blur', 'strength', blur*0.65)

	setActorX(lerp(getActorX('barrelShit'), 0, elapsed*6),'barrelShit')
    setShaderProperty('barrel', 'barrel', getActorX('barrelShit'))
end




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

local downscrollDiff = 1

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
		if opponentPlay then 
			if i < keyCount then 

			else 
				noteXPos[i+1] = getActorX(i)+1500
				targetnoteXPos[i+1] = getActorX(i)+1500
			end
		else 
			if i < keyCount then 
				noteXPos[i+1] = getActorX(i)-1500
				targetnoteXPos[i+1] = getActorX(i)-1500
			end
		end

		targetnoteYPos[i+1] = _G['defaultStrum'..i..'Y']
		noteYPos[i+1] = _G['defaultStrum'..i..'Y']
	end

	if not downscrollBool then 
		downscrollDiff = -1
	end

    createShaders()
	
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

local suddenHeight = 400
local suddenAppear = 1000
local suddenBeatShit = 0

local lerpedSH = 400
local lerpedSA = 1000

local hiddenHeight = 0
local hiddenAppear = 800
local hiddenBeatShit = 0

local lerpedHH = 0
local lerpedHA = 1000

local xMoveHeight = 0
local xMoveAppear = 3000
local xMoveBeatShit = 0
local xMoveAmount = -500

local lerpedXH = 300
local lerpedXA = 800

local moveShit = 0

function updatePost(elapsed)



    updateShit(elapsed)

	if not modcharts then 
		return
	end

    lerpedSH = lerp(lerpedSH, suddenHeight, elapsed*1)
    lerpedSA = lerp(lerpedSA, suddenAppear, elapsed*1)

	lerpedHH = lerp(lerpedHH, hiddenHeight, elapsed*1)
    lerpedHA = lerp(lerpedHA, hiddenAppear, elapsed*1)

	lerpedXH = lerp(lerpedXH, xMoveHeight, elapsed*1)
    lerpedXA = lerp(lerpedXA, xMoveAppear, elapsed*1)




	if lerpScale then 
		noteScale = lerp(noteScale, 1, elapsed*lerpSpeedScale)
	end
	noteRotX = lerp(noteRotX, targetNoteRotX, elapsed*lerpSpeednoteRotX)

	drunk = lerp(drunk, drunkLerp, elapsed*5)

	local currentBeat = (songPos / 1000)*(bpm/60)

	local section = math.floor(curStep/16)
	if section ~= 80 and not (section >= 97 and section < 123) and section < 139 then 
		triggerEvent('vignette', 25, 0.8+ math.sin(currentBeat)*0.4)
	end
	

	for i = 0,(keyCount*2)-1 do 
		if moveShit ~= 0 then 
			if i >= keyCount then 
				--targetnoteXPos[i+1] = (_G['defaultStrum'..i..'X'] - 320) + math.cos(currentBeat*2)*moveShit
				--targetnoteYPos[i+1] = (_G['defaultStrum'..i..'Y']) + math.sin(currentBeat*0.5)*(moveShit/20)
			end
		end

		noteXPos[i+1] = lerp(noteXPos[i+1], targetnoteXPos[i+1], elapsed*lerpSpeedX)
		noteYPos[i+1] = lerp(noteYPos[i+1], targetnoteYPos[i+1], elapsed*lerpSpeedY)
		noteZPos[i+1] = lerp(noteZPos[i+1], targetnoteZPos[i+1], elapsed*lerpSpeedZ)



		local thisnotePosX = noteXPos[i+1] + getXOffset(i, 0, 0)
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
			--[[if getRenderedNoteArrowType(i) == 'REJECTED_NOTES' then 
				offsetX = offsetX - 10
				if isSustain(i) then 
					offsetX = offsetX + 50
				end
			end]]--
			local strumTime = getRenderedNoteStrumtime(i)
			if downscrollBool then 
				if isRenderedNoteSustainEnd(i) then 
					strumTime = getRenderedNotePrevNoteStrumtime(i)
				end
			end
			
			local curPos = ((songPos-strumTime)*songSpeed)
			offsetX = offsetX + getXOffset(data, curPos, strumTime)
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

            local alphaMult = 1

            if suddenHeight ~= 0 then
                if (math.floor(((strumTime%(crochet*16))%(crochet*16)) % suddenBeatShit) == 0 and suddenBeatShit ~= 0) or suddenBeatShit == 0 then 
                    if (curPos < -lerpedSH) then
                        alphaMult = (lerpedSA-math.abs(curPos))/(lerpedSA-lerpedSH)
                    end
                end
            end

			if hiddenHeight ~= 0 then
                if (math.floor(((strumTime%(crochet*16))%(crochet*16)) % hiddenBeatShit) == 0 and hiddenBeatShit ~= 0) or hiddenBeatShit == 0 then 
                    if (curPos > -lerpedHA) then
                        alphaMult = (lerpedHH-math.abs(curPos))/(lerpedHH-lerpedHA)
                    end
                end
            end

            

			if not isSustain(i) then 
				--setRenderedNoteScale(getRenderedNoteWidth(i)*,getRenderedNoteHeight(i)*noteScale * (1/-totalNotePos[3]), i)
				setRenderedNoteScaleX(defaultNoteScale*noteScale * (1/-totalNotePos[3]), i)
				setRenderedNoteScaleY(defaultNoteScale*noteScale * (1/-totalNotePos[3]), i)
				setRenderedNoteAlpha(1*alphaMult,i)
				setRenderedNoteAngle(noteAngle[data+1],i)
			else
				--offsetX = 37 * (1/-totalNotePos[3]) * (defaultWidth/112)
				setRenderedNoteAlpha(0.6*alphaMult,i)
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

function getXOffset(data, curPos, strumTime)

	local xOffset = 0
	if drunk ~= 0 then 
		xOffset = xOffset + drunk * (math.cos( ((songPos*0.001) + ((data%keyCount)*0.2) + (curPos*0.45)*(10/720)) * (drunkSpeed*0.2)) * 112*0.5);
	end

	if xMoveHeight ~= 0 then
		if (math.floor(((strumTime%(crochet*16))%(crochet*16)) % xMoveBeatShit) == 0 and xMoveBeatShit ~= 0) or xMoveBeatShit == 0 then 
			if (curPos < -lerpedXH) then
				local val = easeOutCubic((lerpedXH-math.abs(curPos))/(lerpedXH-lerpedXA))
				if data % 2 == 0 then 
					xOffset = xOffset + val*112
				else 
					xOffset = xOffset + val*-112
				end
				
			end
		end
	end

	return xOffset
end

function easeOutCubic(x)
	return 1 - math.pow(1 - x, 3)
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







local trailCount = 0
local lastNoteTime = 0
function playerTwoSing(data, time, type)
    if getHealth() - 0.008 > 0.25 then
        setHealth(getHealth() - 0.02)
    else
        setHealth(0.1)
    end
	if modcharts then  
		triggerEvent('Screen Shake','0.1,0.005','0.1,0.005')
	else 
		triggerEvent('Screen Shake','0.1,0.005','0, 0')
	end
   
	setActorAngle(math.random()*2, 'barrelOffset')
    blur = blur + 0.6

	if time-lastNoteTime < crochet then 
        destroySprite('trail'..trailCount)
        makeSpriteCopy('trail'..trailCount, 'dad')
        tweenFadeOut('trail'..trailCount, 0, crochet*0.001*8)
        setActorLayer('trail'..trailCount, getActorLayer('dad')-1)
        trailCount = trailCount + 1
        if trailCount >= 50 then 
            trailCount = 0
        end
	end
    lastNoteTime = time
end

function stepHit()

	if opponentPlay then 

		if curStep == 112 then 
			suddenHeight = 0
			showOnlyStrums = false
			setProperty('camGame', 'alpha', 1)
			setProperty('camHUD', 'alpha', 1)
			setProperty('', 'canPause', true)
			setProperty('', 'inCutscene', false)
			--stopLuaVideo()
		end
		if curStep == 113 then 
			setLuaVideoHide(true)
		end
	else 

		if curStep == 128 then 
			suddenHeight = 0
			showOnlyStrums = false
			setProperty('camGame', 'alpha', 1)
			setProperty('camHUD', 'alpha', 1)
			setProperty('', 'canPause', true)
			setProperty('', 'inCutscene', false)
			--stopLuaVideo()
		end
		if curStep == 129 then 
			setLuaVideoHide(true)
		end
	end

    if curStep == 256 then 
        suddenHeight = 1100
        suddenAppear = 1400
        suddenBeatShit = 4
    end
    if curStep == 576 then 
        suddenHeight = 1100
        suddenAppear = 1400
        suddenBeatShit = 2
    end
    if curStep == 768 or curStep == 768+128 then 
        suddenHeight = 900
        suddenAppear = 1200
        suddenBeatShit = 4
		perlinZRange = 20
		perlinSpeed = 0.6
    elseif curStep == 800 or curStep == 800+128 then 
        suddenHeight = 900
        suddenAppear = 1200
        suddenBeatShit = 2
    elseif curStep == 832 or curStep == 832+128 then 
        suddenHeight = 900
        suddenAppear = 1200
        suddenBeatShit = 0
    elseif curStep == 864 or curStep == 864+128 then 
        suddenHeight = 650
        suddenAppear = 1000
        suddenBeatShit = 0
    end
    if curStep == 1024 then 
        suddenHeight = 0
		perlinSpeed = 0.2
    end

	if curStep == 1088 then 
		xMoveHeight = 900
		xMoveBeatShit = 4
	elseif curStep == 1088+64 then 
		xMoveBeatShit = 2
	end

	if curStep == 1296 or curStep == 1296+128 then 
        xMoveHeight = 900
        xMoveAppear = 2500
        xMoveBeatShit = 4
		perlinZRange = 25
		perlinSpeed = 0.7
    elseif curStep == 1296+32 or curStep == 1296+128+32 then 
        xMoveHeight = 900
        xMoveAppear = 2500
        xMoveBeatShit = 2
    elseif curStep == 1296+32+32 or curStep == 1296+128+32+32 then 
        xMoveHeight = 900
        xMoveAppear = 2500
        xMoveBeatShit = 0
    elseif curStep == 1296+32+32+32 or curStep == 1296+128+32+32+32 then 
        xMoveHeight = 700
        xMoveAppear = 2000
        xMoveBeatShit = 0
    end
	if curStep == 1552 then 
        xMoveHeight = 0
        xMoveAppear = 2000
        xMoveBeatShit = 4
		perlinSpeed = 0.2
	end


	--intro beats
	if curStep == 128 or curStep == 146 or curStep == 148 or curStep == 160 or curStep == 178 or curStep == 180 or curStep == 188 or curStep == 192 or curStep == 198 or curStep == 204 or curStep == 208 or curStep == 214 or curStep == 220 or curStep == 222 or curStep == 224 or curStep == 228 or curStep == 232 or curStep == 236 or curStep == 237 or curStep == 238 or curStep == 240 or curStep == 242 or curStep == 244 or curStep == 246 or curStep == 248 then 
		tweenActorProperty('camGame', 'zoom', getCamZoom()+0.1, crochet*0.001*2, 'cubeOut')
		if modcharts then 
			tweenActorProperty('camHUD', 'zoom', getHudZoom()+0.015, crochet*0.001*2, 'cubeOut')
		end
		
	end

	if modcharts then 
		if curStep == 248 then 
			tweenActorProperty('camHUD', 'alpha', 0.5, crochet*0.001*2, 'cubeOut')
		elseif curStep == 248+2 then 
			tweenActorProperty('camHUD', 'alpha', 0.8, crochet*0.001*2, 'cubeOut')
		elseif curStep == 248+4 then 
			tweenActorProperty('camHUD', 'alpha', 0.4, crochet*0.001*2, 'cubeOut')
		elseif curStep == 248+6 then 
			tweenActorProperty('camHUD', 'alpha', 0.1, crochet*0.001*2, 'cubeOut')
		elseif curStep == 248+8 then 
			tweenActorProperty('camHUD', 'alpha', 1, crochet*0.001*2, 'cubeIn')
		end
	end

	local section = math.floor(curStep/16)

	if (section >= 16 and section < 47) or (section >= 64 and section < 71) then 
		if curStep % 16 == 0 or curStep % 16 == 6 or curStep % 16 == 10 then 
			tweenActorProperty('camGame', 'zoom', getCamZoom()+0.06, crochet*0.001*2, 'cubeOut')
			if modcharts then 
			tweenActorProperty('camHUD', 'zoom', getHudZoom()+0.01, crochet*0.001*2, 'cubeOut')
			end
		end
		if curStep % 16 == 4 or curStep % 16 == 12 or curStep % 32 == 18 or curStep % 32 == 30 then 
			triggerEvent("add camera zoom", 0.05, 0.05)
		end
	end
	if section == 47 or section == 71 then --build ups
		if curStep % 4 == 0 then 
			tweenActorProperty('camGame', 'zoom', getCamZoom()+0.06, crochet*0.001*2, 'cubeOut')
			if modcharts then 
			tweenActorProperty('camHUD', 'zoom', getHudZoom()+0.01, crochet*0.001*2, 'cubeOut')
			end
		end
		if curStep % 16 == 10 or curStep % 16 == 11 or curStep % 16 == 14 then 
			triggerEvent("add camera zoom", 0.05, 0.05)
		end
	end


	if (section >= 48 and section < 64) or (section >= 81 and section < 97) or (section >= 123 and section < 139) then --"spam" sections 
		if curStep % 16 == 0 or curStep % 16 == 4 or curStep % 16 == 8 or curStep % 16 == 11 or curStep % 16 == 14 then 
			tweenActorProperty('camGame', 'zoom', getCamZoom()+0.1, crochet*0.001*2, 'cubeOut')
			if modcharts then 
			tweenActorProperty('camHUD', 'zoom', getHudZoom()+0.015, crochet*0.001*2, 'cubeOut')
			end
			tweenActorProperty('barrelShit', 'x', getActorX('barrelShit')+0.08, crochet*0.001*2, 'cubeOut')			
		end
	end

	if (section >= 72 and section < 78) then 
		if curStep % 16 == 0 or curStep % 16 == 6 or curStep % 32 == 10 or curStep % 32 == 30 or curStep % 32 == 28 then 
			tweenActorProperty('camGame', 'zoom', getCamZoom()+0.1, crochet*0.001*2, 'cubeOut')
			if modcharts then 
			tweenActorProperty('camHUD', 'zoom', getHudZoom()+0.01, crochet*0.001*2, 'cubeOut')
			end
		end
	end
	if section == 78 then 
		if curStep % 4 == 0 or curStep % 16 == 14 then 
			tweenActorProperty('camGame', 'zoom', getCamZoom()+0.07, crochet*0.001*2, 'cubeOut')
			if modcharts then 
				tweenActorProperty('camHUD', 'zoom', getHudZoom()+0.01, crochet*0.001*2, 'cubeOut')
				end
		end
	end
	if section == 79 then 
		if curStep % 2 == 0 or curStep % 16 == 7 or curStep % 16 == 15 or curStep % 16 == 13 then 
			tweenActorProperty('camGame', 'zoom', getCamZoom()+0.04, crochet*0.001*2, 'cubeOut')
			if modcharts then 
				tweenActorProperty('camHUD', 'zoom', getHudZoom()+0.006, crochet*0.001*2, 'cubeOut')
				end
		end
	end


	if curStep == 1680 then 
		perlinSpeed = 1
		hiddenHeight = 100
		hiddenAppear = 700
		moveShit = 400
		perlinZRange = 30
	elseif curStep == 1712 then 
		hiddenBeatShit = 0
	elseif curStep == 1744 then 
		moveShit = 0
		perlinZRange = 10
		perlinSpeed = 0.4
		hiddenBeatShit = 4
	elseif curStep == 1904 then 
		hiddenBeatShit = 2
	elseif curStep == 1936 then 
		hiddenBeatShit = 0
		hiddenHeight = 0
	end

	if curStep == 1584 then 
		hiddenHeight = 150
		hiddenAppear = 500
		hiddenBeatShit = 2
	end



	if curStep == 1968 or curStep == 1968+128 then 
		suddenBeatShit = 4
		xMoveBeatShit = 4
		hiddenBeatShit = 4
		suddenHeight = 1000
        suddenAppear = 1300
        suddenBeatShit = 4
		perlinZRange = 25
		perlinSpeed = 0.7
    elseif curStep == 1968+32 or curStep == 1968+128+32 then 
        xMoveHeight = 900
        xMoveAppear = 2500
        xMoveBeatShit = 4
    elseif curStep == 1968+32+32 or curStep == 1968+128+32+32 then 
		hiddenHeight = 100
		hiddenAppear = 400
    elseif curStep == 1968+32+32+32 or curStep == 1968+128+32+32+32 then 
        suddenBeatShit = 0
		xMoveBeatShit = 4
		hiddenBeatShit = 0
    end

	if curStep == 2208+4 then 
		tweenShaderProperty('barrel', 'zoom', 1.5, crochet*0.001*4, 'cubeOut')
	end
	if curStep == 2208+12 then 
		tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*4, 'cubeOut')
	end
	if curStep == 2224 then 
		suddenHeight = 0
		hiddenHeight = 0
		xMoveHeight = 0
		perlinZRange = 10
		perlinSpeed = 0.2
	elseif curStep == 2352 then 
		tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*128, 'cubeOut')
	end

	if curStep == 2464 then 
		triggerEvent('vignette', 1, 0)
		makeSprite('black', '', 0, 0, 1)
		setObjectCamera('black', 'hud')
		makeGraphic('black', 4000, 2000, '0xFF000000')
		actorScreenCenter('black')
		setActorAlpha(0, 'black')
		tweenActorProperty('black', 'alpha', 1, crochet*0.001*16, 'quadIn')
	end
end