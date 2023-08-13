function create()
    --setProperty('', 'playCountdown', false)
end
local defaultX = {}
local defaultY = {}
function createPost()
    makeSprite('black', '', 0, 0, 1)
    setObjectCamera('black', 'hud')
    makeGraphic('black', 4000, 2000, '0xFF000000')
    actorScreenCenter('black')

	if modcharts then 
		setupCams(4)
		for i = 0, 7 do 
			setActorAlpha(0.55, i)
		end
	end


	initShader('mirror', 'MirrorRepeatEffect')
	setCameraShader('game', 'mirror')
	setShaderProperty('mirror', 'zoom', 1)

	--setSongPosition(80000)

	makeSprite('camGameZoomShit', '', 0, 0, 1)
	makeSprite('camOffset', '', 0, 0, 1)
	--tweenActorProperty('camGameZoomShit', 'x', 1, 5, 'linear')
	for i = 0,7 do 
		defaultX[i+1] = getActorX(i)
		defaultY[i+1] = getActorY(i)
	end
	
end
local camCount = 4
function setupCams(count)
	camCount = count
	count = count - 1 --so it matches
	local camStr = ''
	for i = 0, count do 
		makeCamera('noteCam'..i)
		makeSprite('noteCamZoom'..i, '', 1, 0, 1)
		camStr = camStr..'noteCam'..i
		if i < count then 
			camStr = camStr..',' --so no comma on the end
		end
	end
	trace(camStr)
	setNoteCameras(camStr)
end
function songStart()
	tweenActorProperty('black', 'alpha', 0, crochet*0.001*48, 'quadOut')
	stepHit()
end

local beatStuff = {0, 12,20}

