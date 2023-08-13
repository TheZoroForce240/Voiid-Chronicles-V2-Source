local noteXPos = {}
local targetnoteXPos = {}
local noteYPos = {}
local targetnoteYPos = {}
local noteAngle = {}
local targetnoteAngle = {}
local startCamZoom = 1
function createPost()
	if modcharts then 
		for i = 0, 7 do 
			setActorY(2000, i)
			if downscrollBool then 
				setActorY(-2000, i)
			end
			setActorAngle(1000, i)
	
			table.insert(noteXPos, 0) --setup default pos and whatever
			table.insert(noteYPos, 0)
			table.insert(noteAngle, 0)
			table.insert(targetnoteXPos, 0)
			table.insert(targetnoteYPos, 0)
			table.insert(targetnoteAngle, 720 + (45*i)) --start angle at weird number for start
			noteXPos[i+1] = getActorX(i)
			targetnoteXPos[i+1] = getActorX(i)
			targetnoteYPos[i+1] = _G['defaultStrum'..i..'Y']
			noteYPos[i+1] = _G['defaultStrum'..i..'Y']
		end
		setHudZoom(1.65)
	end
	


	makeStageSprite('Ring2', 'Ring2',-195,-238, 2)
	setActorLayer('Ring2', getActorLayer('ring'))
	makeStageSprite('Ring3', 'Ring3',-195,-238, 2)
	setActorLayer('Ring3', getActorLayer('ring'))

	--setActorVisible(false, 'undefinedSprite6')
	setActorVisible(false, 'Ring2')
	setActorVisible(false, 'Ring3')

	initShader('mirror', 'MirrorRepeatEffect')
	setCameraShader('game', 'mirror')
	if modcharts then 
		--setCameraShader('hud', 'mirror')
	end
	
	setShaderProperty('mirror', 'zoom', 1.0)

	initShader('greyscale', 'GreyscaleEffect')
    setCameraShader('game', 'greyscale')
    setCameraShader('hud', 'greyscale')
    setShaderProperty('greyscale', 'strength', 1)

    initShader('blur', 'BlurEffect')
    setCameraShader('game', 'blur')
    setCameraShader('hud', 'blur')
    setShaderProperty('blur', 'strength', 0)

	startCamZoom = getProperty('', 'defaultCamZoom')

	if opponentPlay then 
		setProperty('', 'camZooming', true)
	end

end
local noteScale = 0.7
function lerp(a, b, ratio)
	return a + ratio * (b - a); --the funny lerp
end

local lerpX = true
local lerpY = false
local lerpAngle = true
local lerpScale = true

local perlinX = 0
local perlinY = 0
local perlinZ = 0

local perlinSpeed = 0.5

local perlinXRange = 0.01
local perlinYRange = 0.01
local perlinZRange = 0.1


