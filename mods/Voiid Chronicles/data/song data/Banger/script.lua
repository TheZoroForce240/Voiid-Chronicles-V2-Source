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
local downscrollDiff = 1
local rad = math.pi/180;

--based on code from andromeda engine, but with lua
local velChanges = {

	--step, speed mult
	{0, 1.0},
}
local velMarkers = {

}
function mapVelChanges()

	for i = 1, #velChanges do  --convert from step to millseconds
		velChanges[i][1] = getStrumTimeFromStep(velChanges[i][1])
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
        makeSprite('note2'..i, '', 0, 0)
        makeSprite('angle'..i, '', 0, 0)
		makeSprite('reverse'..i, '', 0, 0)
	end


    makeSprite('scale', '', 1, 1)

    makeSprite('playerAngle', '', 0, 0)
    makeSprite('opponentAngle', '', 0, 0)
    makeSprite('angle', '', 0, 0)


	makeSprite('drunk', '', 0, 0)
	makeSprite('tipsy', '', 0, 0)

	makeSprite('drunkSpeed', '', 1, 1)
	makeSprite('tipsySpeed', '', 1, 1)
	setActorAngle(1,'drunkSpeed')
	setActorAngle(1,'tipsySpeed')


	makeSprite('noteSine', '', 0, 0)
	makeSprite('noteSineSpeed', '', 6, 6)
	setActorAngle(6,'noteSineSpeed')

	makeSprite('brake', '', 0, 0)
	makeSprite('boost', '', 0, 0)

   

    makeSprite('global', '', 0, 0)
    makeSprite('player', '', 0, 0)
    makeSprite('opponent', '', 0, 0)

	makeSprite('playerIA', '', 0, 0)
    makeSprite('opponentIA', '', 0, 0)
	makeSprite('playerRot', '', 0, -90)
    makeSprite('opponentRot', '', 0, -90)


	makeSprite('screenRot', '', 0, 0)

	makeSprite('songPosOffset', '', 0, 0)

	defaultZoom = getProperty('', 'defaultCamZoom')
	--trace(defaultZoom)

	if not downscrollBool then 
		downscrollDiff = -1
	end

    setupShaders()

	if opponentPlay then 
		curOpponent = 'player'
	end
end
							--x,y,z,w
local screenRotQuaternion = {0,0,0,1}

local notePerlinSpeed = 0.0002
local notePerlinRange = {20,20,20,0}
local noteRangeBoost = 1

local perlinSpeed = 0.2
					--p2          p1
					--x,y,z,angle,x,y,z,angle
local perlinTime = {0,0,0,0,0,0,0,0}
local perlinRange = {0,0,0,5}

local perlinCamRange = {0.05,0.05,2,0}

function playerOneSing(data, time, nt)
	if nt == 'VoiidBullet' then 
		noteRangeBoost = noteRangeBoost + 1.5
	end
end

function updatePerlin(elapsed)

	for i = 1, #perlinTime do 
		perlinTime[i] = perlinTime[i] + elapsed*math.random()*perlinSpeed
	end

	if noteRangeBoost > 1 then 
		noteRangeBoost = noteRangeBoost - elapsed*10
	else 
		noteRangeBoost = 1
	end

	--setActorX(getActorX('screenRot')+100*elapsed, 'screenRot')
	--setActorY(getActorY('screenRot')+60*elapsed, 'screenRot')
	--setActorAngle(getActorAngle('screenRot')+75*elapsed, 'screenRot')

	setShaderProperty('mirror2', 'x', ((-0.5 + perlin(perlinTime[1], 0, 0))*perlinCamRange[1]))
	setShaderProperty('mirror2', 'y', ((-0.5 + perlin(0, perlinTime[2], 0))*perlinCamRange[2]))
	setShaderProperty('mirror2', 'angle', ((-0.5 + perlin(0, 0, perlinTime[3]))*perlinCamRange[3]))


	screenRotQuaternion = updateQuaternion('screenRot', screenRotQuaternion)
