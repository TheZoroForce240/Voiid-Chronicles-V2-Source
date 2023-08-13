local bloomValues = {
	{0.18,1},
	{0.3,1.2},
	{0.4,1.3}
}
function createPost()
	
		initShader('bloom', 'BloomEffect')
		setCameraShader('game', 'bloom')
		--setCameraShader('hud', 'bloom')
		setShaderProperty('bloom', 'effect', 0)
		if bloomSetting > 0 then
		setShaderProperty('bloom', 'strength', bloomValues[bloomSetting][1])
		setShaderProperty('bloom', 'effect', bloomValues[bloomSetting][2])
		end
		
		
		--low = 0.18, 1
		--med = 0.3, 1.2
		--high 0.4, 1.3
end
local brightness = 0
local contrast = 1
local doBrightnessWave = false
local bSpeed = 1
local bRange = 0.1

function update(elapsed)
	if doBrightnessWave then 
		setShaderProperty('bloom', 'brightness', brightness + math.sin((songPos * 0.001)*(bpm/60)*bSpeed)*bRange)
	end
end
function onEvent(name, position, value1, value2)
    if string.lower(name) == "brightness sine" then
        doBrightnessWave = not doBrightnessWave
		bSpeed = tonumber(value1)
		bRange = tonumber(value2)
		if not doBrightnessWave then 
			setShaderProperty('bloom', 'brightness', brightness)
		end
    end
	if string.lower(name) == "set brightness" then
		brightness = tonumber(value1)
		setShaderProperty('bloom', 'brightness', brightness)
    end
	if string.lower(name) == "set contrast" then
		contrast = tonumber(value1)
		setShaderProperty('bloom', 'contrast', contrast)
    end
end