function update(elapsed)
	if curBeat >= 1004 and songPos > 0 then 
		setProperty('', 'altAnim', '-alt') --force alt anim until the end
	end




	perlinX = perlinX + elapsed*math.random()*perlinSpeed
	perlinY = perlinY + elapsed*math.random()*perlinSpeed
	perlinZ = perlinZ + elapsed*math.random()*perlinSpeed
    --local noiseX = perlin.noise(perlinX, 0, 0)
	--trace(perlin(perlinX, 0, 0)*0.1)
    setShaderProperty('mirror', 'x', ((-0.5 + perlin(perlinX, 0, 0))*perlinXRange))
	setShaderProperty('mirror', 'y', ((-0.5 + perlin(0, perlinY, 0))*perlinYRange))
	setShaderProperty('mirror', 'angle', ((-0.5 + perlin(0, 0, perlinZ))*perlinZRange))

	if not modcharts then 
		return
	end

	if lerpScale then 
		noteScale = lerp(noteScale, 1, elapsed*5)
	end
	
	for i = 0,7 do 
		if lerpX then
			noteXPos[i+1] = lerp(noteXPos[i+1], targetnoteXPos[i+1], elapsed*4)
			setActorX(noteXPos[i+1], i)
		end
		if lerpY then
			noteYPos[i+1] = lerp(noteYPos[i+1], targetnoteYPos[i+1], elapsed*4)
			setActorY(noteYPos[i+1], i)
		end
		if lerpAngle then
			noteAngle[i+1] = lerp(noteAngle[i+1], targetnoteAngle[i+1], elapsed*3)
			setActorModAngle(noteAngle[i+1], i)
		end

		if lerpScale then 
			setActorScaleXY(noteScale, noteScale, i)
			if getPlayingActorAnimation(i) == 'confirm' then 
				setActorScaleXY(noteScale*1.3, noteScale*1.3, i) --confirm is weird ig
			end
		end
	end

	--leather engine is shit
	--for i = 0, getRenderedNotes()-1 do 
		--local noteX = getRenderedNoteCalcX(i)
		--local susOffset = 0
		--if not isSustain(i) then 
			--setRenderedNoteScale(112*noteScale, 112*noteScale, i)
		--else
		--	susOffset = 37*noteScale
		--end

		

		--setRenderedNotePos(noteX+susOffset, getRenderedNoteY(), i)
		--setRenderedNoteScale(112*noteScale, 112*noteScale, i)
		--if doGhostNotes then 
			--setRenderedNoteAlpha(0.5, i)
		--end
	--end

end

local beatSteps = {0,8,16,40,48}
local lastsecBeatSteps = {4,24,28,48,56,60}