end
--https://github.com/topameng/CsToLua/blob/master/tolua/Assets/Lua/Quaternion.lua
function updateQuaternion(vec3, q)
	local x = getActorX(vec3)*rad*0.5
	local y = getActorY(vec3)*rad*0.5
	local z = getActorAngle(vec3)*rad*0.5

	local sinX = math.sin(x)
    local cosX = math.cos(x)
    local sinY = math.sin(y)
    local cosY = math.cos(y)
    local sinZ = math.sin(z)
    local cosZ = math.cos(z)
    
    q[4] = cosY * cosX * cosZ + sinY * sinX * sinZ
    q[1] = cosY * sinX * cosZ + sinY * cosX * sinZ
    q[2] = sinY * cosX * cosZ - cosY * sinX * sinZ
    q[3] = cosY * cosX * sinZ - sinY * sinX * cosZ
	return q
end
function applyQuaternion(xyz, q)

	local num 	= q[1] * 2
	local num2 	= q[2] * 2
	local num3 	= q[3] * 2
	local num4 	= q[1] * num
	local num5 	= q[2] * num2
	local num6 	= q[3] * num3
	local num7 	= q[1] * num2
	local num8 	= q[1] * num3
	local num9 	= q[2] * num3
	local num10 = q[4] * num
	local num11 = q[4] * num2
	local num12 = q[4] * num3

	local point = {xyz[1], xyz[2], xyz[3]} --copy
	
	xyz[1] = (((1 - (num5 + num6)) * point[1]) + ((num7 - num12) * point[2])) + ((num8 + num11) * point[3])
	xyz[2] = (((num7 + num12) * point[1]) + ((1 - (num4 + num6)) * point[2])) + ((num9 - num10) * point[3])
	xyz[3] = (((num8 - num11) * point[1]) + ((num9 + num10) * point[2])) + ((1 - (num4 + num5)) * point[3])

	return xyz
end
function rotateVector(xyz, q)

	xyz[1] = xyz[1] - (1280*0.5) + (112*0.5)
	xyz[2] = xyz[2] - (720*0.5) + (112*0.5)
	--xyz[3] = xyz[3] - (1000)

	xyz = applyQuaternion(xyz, screenRotQuaternion)

	xyz[1] = xyz[1] + (1280*0.5) - (112*0.5)
	xyz[2] = xyz[2] + (720*0.5) - (112*0.5)
	--xyz[3] = xyz[3] + (1000)

	return xyz
end
function getPerlin(player, axis)
	local p = 0
	player = player*4
	if axis == 0 then 
		p = perlin(perlinTime[axis+player], player, player)
	elseif axis == 1 then 
		p = perlin(player, perlinTime[axis+player], player)
	elseif axis == 2 then 
		p = perlin(player, player, perlinTime[axis+player])
	else 
		p = perlin(perlinTime[axis+player], player, perlinTime[axis+player])
	end
	return ((-0.5 + p)*perlinRange[axis])
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

function getNoteX(i)
    local pos = targetnoteXPos[i+1] + getActorX('global') + getActorX('note'..i) + getActorX('note2'..i)
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
		pos = pos + getPerlin(0, 1)
	else 
		pos = pos + getPerlin(1, 1)
    end
    pos = pos + getActorX(p) + ((-0.5 + perlin((songPos*notePerlinSpeed)+i, 0, 0))*notePerlinRange[1]*noteRangeBoost)
    return pos
end
function getNoteY(i)
    local pos = targetnoteYPos[i+1] + getActorY('global') + getActorY('note'..i) + getActorY('note2'..i)
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
		pos = pos + getPerlin(0, 2)
	else 
		pos = pos + getPerlin(1, 2)
    end
    pos = pos + getActorY(p)

	local scrollSwitch = 520
	if downscrollBool then 
		scrollSwitch = -520
	end
	pos = pos + (getActorY('reverse'..i)*scrollSwitch) + ((-0.5 + perlin(0, (songPos*notePerlinSpeed)+i, 0))*notePerlinRange[2]*noteRangeBoost)

    return pos
end
function getNoteZ(i)
    local pos = getActorAngle('global') + getActorAngle('note'..i) + getActorAngle('note2'..i)
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
		pos = pos + getPerlin(0, 3)
	else 
		pos = pos + getPerlin(1, 3)
    end
    pos = pos + getActorAngle(p) + ((-0.5 + perlin(0, 0, (songPos*notePerlinSpeed)+i))*notePerlinRange[3]*noteRangeBoost)
    return pos
end
function getNoteAngle(i)
    local pos = getActorAngle('angle') + getActorAngle('angle'..i)
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
		pos = pos - getPerlin(0, 4)
	else 
		pos = pos - getPerlin(1, 4)
    end
    pos = pos + getActorAngle(p..'Angle')
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

