--Thanks leather for helping me write these
rotCam = false
rotCamSpd = 0
rotCamRange = 0

rotCamInd = 0

function onEvent(name, position, value1, value2)
    if string.lower(name) == "rotate shit" then
        rotCam = true

        rotCamSpd = tonumber(value1)
		rotCamRange = tonumber(value2)
    end
end

function update(elapsed)
    if rotCam then
        rotCamInd = rotCamInd + (elapsed / (1 / 120))
        setProperty("camGame", "angle", math.sin(rotCamInd / 100 * rotCamSpd) * rotCamRange)
        setProperty("camHUD", "angle", math.sin(rotCamInd / 100 * rotCamSpd) * rotCamRange)
    else
        rotCamInd = 0
    end
end