function stepHit(curStep)
	if curStep == 1536 then 
		triggerEvent('camera flash', 0.01, crochet/33.25)
		setProperty('', 'camZooming', false)
		setHudZoom(2)
	end

	if curStep == 208 then  
		--move arrows up
		if modcharts then 
			for i = 0, 7 do 
				tweenPosYAngleOut(i, _G['defaultStrum'..i..'Y'], 0, (crochet/1000)*48)
				targetnoteAngle[i+1] = 0
			end
		end
	elseif curStep == 1256-8 then  
		--maybe fade out slightly??
		if modcharts then 
			for i = 0, 7 do 
				tweenFadeOut(i, 0.5, (crochet/1000)*32)
			end
		end
		tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*4, 'cubeOut')
	elseif curStep == 1256-8+16 then  
		tweenShaderProperty('greyscale', 'strength', 0.75, crochet*0.001*4, 'cubeIn')
	elseif curStep == 1280 then 
		--fade back in
		if modcharts then 
			for i = 0, 7 do 
				tweenFadeIn(i, 1, (crochet/1000)*4)
			end
		end
		tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*4*24, 'cubeIn')
	elseif curStep == 3808 then  
		--maybe fade out slightly??
		if modcharts then 
			for i = 0, 7 do 
				tweenFadeOut(i, 0.5, (crochet/1000)*32)
			end
		end
		tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*4, 'cubeOut')
	elseif curStep == 3808+16 then  
		tweenShaderProperty('greyscale', 'strength', 0.75, crochet*0.001*4, 'cubeIn')
	elseif curStep == 3840 then 
		--fade back in
		if modcharts then 
			for i = 0, 7 do 
				tweenFadeIn(i, 1, (crochet/1000)*4)
			end
		end
		tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*4*24, 'cubeIn')
	elseif curStep == 1760 or curStep == 4224 then 
		--arrows come back up
		--for i = 0, 7 do 
		--	tweenPosYAngleOut(i, _G['defaultStrum'..i..'Y'], 0, (crochet/1000)*8)
		--	tweenAngle(i, 0, (crochet/1000)*8)
		--end
		resetNotePos()

	elseif curStep == 1456-16 or curStep == 4000 then 
		if not middlescroll then 
			goMiddlescroll()
		end

	elseif curStep == 4352 then
		triggerEvent('camera flash', 0.01, crochet/33.25)

	end

	if curStep <= 1280 or (curStep >= 1792 and curStep <= 3840) or (curStep >= 4096 and curStep <= 4352) then 
		if curStep % 16 == 0 then --regular beat every section
			if curStep < 256 then
				noteScale = noteScale+0.2
				triggerEvent('add camera zoom', 0.01, 0)
			end
			--triggerEvent('add camera zoom', 0.08, -0.08)
			--tweenHudZoom(0.95, crochet/500)
		end
		if curStep <= 2816 and curStep >= 1792 or curStep >= 4096 then 
			if curStep % 256 < 192 then 	
				for i = 0, #beatSteps-1 do 
					if curStep % 64 == beatSteps[i+1] then 
						noteScale = noteScale+0.2
						triggerEvent('add camera zoom', 0.05, 0)
						noteBeatMoveThingAlt()
					end
				end
			else 
				for i = 0, #lastsecBeatSteps-1 do 
					if curStep % 64 == lastsecBeatSteps[i+1] then 
						noteScale = noteScale+0.2
						triggerEvent('add camera zoom', 0.05, 0)
						noteBeatMoveThingAlt()
					end
				end
			end
		elseif curStep >= 256 then 
			lerpY = true
			if curStep % 256 < 192 then 	
				for i = 0, #beatSteps-1 do 
					if curStep % 64 == beatSteps[i+1] then 
						noteScale = noteScale+0.2
						triggerEvent('add camera zoom', 0.05, 0)
						noteBeatMoveThing()
					end
				end
			else 
				for i = 0, #lastsecBeatSteps-1 do 
					if curStep % 64 == lastsecBeatSteps[i+1] then 
						noteScale = noteScale+0.2
						triggerEvent('add camera zoom', 0.05, 0)
						noteBeatMoveThing()
					end
				end
			end
		end

	elseif curStep <= 1344 then --beat build up part
		if curStep % 32 == 0 then 
			noteScale = noteScale+0.3
			triggerEvent('add camera zoom', 0.05, -0.05)
			noteBeatAngleThing()
		end
	elseif curStep <= 1408 then 
		if curStep % 16 == 0 then 
			noteScale = noteScale+0.3
			triggerEvent('add camera zoom', 0.05, -0.05)
			noteBeatAngleThing()
		end
	elseif curStep <= 1456 then 
		if curStep % 8 == 0 then 
			noteScale = noteScale+0.2
			triggerEvent('add camera zoom', 0.05, -0.05)
			noteBeatAngleThing()
		end
	elseif curStep >= 1472 and curStep <= 1504 then 
		if curStep % 4 == 0 then 
			noteScale = noteScale+0.1
			triggerEvent('add camera zoom', 0.035, -0.035)
			noteBeatAngleThing()
		end
	elseif curStep <= 1536 and curStep >= 1504 then 
		if curStep % 2 == 0 then 
			noteScale = noteScale+0.1
			triggerEvent('add camera zoom', 0.035, -0.035)
			noteBeatAngleThing()
		end


	elseif curStep <= 3904 and curStep >= 3840 then --second beat build up part
		if curStep % 32 == 0 then 
			noteScale = noteScale+0.3
			triggerEvent('add camera zoom', 0.05, -0.05)
			noteBeatAngleThing()
		end
	elseif curStep <= 3968 and curStep >= 3840 then 
		if curStep % 16 == 0 then 
			noteScale = noteScale+0.3
			triggerEvent('add camera zoom', 0.05, -0.05)
			noteBeatAngleThing()
		end
	elseif curStep <= 4016 and curStep >= 3840 then 
		if curStep % 8 == 0 then 
			noteScale = noteScale+0.2
			triggerEvent('add camera zoom', 0.05, -0.05)
			noteBeatAngleThing()
		end
	elseif curStep >= 4032 and curStep <= 4064 then 
		if curStep % 4 == 0 then 
			noteScale = noteScale+0.1
			triggerEvent('add camera zoom', 0.035, -0.035)
			noteBeatAngleThing()
		end
	elseif curStep <= 4096 and curStep >= 3840 and curStep >= 4064 then 
		if curStep % 2 == 0 then 
			noteScale = noteScale+0.1
			triggerEvent('add camera zoom', 0.035, -0.035)
			noteBeatAngleThing()
		end
	
	end


	if curStep == 1280 then 
		perlinXRange = 0.03
		perlinYRange = 0.03
		perlinZRange = 1
		setProperty('', 'cameraSpeed', 2)
	elseif curStep == 1280+32 then 
		perlinXRange = 0.05
		perlinYRange = 0.05
		perlinZRange = 2
	elseif curStep == 1280+64 then 
		perlinXRange = 0.07
		perlinYRange = 0.07
		perlinZRange = 3
		perlinSpeed = 0.6
	elseif curStep == 1280+64+16 then 
		perlinXRange = 0.07
		perlinYRange = 0.07
		perlinZRange = 4
		perlinSpeed = 0.7
	elseif curStep == 1280+64+32 then 
		perlinXRange = 0.08
		perlinYRange = 0.08
		perlinZRange = 5
		perlinSpeed = 0.8
	elseif curStep == 1280+64+48 then 
		perlinXRange = 0.09
		perlinYRange = 0.09
		perlinZRange = 6
		perlinSpeed = 0.9
	elseif curStep == 1280+128 then 
		perlinXRange = 0.09
		perlinYRange = 0.09
		perlinZRange = 7
		perlinSpeed = 1
	elseif curStep == 1280+192 then 
		perlinXRange = 0.1
		perlinYRange = 0.1
		perlinZRange = 20
		perlinSpeed = 4
		setProperty('', 'cameraSpeed', 3)
	elseif curStep == 1280+256 or curStep == 4356 then 
		perlinXRange = 0.01
		perlinYRange = 0.01
		perlinZRange = 0.1
		perlinSpeed = 0.5
		setProperty('', 'cameraSpeed', 1)
	end


	if curStep == 3840 then 
		perlinXRange = 0.03
		perlinYRange = 0.03
		perlinZRange = 1
		setProperty('', 'cameraSpeed', 2)
	elseif curStep == 3840+32 then 
		perlinXRange = 0.05
		perlinYRange = 0.05
		perlinZRange = 2
	elseif curStep == 3840+64 then 
		perlinXRange = 0.07
		perlinYRange = 0.07
		perlinZRange = 3
		perlinSpeed = 0.6
	elseif curStep == 3840+64+16 then 
		perlinXRange = 0.07
		perlinYRange = 0.07
		perlinZRange = 4
		perlinSpeed = 0.7
	elseif curStep == 3840+64+32 then 
		perlinXRange = 0.08
		perlinYRange = 0.08
		perlinZRange = 5
		perlinSpeed = 0.8
	elseif curStep == 3840+64+48 then 
		perlinXRange = 0.09
		perlinYRange = 0.09
		perlinZRange = 6
		perlinSpeed = 0.9
	elseif curStep == 3840+128 then 
		perlinXRange = 0.09
		perlinYRange = 0.09
		perlinZRange = 7
		perlinSpeed = 1
	elseif curStep == 3840+192 then 
		perlinXRange = 0.1
		perlinYRange = 0.1
		perlinZRange = 20
		perlinSpeed = 4
		setProperty('', 'cameraSpeed', 3)
	elseif curStep == 3840+256+4 then 
		perlinSpeed = 0.5
		setProperty('', 'cameraSpeed', 1)
	elseif curStep == 3840+256+8 then 
		perlinSpeed = 6
		setProperty('', 'cameraSpeed', 3)
	elseif curStep == 3840+256+4+16 then 
		perlinSpeed = 0.5
	elseif curStep == 3840+256+8+16 then 
		perlinSpeed = 4
		setProperty('', 'cameraSpeed', 3)

	elseif curStep == 4160+4 then 
		perlinSpeed = 0.5
		setProperty('', 'cameraSpeed', 1)
	elseif curStep == 4160+8 then 
		perlinSpeed = 6
		setProperty('', 'cameraSpeed', 3)
	elseif curStep == 4160+4+16 then 
		perlinSpeed = 0.5
		setProperty('', 'cameraSpeed', 1)
	elseif curStep == 4160+8+16 then 
		perlinSpeed = 8
		setProperty('', 'cameraSpeed', 3)
	end


	if curStep == 192 or curStep == 2752 then 
		tweenShaderProperty('greyscale', 'strength', 0, crochet*0.001*16*4, 'cubeIn')
	end
	if curStep == 1680 then 
		tweenShaderProperty('greyscale', 'strength', 1, crochet*0.001*8, 'cubeInOut')
	elseif curStep == 1728 then 
		tweenShaderProperty('greyscale', 'strength', 0.5, crochet*0.001*8, 'cubeInOut')
	end