function getIAX(i)
	local x = 0
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
    end
	x = x + getActorX(p..'IA')
	return x
end
function getIAY(i)
	local y = 0
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
		y = y + getPerlin(0, 4)
	else 
		y = y + getPerlin(1, 4)
    end
	y = y + getActorY(p..'IA')
	return y
end
function getStrumRot(i)
	local x = 0
	local y = 0
    local p = 'player'
    if i < keyCount then 
        p = 'opponent'
		y = y + getPerlin(0, 4)
	else 
		y = y + getPerlin(1, 4)
    end
	x = x + getActorX(p..'Rot')
	y = y + getActorY(p..'Rot')
	return {x, y}
end

function clamp(val, min, max)
	if val < min then
		val = min
	elseif max < val then
		val = max
	end
	return val
end
--https://stackoverflow.com/questions/5294955/how-to-scale-down-a-range-of-numbers-with-a-known-min-and-max-value
function scale(valueIn, baseMin, baseMax, limitMin, limitMax)
	return ((limitMax - limitMin) * (valueIn - baseMin) / (baseMax - baseMin)) + limitMin
end

function drunk(lane, curPos, speed)
	return (math.cos( ((songPos*0.001) + ((lane%4)*0.2) + 
        (curPos*0.45)*(10/720)) * (speed*0.2)) * 112*0.5);
end
function tipsy(lane, curPos, speed)
	return ( math.cos( songPos*0.001 *(1.2) + 
	(lane%4)*(2.0) + speed*(0.2) ) * 112*0.4 );
end
function boost(value, height, curPos, speed)
	local yOffset = 0
	local fYOffset = -curPos / speed --idk why its minus it just is
	local fEffectHeight = height
	local fNewYOffset = fYOffset * 1.5 / ((fYOffset+fEffectHeight/1.2)/fEffectHeight); 
	local fAccelYAdjust = value * (fNewYOffset - fYOffset);
	fAccelYAdjust = clamp(fAccelYAdjust*speed, -400, 400);
	yOffset = yOffset - (fAccelYAdjust);

	curPos = curPos + yOffset
	return curPos
end
function brake(value, height, curPos, speed)
	--trace(curPos)
	local yOffset = 0
	local fYOffset = -curPos / speed
	local fEffectHeight = height
	local fScale = scale(fYOffset, 0, fEffectHeight, 0, 1);
	local fNewYOffset = fYOffset * fScale; 
	local fBrakeYAdjust = value * (fNewYOffset - fYOffset);
	fBrakeYAdjust = clamp( fBrakeYAdjust, -400, 400 );
	yOffset = yOffset - fBrakeYAdjust*speed;

	curPos = curPos + yOffset
	
	return curPos
end
function getCurPos(curPos, speed)


	if getActorX('boost') ~= 0 then 
		curPos = boost(getActorX('boost'), 720, curPos, speed)
	end
	if getActorX('brake') ~= 0 then 
		curPos = brake(getActorX('brake'), 720, curPos, speed)
	end

	return curPos
end


