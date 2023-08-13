local particleSpawnTime = 0.01
function createPost()
    initShader('rain', 'RainEffect')
    setCameraShader('game', 'rain')
    --setCameraShader('hud', 'rain')

    if songLower == 'banger' then 
        particleSpawnTime = 0.006
    elseif songLower == 'edgy' then 
        particleSpawnTime = 0.003
    end
    initPool()
end

local particleTime = 0
local particleCount = 0
local velocityAngle = 140
local velocitySpeed = 8000
local spawnX = 0
local spawnWidth = 6000
local spawnY = 300

local piss = false
local pis = 0

function update(elapsed)
    particleTime = particleTime + elapsed
    if particleTime >= particleSpawnTime then 
        particleTime = particleTime - particleSpawnTime
        makeParticle()
    end

    if (pis == 0 and justPressed('P')) or (pis == 1 and justPressed('I')) or (pis > 1 and justPressed('S'))  then 
        pis = pis + 1
        if pis >= 4 then 
            piss = true
        end
    end
end
function lerp(a, b, ratio)
	return a + ratio * (b - a); --the funny lerp
end

local poolLimit = 200
function initPool()

    for i = 0, poolLimit do 
        local sprName = 'rainParticle'..i
        makeSprite(sprName, '', -10000, 0)
        makeGraphic(sprName, 100, 5, 'ffffff')
    end
end

function makeParticle()

    --trace(particleCount)    
    local sprName = 'rainParticle'..particleCount
    local pos = lerp(spawnX, spawnX+spawnWidth, math.random())


    setActorX(pos, sprName)
    setActorY(spawnY, sprName)

    if piss then 
        setActorColor(sprName, 255, 255, 0) --piss
    end

    setActorAngle(velocityAngle, sprName)

    setActorAlpha(lerp(0.25, 0.7, math.random()), sprName)

    setActorVelocityX(math.cos(velocityAngle*(math.pi/180))*velocitySpeed, sprName)
    setActorVelocityY(math.sin(velocityAngle*(math.pi/180))*velocitySpeed, sprName)

    local scroll = lerp(0.8, 1.3, math.random())

    setActorScroll(scroll, scroll, sprName)

    setActorLayer(sprName, getActorLayer('dad')+2)

    particleCount = particleCount + 1
    if particleCount > 200 then 
        particleCount = 0
    end
end