end
local noteMovementThing = {-25, -15, 15, 25, -25, -15, 15, 25}
function noteBeatMoveThing()
	for i = 0,7 do 
		noteXPos[i+1] = targetnoteXPos[i+1] + noteMovementThing[i+1]
	end
end

local beatSwap = 1
local noteMovementThingAngle = {-25, -15, 15, 25, -25, -15, 15, 25}
function noteBeatAngleThing()
	for i = 0,7 do 
		noteAngle[i+1] = noteMovementThingAngle[i+1]*beatSwap
	end
	beatSwap = beatSwap * -1
end

function noteBeatMoveThingAlt()
	for i = 0,7 do 
		noteYPos[i+1] = targetnoteYPos[i+1] + noteMovementThing[i+1]*beatSwap
	end
	beatSwap = beatSwap * -1
end

function goMiddlescroll()
	if middlescroll then 
		return
	end
	for i = 0,7 do 
		targetnoteXPos[i+1] = _G['defaultStrum'..((i%4)+4)..'X']-320
	end
end
function resetNotePos()
	for i = 0,7 do 
		targetnoteXPos[i+1] = _G['defaultStrum'..i..'X']
	end
end

function playerTwoSing(data, time, type)
    if getHealth() - 0.008 > 0.09 then
        setHealth(getHealth() - 0.008)
    else
        setHealth(0.035)
    end