function updatePost(elapsed)
	if not modcharts then 
		return
	end
	songSpeed = getProperty('', 'speed')
	local songVisualPos = getTime(songPos) + getActorX('songPosOffset')

	noteScale = getActorX('scale')

	updatePerlin(elapsed)

	--drunk = lerp(drunk, drunkLerp, elapsed*5)

	local currentBeat = (songPos / 1000)*(bpm/60)

	for i = 0,(keyCount+playerKeyCount)-1 do 
		noteXPos[i+1] = getNoteX(i)
		noteYPos[i+1] = getNoteY(i)
		noteZPos[i+1] = getNoteZ(i)

		local thisnotePosX = noteXPos[i+1] + getXOffset(i, 0)
		local thisnotePosY = noteYPos[i+1] + getYOffset(i, 0)
		local thisnotePosZ = noteZPos[i+1] + getZOffset(i, 0)


		local rotatedPos = rotateVector({thisnotePosX, thisnotePosY, thisnotePosZ}, screenRotQuaternion)

		--local thisnotePosX = noteXPos[i+1]
		--local thisnotePosY = noteYPos[i+1]
		--local thisnotePosZ = (noteZPos[i+1]/1000)-1

		--noteAngle[i+1] = lerp(noteAngle[i+1], targetnoteAngle[i+1], elapsed*lerpSpeedAngle)
		setActorModAngle(getNoteAngle(i), i)
        setActorAlpha(getNoteAlpha(i), i)

		local totalNotePos = calculatePerspective(rotatedPos[1], rotatedPos[2], (rotatedPos[3]*0.001)-1)
		
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
			curPos = getCurPos(curPos, songSpeed)
			offsetX = offsetX + getXOffset(data, curPos)
			local thisnoteYPos = noteYPos[data+1]

			local incomingAngleRotation = getCartesianCoords3D(getIAX(data), getIAY(data), (dist*curPos))

			thisnoteYPos = thisnoteYPos + incomingAngleRotation[2] - (getRenderedNoteOffsetY(i)) + getYOffset(data, curPos)
			if dist > 0 then --downscroll
				if isRenderedNoteSustainEnd(i) then 
					thisnoteYPos = thisnoteYPos - (getRenderedNoteHeight(i))+2
				end
			--else 
				--thisnoteYPos = thisnoteYPos - (0.45*curPos) - (getRenderedNoteOffsetY(i))
			end
            
			local thisnoteXPos = noteXPos[data+1]+offsetX+incomingAngleRotation[1]
			local thisnotePosZ = (noteZPos[data+1] + getZOffset(data, curPos) + incomingAngleRotation[3])

			local rotatedPos = rotateVector({thisnoteXPos, thisnoteYPos, thisnotePosZ}, screenRotQuaternion)

			local totalNotePos = calculatePerspective(rotatedPos[1], rotatedPos[2], (rotatedPos[3]*0.001)-1)

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

local distFromCenter = {1.5, 0.5, -0.5, -1.5}

function getXOffset(data, curPos)
	local off = 0
	if getActorX('drunk') ~= 0 then 
		off = off + (getActorX('drunk')*drunk(data, curPos, getActorX('drunkSpeed')))
	end
	if getActorX('tipsy') ~= 0 then 
		off = off + (getActorX('tipsy')*tipsy(data, curPos, getActorX('tipsySpeed')))
	end
	if getActorX('noteSine') ~= 0 and curPos ~= 0 then 
		off = off + (getActorX('noteSine')*math.sin((getActorX('noteSineSpeed')*curPos*0.001)+data))
	end

	local strumRot = getStrumRot(data)
	if strumRot[1] ~= 0 or strumRot[2] ~= 0 then 
		off = off + (distFromCenter[(data%4)+1]*112) -- move to center

		off = off + getCartesianCoords3D(strumRot[1], strumRot[2], (distFromCenter[(data%4)+1]*112))[1]

	end


	return off
end
function getYOffset(data, curPos)
	local off = 0
	if getActorY('drunk') ~= 0 then 
		off = off + (getActorY('drunk')*drunk(data, curPos, getActorY('drunkSpeed')))
	end
	if getActorY('tipsy') ~= 0 then 
		off = off + (getActorY('tipsy')*tipsy(data, curPos, getActorY('tipsySpeed')))
	end
	if getActorY('noteSine') ~= 0 and curPos ~= 0 then 
		off = off + (getActorY('noteSine')*math.sin((getActorY('noteSineSpeed')*curPos*0.001)+data))
	end
	local strumRot = getStrumRot(data)
	if strumRot[1] ~= 0 or strumRot[2] ~= 0 then 
		off = off + getCartesianCoords3D(strumRot[1], strumRot[2], (distFromCenter[(data%4)+1]*112))[2]
	end
	return off
end
function getZOffset(data, curPos)
	local off = 0
	if getActorAngle('drunk') ~= 0 then 
		off = off + (getActorAngle('drunk')*drunk(data, curPos, getActorAngle('drunkSpeed')))
	end
	if getActorAngle('tipsy') ~= 0 then 
		off = off + (getActorAngle('tipsy')*tipsy(data, curPos, getActorAngle('tipsySpeed')))
	end
	if getActorAngle('noteSine') ~= 0 and curPos ~= 0 then 
		off = off + (getActorAngle('noteSine')*math.sin((getActorAngle('noteSineSpeed')*curPos*0.001)+data))
	end
	local strumRot = getStrumRot(data)
	if strumRot[1] ~= 0 or strumRot[2] ~= 0 then 
		off = off + getCartesianCoords3D(strumRot[1], strumRot[2], (distFromCenter[(data%4)+1]*112))[3]
	end
	return off
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

	return {x,y,z}
end



