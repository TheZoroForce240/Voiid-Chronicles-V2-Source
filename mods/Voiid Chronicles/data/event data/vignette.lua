local strength = 1
local size = 0
local lerpedStrength = 0
local lerpedSize = 0
function createPost()
    initShader('vignette', 'VignetteEffect')
    setCameraShader('hud', 'vignette')
    setCameraShader('game', 'vignette')
    setShaderProperty('vignette', 'strength', strength)
    setShaderProperty('vignette', 'size', size)
end
function onEvent(name, position, value1, value2)
    if string.lower(name) == "vignette" then
        strength = tonumber(value1)
		size = tonumber(value2)
    end
end
function lerp(a, b, ratio)
	return a + ratio * (b - a); --the funny lerp
end

function update(elapsed)
    lerpedStrength = lerp(lerpedStrength, strength, elapsed*5)
    lerpedSize = lerp(lerpedSize, size, elapsed*5)
    setShaderProperty('vignette', 'strength', lerpedStrength)
    setShaderProperty('vignette', 'size', lerpedSize)
end