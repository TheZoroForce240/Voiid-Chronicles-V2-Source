--Thanks leather for helping me write these
rotCam = false
rotCamSpd = 0
rotCamRange = 0

rotCamInd = 0

function onEvent(name, position, value1, value2)
    if string.lower(name) == "hud rotate on" then
        rotCam = true

        rotCamSpd = tonumber(value1)
		rotCamRange = tonumber(value2)
    end
end

function update(elapsed)
    if rotCam then
        rotCamInd = rotCamInd + (elapsed / (1 / 120))
        setProperty("camHUD", "angle", math.sin(rotCamInd / 100 * rotCamSpd) * rotCamRange)
    else
        rotCamInd = 0
    end
end