function setupShaders()

	initShader('mirror', 'BarrelBlurEffect')
	setCameraShader('game', 'mirror')
    if modcharts then 
		setCameraShader('hud', 'mirror')
	end
	setShaderProperty('mirror', 'zoom', 1.0)
	setShaderProperty('mirror', 'barrel', 0.0)
	setShaderProperty('mirror', 'doChroma', true)

	initShader('mirror2', 'MirrorRepeatEffect')
	setCameraShader('game', 'mirror2')
    if modcharts then 
		setCameraShader('hud', 'mirror2')
	end
	setShaderProperty('mirror2', 'zoom', 1.0)

    --setShaderProperty('color', 'green', 0.3)

    --initShader('caBlue', 'ChromAbBlueSwapEffect')
    --setCameraShader('game', 'caBlue')
    --setCameraShader('hud', 'caBlue')
    --setShaderProperty('caBlue', 'strength', -0.001)
    --setShaderProperty('caBlue', 'strength', 0.0)

    initShader('grey', 'GreyscaleEffect')
    setCameraShader('game', 'grey')
    setCameraShader('hud', 'grey')
    setShaderProperty('grey', 'strength', 1.0)

    initShader('vignette', 'VignetteEffect')
    setCameraShader('hud', 'vignette')
    setCameraShader('game', 'vignette')
    setShaderProperty('vignette', 'strength', 15)
    setShaderProperty('vignette', 'size', 0.75)


	makeSprite('black', '', 0, 0, 1)
	setObjectCamera('black', 'hud')
	makeGraphic('black', 4000, 2000, '0xFFAE3FED')
	actorScreenCenter('black')
	setActorAlpha(0, 'black')

end
function songStart()
    --tweenShaderProperty('color', 'red', 0.9, crochet*0.001*16*8, 'circIn')
    --tweenShaderProperty('color', 'green', 1.1, crochet*0.001*16*8, 'cubeIn')
    --tweenShaderProperty('color', 'blue', 0.9, crochet*0.001*16*8, 'cubeIn')
    --tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*16*16, 'cubeInOut')

	
end