end

local lastAltAnim = ''
function beatHit()
	--[[
	if getProperty('', 'altAnim') ~= lastAltAnim then 

		setCharacterShouldDance('dad', false)
		if getProperty('', 'altAnim') then 
			playCharacterAnimation('dad', 'trans', true)
		else 
			playCharacterAnimation('dad', 'destrans', true)
		end


		lastAltAnim = getProperty('', 'altAnim')
	end
	]]--

	if curBeat == 360 or curBeat == 1000 then 
		setCharacterShouldDance('dad', false)
		playCharacterAnimation('dad', 'trans', true)
		setProperty('', 'defaultCamZoom', 1.1)
	elseif curBeat == 368 or curBeat == 1008 then 
		setCharacterShouldDance('dad', true)
		setProperty('', 'defaultCamZoom', startCamZoom)

	elseif curBeat == 364 or curBeat == 1004 then 
		--triggerEvent('camera flash', 0.01, crochet/100)
		flashCamera('game', '#B700ff', crochet/100)
		triggerEvent('screen shake', ((crochet/1000)*8)..',0.02', '0,0')
		if curBeat == 364 then 
			setActorVisible(true, 'Ring2')
			setActorVisible(false, 'undefinedSprite6') --the ring, leather engine weird ig
		elseif curBeat == 1004 then 
			--triggerEvent('change stage', 'VoiidBoxingRing3')
			setActorVisible(true, 'Ring3')
			setActorVisible(false, 'Ring2')
		end
	
	elseif curBeat == 400 then 
		playCharacterAnimation('dad', 'destrans', true)
	end
end