function stepHit()
	if curStep == 1 then
		setCharacterShouldDance('dadCharacter1', false)
		setCharacterShouldDance('dadCharacter2', false)
		setCharacterShouldDance('dadCharacter3', false)
		setCharacterShouldDance('dadCharacter4', false)
	end
	if curStep == 297 or curStep == 305 or curStep == 361 or curStep == 369 or curStep == 401 or curStep == 473 or curStep == 481 or curStep == 529 or curStep == 617 or curStep == 625 or curStep == 745 or curStep == 753 or curStep == 1105 or curStep == 1129 or curStep == 1137 or curStep == 1161 or curStep == 1217 or curStep == 1233 or curStep == 1281 or curStep == 1297 or curStep == 1313 or curStep == 1329 or curStep == 1345 or curStep == 1361 or curStep == 1377 or curStep == 1393 then
		--playCharacterAnimation('dadCharacter1', 'singLEFT', true)
	end
	if curStep == 533 or curStep == 1109 or curStep == 1165 then
	    --playCharacterAnimation('dadCharacter2', 'singLEFT', true)
    end
	if curStep == 1169 then
	    --playCharacterAnimation('dadCharacter3', 'singLEFT', true)
    end
	if curStep == 1401 then
	    playCharacterAnimation('dadCharacter4', 'FadeIn', true)
    end
	if curStep == 1408 then
	    playCharacterAnimation('dadCharacter4', 'idlemoment', true)
    end
	if curStep == 1536 then
	    playCharacterAnimation('dadCharacter4', 'FadeOut', true)
    end
	if curStep == 1408 then
        triggerEvent('Camera Flash','White','1')
	end

	local section = math.floor(curStep/16)
	local secStep = curStep % 16
	local doubleSecStep = curStep % 32

	function camBump()
		triggerEvent('add camera zoom','0.06','0.06')
		for i = 0, camCount-1 do
			setActorProperty('noteCamZoom'..i, 'angle', 0.95-(0.02*i))
			tweenActorProperty('noteCamZoom'..i, 'angle', 1.0, crochet*0.001*4, 'quadOut')
		end
	end

	if (section >= 0 and section < 28 and section ~= 15 and section ~= 23) or (section >= 32 and section < 80 and section ~= 63) or (section >= 96 and section < 104) then 
		if doubleSecStep == 0 or doubleSecStep == 12 or doubleSecStep == 20 then 
			camBump()
		end
	end 

	if (section >= 16 and section < 28 and section ~= 23) or (section >= 32 and section < 48) or (section >= 64 and section < 80) then 
		if secStep == 8 then 
			triggerEvent('add camera zoom','0.1','0.1')
			setActorX(-50, 'noteCamZoom0')
			setActorX(50, 'noteCamZoom1')
			tweenActorProperty('noteCamZoom0', 'x', 0, crochet*0.001*4, 'quadOut')
			tweenActorProperty('noteCamZoom1', 'x', 0, crochet*0.001*4, 'quadOut')
			if (section >= 64) then 
				setActorY(-50, 'noteCamZoom2')
				setActorY(50, 'noteCamZoom3')
				tweenActorProperty('noteCamZoom2', 'y', 0, crochet*0.001*4, 'quadOut')
				tweenActorProperty('noteCamZoom3', 'y', 0, crochet*0.001*4, 'quadOut')
			end
		end
	end
	if (section >= 28 and section < 29) then 
		if curStep % 8 == 0 then 
			camBump()
		end
	end
	if (section == 31) then 
		if curStep % 4 == 0 then 
			camBump()
		end
	end

	if (section >= 80 and section < 96) then 
		if secStep == 0 or secStep == 2 or secStep == 8 or secStep == 10 then 
			triggerEvent('add camera zoom','0.04','0.04')
			for i = 0, camCount-1 do
				setActorProperty('noteCamZoom'..i, 'angle', 0.95+(0.01*i))
				tweenActorProperty('noteCamZoom'..i, 'angle', 1.0, crochet*0.001*2, 'quadOut')
			end
		end
		if secStep == 4 or secStep == 12 or secStep == 14 then 
			triggerEvent('add camera zoom','0.07','0.07')
			--setActorX(-20, 'noteCamZoom0')
			--setActorX(20, 'noteCamZoom1')
			--tweenActorProperty('noteCamZoom0', 'x', 0, crochet*0.001*2, 'quadOut')
			--tweenActorProperty('noteCamZoom1', 'x', 0, crochet*0.001*2, 'quadOut')

			setActorY(-20, 'noteCamZoom2')
			setActorY(20, 'noteCamZoom3')
			tweenActorProperty('noteCamZoom2', 'y', 0, crochet*0.001*2, 'quadOut')
			tweenActorProperty('noteCamZoom3', 'y', 0, crochet*0.001*2, 'quadOut')
		end
	end 

	if curStep == 224 then 
		--tweenActorProperty('noteCam0', 'zoom', 1.0, crochet*0.001*16, 'cubeIn')
		--tweenActorProperty('noteCam1', 'zoom', 0.8, crochet*0.001*16, 'cubeIn')
		--tweenActorProperty('noteCam2', 'zoom', 0.6, crochet*0.001*16, 'cubeIn')
		--tweenActorProperty('noteCam3', 'zoom', 0.4, crochet*0.001*16, 'cubeIn')
	elseif curStep == 240 then 
		for i = 0, camCount-1 do
			tweenActorProperty('noteCamZoom'..i, 'angle', 1.0, crochet*0.001*16, 'quadOut')
		end

	end

	if modcharts then 

		--spins
		if section == 15 or section == 63 then 
			if secStep == 4 or secStep == 8 or secStep == 12 then 

				for i = 0, 7 do 
					setActorAngle(0, i)
					tweenActorProperty(i, 'angle', 360, crochet*0.001*4, 'quadOut')
				end
			end
		end
		if section == 19 or section == 23 or section == 39 or section == 47 then
			if secStep == 0 or secStep == 8 or secStep == 12 then 
				for i = 0, 7 do 
					setActorAngle(0, i)
					tweenActorProperty(i, 'angle', 360, crochet*0.001*4, 'quadOut')
				end
			end
			if secStep == 4 then 
				for i = 0, 7 do
					tweenActorProperty(i, 'angle', -180, crochet*0.001*2, 'quadOut')
				end
			elseif secStep == 8 then 
				for i = 0, 7 do 
					tweenActorProperty(i, 'angle', -360, crochet*0.001*2, 'quadOut')
				end
			end
		end

		if section == 30 then
			if secStep == 4 or secStep == 12 then 
				for i = 0, 7 do 
					setActorAngle(0, i)
					tweenActorProperty(i, 'angle', -360, crochet*0.001*4, 'quadOut')
				end
			end
		end
		if section == 31 then
			if curStep % 4 == 0 then 
				for i = 0, 7 do 
					setActorAngle(0, i)
					tweenActorProperty(i, 'angle', 360, crochet*0.001*4, 'quadOut')
				end
			end
		end
		if section == 33 or section == 69 then
			if secStep == 8 or secStep == 12 then 
				for i = 0, 7 do 
					setActorAngle(0, i)
					tweenActorProperty(i, 'angle', 360, crochet*0.001*4, 'quadOut')
				end
			end
		end

		if section == 71 then

			if secStep == 0 or secStep == 2 or secStep == 4 or secStep == 6 then 
				for i = 0, 7 do 
					setActorAngle(0, i)
					tweenActorProperty(i, 'angle', -360, crochet*0.001*2, 'quadOut')
				end
			end


			if secStep == 8 or secStep == 12 then 
				
				for i = 0, 7 do 
					setActorAngle(0, i)
					tweenActorProperty(i, 'angle', 360, crochet*0.001*4, 'quadOut')
				end
			end
		end

	end



	if section == 73 then 
		if secStep == 0 or secStep == 4 or secStep == 8 then 
			if modcharts then 
			for i = 0, 7 do 
				setActorAngle(0, i)
				tweenActorProperty(i, 'angle', 360, crochet*0.001*4, 'quadOut')
			end
		end

			if secStep == 4 then 
				for i = 0, camCount-1 do
					setActorProperty('noteCam'..i, 'angle', 10-(10*i))
					tweenActorProperty('noteCam'..i, 'angle', 0.0, crochet*0.001*4, 'quadOut')
				end
			else 
				for i = 0, camCount-1 do
					setActorProperty('noteCam'..i, 'angle', -(10-(10*i)))
					tweenActorProperty('noteCam'..i, 'angle', 0.0, crochet*0.001*4, 'quadOut')
				end
			end
		end
	end

	if curStep == 408 then 
		if modcharts then 
		for i = 0, 7 do 
			setActorAngle(0, i)
			tweenActorProperty(i, 'angle', 360, crochet*0.001*4, 'quadOut')
		end
	end
	end

	if curStep == 1288 or curStep == 1322 or curStep == 1352 or curStep == 1384 or curStep == 1224 then 
		for i = 0, camCount-1 do
			setActorProperty('noteCam'..i, 'angle', 10-(6*i))
			tweenActorProperty('noteCam'..i, 'angle', 0.0, crochet*0.001*4, 'quadOut')
		end
		if modcharts then 
		for i = 0, 7 do 
			setActorAngle(0, i)
			tweenActorProperty(i, 'angle', 360, crochet*0.001*4, 'quadOut')
		end
	end
	elseif curStep == 1336 or curStep == 1308 or curStep == 1372 or curStep == 1400 or curStep == 1240 then 
		for i = 0, camCount-1 do
			setActorProperty('noteCam'..i, 'angle', -(10-(6*i)))
			tweenActorProperty('noteCam'..i, 'angle', 0.0, crochet*0.001*4, 'quadOut')
		end
		if modcharts then 
		for i = 0, 7 do 
			setActorAngle(0, i)
			tweenActorProperty(i, 'angle', -360, crochet*0.001*4, 'quadOut')
		end
	end

	elseif curStep == 1304 or curStep == 1306 or curStep == 1368 or curStep == 1370 then 
		for i = 0, camCount-1 do
			setActorProperty('noteCam'..i, 'angle', 10-(6*i))
			tweenActorProperty('noteCam'..i, 'angle', 0.0, crochet*0.001*2, 'quadOut')
		end
		if modcharts then 
		for i = 0, 7 do 
			setActorAngle(0, i)
			tweenActorProperty(i, 'angle', 360, crochet*0.001*2, 'quadOut')
		end
	end
	end

	--[[if curStep % 16 == 0 then 
		for i = 0, camCount-1 do
			setActorProperty('noteCam'..i, 'angle', 10-(3*i))
			tweenActorProperty('noteCam'..i, 'angle', 0, crochet*0.001*4, 'quadOut')
		end
	end]]--

	if curStep == 1276 then 
		tweenActorProperty('camGameZoomShit', 'x', 1, crochet*0.001*4, 'cubeIn')
		--tweenActorProperty('camOffset', 'angle', -0.3, crochet*0.001*4, 'cubeIn')

		--tweenActorProperty('noteCamZoom0', 'x', -300, crochet*0.001*4, 'cubeIn')
		--tweenActorProperty('noteCamZoom1', 'x', -300, crochet*0.001*4, 'cubeIn')
		--tweenActorProperty('noteCamZoom2', 'x', 300, crochet*0.001*4, 'cubeIn')
		--tweenActorProperty('noteCamZoom3', 'x', 300, crochet*0.001*4, 'cubeIn')
		tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*4, 'cubeIn')
		if modcharts then 
		if not middlescroll then 
			for i = 0, 3 do 
				tweenActorProperty(i, 'x', defaultX[i+1]+100, crochet*0.001*4, 'cubeIn')
				--tweenActorProperty(i, 'alpha', 0.1, crochet*0.001*4, 'cubeIn')
				tweenActorProperty(i+4, 'x', defaultX[i+1+4]-100, crochet*0.001*4, 'cubeIn')
			end
		end
	end
	end
	if curStep == 1340 or curStep == 1468 then 
		--tweenActorProperty('camOffset', 'x', -100, crochet*0.001*4, 'cubeIn')
		if modcharts then 
		if not middlescroll then 
			for i = 0, 3 do 
				tweenActorProperty(i, 'x', defaultX[i+1]+100+448, crochet*0.001*4, 'cubeIn')
				tweenActorProperty(i+4, 'x', defaultX[i+1+4]-100-448, crochet*0.001*4, 'cubeIn')
			end
		end
	end
		tweenShaderProperty('mirror', 'angle', 180, crochet*0.001*4, 'cubeIn')
	end
	if curStep == 1404 then 
		--tweenActorProperty('camOffset', 'x', -100, crochet*0.001*4, 'cubeIn')
		if modcharts then 
		if not middlescroll then 
			for i = 0, 3 do 
				tweenActorProperty(i, 'x', defaultX[i+1]+100, crochet*0.001*4, 'cubeIn')
				tweenActorProperty(i+4, 'x', defaultX[i+1+4]-100, crochet*0.001*4, 'cubeIn')
			end
		end
	end
		tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeIn')
	end
	if curStep == 1532 then 
		tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('camGameZoomShit', 'x', 0, crochet*0.001*4, 'cubeIn')
		--tweenActorProperty('camOffset', 'x', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('camOffset', 'angle', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('noteCamZoom0', 'x', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('noteCamZoom1', 'x', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('noteCamZoom2', 'x', 0, crochet*0.001*4, 'cubeIn')
		tweenActorProperty('noteCamZoom3', 'x', 0, crochet*0.001*4, 'cubeIn')
		if modcharts then 
		for i = 0, 7 do 
			tweenActorProperty(i, 'y', defaultY[i+1], crochet*0.001*8, 'cubeIn')
			tweenActorProperty(i, 'alpha', 0.55, crochet*0.001*4, 'cubeIn')
			tweenActorProperty(i, 'x', defaultX[i+1], crochet*0.001*4, 'cubeIn')
		end
		end
	end


	if curStep == 1696 then 
		setActorProperty('black', 'alpha', 1)
	end

end

function lerp(a, b, ratio)
	return a + ratio * (b - a);
end

function updatePost(elapsed)
	



	if modcharts then 

		--have the zoom seperate so i can multiply different zoom levels for the end part
		local camZoomMult = lerp(0.0, getCamZoom()-0.9, getActorX('camGameZoomShit'))


		--was cool but it would probably break with different bgs and characters idk
		--local camXOff = lerp(0.0, -getCameraScrollX('game')+1000, getActorX('camGameZoomShit'))
		--local camYOff = lerp(0.0, -getCameraScrollY('game')+400, getActorX('camGameZoomShit'))

		--if not charsAndBGs then 
		local camXOff = 0
		local camYOff = 0
		--end

		local wave = (getActorX('camGameZoomShit') * 85 * math.sin(songPos*0.001*2.2916))

		for i = 0, camCount-1 do
			setActorProperty('noteCam'..i, 'zoom', getActorAngle('noteCamZoom'..i)+getActorAngle('camOffset'))
			setActorProperty('noteCam'..i, 'x', camXOff+getActorX('noteCamZoom'..i)+getActorX('camOffset'))
			setActorProperty('noteCam'..i, 'y', camYOff+getActorY('noteCamZoom'..i))
		end
	
		if curStep < 1536 then 
			if wave ~= 0 then 
				for i = 0, 7 do 
					if i < 4 then 
						setActorY(defaultY[i+1]-wave, i)
					else 
						setActorY(wave+defaultY[i+1], i)
					end
				end
			end
		else 
			for i = 0, 7 do 
				setActorY(defaultY[i+1], i)
			end
		end
	end



end

function playerTwoSing(data, time, type)

end