function stepHit()
    local section = math.floor(curStep/16)
	local secStep = curStep % 16
    if curStep % 16 == 0 then 
        sectionHit(section)
    end

	if curStep == 120 then 
		tweenShaderProperty('grey', 'strength', 0, crochet*0.001*8, 'cubeIn')
		tweenShaderProperty('mirror', 'zoom', 2, crochet*0.001*8, 'cubeIn')
		tweenShaderProperty('mirror', 'barrel', 20, crochet*0.001*8, 'cubeIn')
	elseif curStep == 128 then 
		--if not opponentPlay then 
		setShaderProperty('mirror', 'zoom', 0.2)
		setActorAlpha(0.7, 'black')
		--end
		setShaderProperty('mirror', 'barrel', -10)
		
		tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'cubeOut')
		tweenShaderProperty('mirror', 'barrel', 0.0, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('black', 'alpha', 0.0, crochet*0.001*8, 'cubeOut')
	end
	
	if (section >= 72 and section < 96) then 
		if secStep == 0 then 
			--green
			setStageColorSwap('hue', 0.6)
		elseif secStep == 4 then 
			--pink
			setStageColorSwap('hue', 0.2)
		elseif secStep == 8 then 
			--yellow/orange
			setStageColorSwap('hue', 0.4)
		elseif secStep == 12 then 
			--purple
			setStageColorSwap('hue', 0)
		end	
		if curStep % 4 == 0 then 
			tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
		elseif curStep % 4 == 2 then 
			tweenShaderProperty('mirror', 'zoom', 0.9, crochet*0.001*2, 'cubeIn')
		end
	end

	if curStep == 224 then 
		tweenShaderProperty('mirror', 'zoom', 1.4, crochet*0.001*16, 'cubeIn')
	elseif curStep == 256 or curStep == 1152 or curStep == 640 then 
		if not opponentPlay then 
		setShaderProperty('mirror', 'zoom', 0.2)
		setActorAlpha(0.7, 'black')
		setShaderProperty('mirror', 'barrel', -10)
		end
		
		
		tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'cubeOut')
		tweenShaderProperty('mirror', 'barrel', 0.0, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('black', 'alpha', 0.0, crochet*0.001*8, 'cubeOut')
	end

	if section == 15 then 
		if curStep % 4 ~= 3 then 
			setShaderProperty('mirror', 'zoom', 1.5+(secStep/10))
		end
	end

	if curStep == 608 then 
		tweenShaderProperty('mirror', 'zoom', 3, crochet*0.001*32, 'cubeIn')
	elseif curStep == 636 then 
		if not opponentPlay then 
			tweenShaderProperty('mirror', 'angle', -360, crochet*0.001*4, 'cubeIn')
		end
		
	end

	if curStep == 888 then 
		tweenShaderProperty('grey', 'strength', 1, crochet*0.001*4, 'cubeOut')
	elseif curStep == 892 then 
		tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeIn')
		tweenShaderProperty('grey', 'strength', 0, crochet*0.001*4, 'cubeIn')
	end


	if (section >= 16 and section < 96) then 
		if secStep == 8 or (section % 8 == 7 and (secStep == 12 or secStep == 14)) then --clap
			triggerEvent('add camera zoom', 0.07, 0.07)

			setActorProperty('drunk', 'angle', 2.0)
			setActorProperty('drunkSpeed', 'angle', 8.0)
			tweenActorProperty('drunk', 'angle', 0.0, crochet*0.001*2, 'cubeOut')
			setActorProperty('tipsy', 'y', 2.0)
			tweenActorProperty('tipsy', 'y', 0.0, crochet*0.001*2, 'cubeOut')
		end
		if curStep % 32 == 0 or secStep == 12 or (section % 8 == 3 and secStep == 14) then 
			triggerEvent('add camera zoom', 0.07, 0.07)
		end
		if (section % 2 == 1 and (secStep == 4 or secStep == 6)) or (section % 4 == 1 and (secStep == 5)) then 
			triggerEvent('add camera zoom', 0.07, 0.07)
		end
	end	
	if (section >= 96 and section < 101) then 
		--if curStep % 32 == 0 or secStep == 12 or (section % 8 == 3 and (secStep == 14 or secStep == 13)) then 
		--	triggerEvent('add camera zoom', 0.07, 0.07)
		--end
		--if (section % 2 == 1 and (secStep == 4 or secStep == 6)) or (section % 4 == 1 and (secStep == 5)) then 
		--	triggerEvent('add camera zoom', 0.07, 0.07)
		--end
	end	

	

	if curStep == 1136 then 
		tweenShaderProperty('grey', 'strength', 1, crochet*0.001*4, 'cubeOut')
	elseif curStep == 1140 then 
		tweenShaderProperty('grey', 'strength', 0, crochet*0.001*4, 'cubeIn')
	end

	if section == 70 then 

		if curStep % 8 == 0 then 
			tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
			tweenShaderProperty('mirror', 'angle', 10, crochet*0.001*2, 'cubeOut')
			tweenShaderProperty('mirror', 'y', 0, crochet*0.001*2, 'cubeOut')
		elseif curStep % 8 == 2 then 
			tweenShaderProperty('mirror', 'zoom', 0.9, crochet*0.001*2, 'cubeIn')
			tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*2, 'cubeIn')
			tweenShaderProperty('mirror', 'y', 0.1, crochet*0.001*2, 'cubeIn')
		elseif curStep % 8 == 4 then 
			tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*2, 'cubeOut')
			tweenShaderProperty('mirror', 'angle', -10, crochet*0.001*2, 'cubeOut')
			tweenShaderProperty('mirror', 'y', 0, crochet*0.001*2, 'cubeOut')
		elseif curStep % 8 == 6 then 
			tweenShaderProperty('mirror', 'zoom', 0.9, crochet*0.001*2, 'cubeIn')
			tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*2, 'cubeIn')
			tweenShaderProperty('mirror', 'y', 0.1, crochet*0.001*2, 'cubeIn')
		end
	end
	if section == 71 then 

		if secStep <= 8 then 
			if curStep % 4 == 0 then 
				tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001, 'cubeOut')
				tweenShaderProperty('mirror', 'angle', 10, crochet*0.001, 'cubeOut')
				tweenShaderProperty('mirror', 'y', 0, crochet*0.001, 'cubeOut')
			elseif curStep % 4 == 1 then 
				tweenShaderProperty('mirror', 'zoom', 0.9, crochet*0.001, 'cubeIn')
				tweenShaderProperty('mirror', 'angle', 0, crochet*0.001, 'cubeIn')
				tweenShaderProperty('mirror', 'y', 0.1, crochet*0.001, 'cubeIn')
			elseif curStep % 4 == 2 then 
				tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001, 'cubeOut')
				tweenShaderProperty('mirror', 'angle', -10, crochet*0.001, 'cubeOut')
				tweenShaderProperty('mirror', 'y', 0, crochet*0.001, 'cubeOut')
			elseif curStep % 4 == 3 then 
				tweenShaderProperty('mirror', 'zoom', 0.9, crochet*0.001, 'cubeIn')
				tweenShaderProperty('mirror', 'angle', 0, crochet*0.001, 'cubeIn')
				tweenShaderProperty('mirror', 'y', 0.1, crochet*0.001, 'cubeIn')
			end
		end

		if secStep == 9 or secStep == 11 then 
			tweenShaderProperty('mirror', 'angle', -10, crochet*0.001, 'cubeOut')
		elseif secStep == 10 then 
			tweenShaderProperty('mirror', 'angle', 10, crochet*0.001, 'cubeOut')
		elseif secStep == 12 then 
			if not opponentPlay then 
				tweenShaderProperty('mirror', 'angle', 360, crochet*0.001*4, 'cubeIn')
			else 
				tweenShaderProperty('mirror', 'angle', 0, crochet*0.001*4, 'cubeIn')
			end
			tweenActorProperty('boost', 'x', 0.5, crochet*0.001*4, 'cubeIn')
		end


	end

	if curStep == 1400 then 
		if not middlescroll then 
			tweenActorProperty('player', 'x', -320, crochet*0.001*8, 'cubeIn')
			tweenActorProperty('opponent', 'x', 320, crochet*0.001*8, 'cubeIn')
			tweenActorProperty(curOpponent, 'alpha', 0.05, crochet*0.001*8, 'cubeIn')
		end

		tweenActorProperty('note0', 'x', -100, crochet*0.001*8, 'cubeIn')
		tweenActorProperty('note1', 'x', -50, crochet*0.001*8, 'cubeIn')
		tweenActorProperty('note2', 'x', 50, crochet*0.001*8, 'cubeIn')
		tweenActorProperty('note3', 'x', 100, crochet*0.001*8, 'cubeIn')
		tweenActorProperty('note4', 'x', -100, crochet*0.001*8, 'cubeIn')
		tweenActorProperty('note5', 'x', -50, crochet*0.001*8, 'cubeIn')
		tweenActorProperty('note6', 'x', 50, crochet*0.001*8, 'cubeIn')
		tweenActorProperty('note7', 'x', 100, crochet*0.001*8, 'cubeIn')
		
	end

	if curStep == 1504 then 
		tweenShaderProperty('mirror', 'zoom', 3, crochet*0.001*32, 'cubeIn')
		if not middlescroll then 
			tweenActorProperty('player', 'x', 0, crochet*0.001*32, 'cubeIn')
			tweenActorProperty('opponent', 'x', 0, crochet*0.001*32, 'cubeIn')
			--tweenActorProperty(curOpponent, 'alpha', 1, crochet*0.001*32, 'cubeIn')
		end
		for i = 0,7 do 
			tweenActorProperty('note'..i, 'x', 0, crochet*0.001*32, 'cubeIn')
		end
	end
end
function sectionHit(section)

    if section == 96 then 
		if not opponentPlay then 
		setShaderProperty('mirror', 'zoom', 0.2)
		setShaderProperty('mirror', 'barrel', -10)
		setActorAlpha(0.7, 'black')
		end
		
		
		tweenShaderProperty('mirror', 'zoom', 1, crochet*0.001*8, 'cubeOut')
		tweenShaderProperty('mirror', 'barrel', 0.0, crochet*0.001*8, 'cubeOut')
		tweenActorProperty('black', 'alpha', 0.0, crochet*0.001*8, 'cubeOut')
		tweenActorProperty(curOpponent, 'alpha', 1, crochet*0.001*8, 'cubeOut')
        --tweenShaderProperty('grey', 'strength', 0, crochet*0.001*16*8, 'cubeIn')
		perlinSpeed = 0.2
		perlinCamRange = {0.05,0.05,2,0}
    end
	if section == 72 then 
		perlinSpeed = 0.5
		perlinCamRange = {0.1,0.1,5,0}
	end

	if section == 101 then 
		tweenShaderProperty('grey', 'strength', 1, crochet*0.001*16, 'cubeOut')
	end
end
