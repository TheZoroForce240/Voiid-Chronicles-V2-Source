function createPost()
    initShader('greyscale', 'GreyscaleEffect')
    setCameraShader('game', 'greyscale')
    setCameraShader('hud', 'greyscale')
    setShaderProperty('greyscale', 'strength', 1)

    initShader('pixel', 'MosaicEffect')
    setCameraShader('game', 'pixel')
    setCameraShader('hud', 'pixel')
    setShaderProperty('pixel', 'strength', 1)

    initShader('barrel', 'BarrelBlurEffect')
	setCameraShader('game', 'barrel')
    if modcharts then 
		setCameraShader('hud', 'barrel')
	end
	
	setShaderProperty('barrel', 'zoom', 1)
	setShaderProperty('barrel', 'barrel', 0.0)
    --setShaderProperty('barrel', 'angle', 720.0)
	makeSprite('barrelOffset', '', 0, 0) --so i can tween while still having the perlin stuff
	setActorAlpha(0, 'barrelOffset')

    initShader('blur', 'BlurEffect')
    setCameraShader('game', 'blur')
    setCameraShader('hud', 'blur')
    setShaderProperty('blur', 'strength', 0)
end

local perlinX = 0
local perlinY = 0
local perlinZ = 0

local perlinSpeed = 0.5

local perlinXRange = 0.02
local perlinYRange = 0.02
local perlinZRange = 0.5

function updatePost(elapsed)

    perlinX = perlinX + elapsed*math.random()*perlinSpeed
	perlinY = perlinY + elapsed*math.random()*perlinSpeed
	perlinZ = perlinZ + elapsed*math.random()*perlinSpeed
    --local noiseX = perlin.noise(perlinX, 0, 0)
	--trace(perlin(perlinX, 0, 0)*0.1)
    setShaderProperty('barrel', 'x', ((-0.5 + perlin(perlinX, 0, 0))*perlinXRange)+getActorX('barrelOffset'))
	setShaderProperty('barrel', 'y', ((-0.5 + perlin(0, perlinY, 0))*perlinYRange)+getActorY('barrelOffset'))
	setShaderProperty('barrel', 'angle', ((-0.5 + perlin(0, 0, perlinZ))*perlinZRange)+getActorAngle('barrelOffset'))
end
function songStart()
    tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*63, 'cubeInOut')
    tweenShaderProperty('pixel', 'strength', 1, crochet*0.001*64, 'backIn')
end

local beatinSteps = {256,268,276,284,288,300,308,316,320,332,340,348,352,364,372,380,384,396,404,412,416,428,436,444,448,460,468,476,480,492,500,508,512,524,536,540,544,556,576,588,600,604,608,620,640,652,664,668,672,684,704,716,728,732,736,748,768,780,788,796,800,812,820,828,832,844,852,860,864,876,884,892,896,908,916,924,928,940,948,956,960,972,980,988,992,1004,1012,1020,1024,1036,1064,1088,1100,1128,1152,1164,1192,1216,1228,1256,1344,1356,1368,1372,1376,1388,1408,1420,1432,1436,1440,1452,1472,1484,1496,1500,1504,1516,1536,1548,1560,1564,1568,1580,1600,1612,1620,1628,1632,1644,1652,1660,1664,1676,1684,1692,1696,1708,1716,1724,1728,1740,1748,1756,1760,1772,1780,1788,1792,1804,1812,1820,1824,1836,1844,1852,1856,1868,1880,1884,1888,1900,1920,1932,1944,1948,1952,1964,1984,1996,2008,2012,2016,2028,2048,2060,2072,2076,2080,2092,2112,2124,2132,2140,2144,2156,2164,2172,2176,2188,2196,2204,2208,2220,2228,2236,2240,2252,2260,2268,2272,2284,2292,2300,2304,2316,2324,2332,2336,2348,2356,2364,2368,2380,2392,2396,2400,2412,2432,2444,2456,2460,2464,2476,2496,2508,2520,2524,2528,2540,2560,2572,2584,2588,2592,2604}
local beatInMore = {}
function stepHit()

    for i = 1,#beatinSteps do 
        if curStep == beatinSteps[i]-1 then 
            tweenShaderProperty('barrel', 'zoom', 0.8, crochet*0.001, 'cubeIn')
            setShaderProperty('blur', 'strength', 2)
            tweenShaderProperty('blur', 'strength', 0, crochet*0.001*4, 'expoIn')
        elseif curStep == beatinSteps[i] then 
            tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*3.8, 'cubeOut')
        end
    end
    for i = 1,#beatInMore do 
        if curStep == beatInMore[i]-1 then 
            tweenShaderProperty('barrel', 'zoom', 0.75, crochet*0.001, 'cubeIn')
        elseif curStep == beatInMore[i] then 
            tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*1.8, 'cubeOut')
            --triggerEvent("add camera zoom", 0.13, 0.13)
        end
       
    end

    if curStep == 112 then 
        tweenShaderProperty('greyscale', 'strength', 0, 0.8, 'cubeOut')
    elseif curStep == 484 then 
        tweenShaderProperty('greyscale', 'strength', 1, 0.45, 'backIn')
    elseif curStep == 512 then 
        tweenShaderProperty('greyscale', 'strength', 0, 0.001, 'backIn')
    elseif curStep == 752 then 
        tweenShaderProperty('greyscale', 'strength', 1, 0.8, 'backIn')
    elseif curStep == 768 then 
        tweenShaderProperty('greyscale', 'strength', 0, 0.001, 'backIn')
    elseif curStep == 1008 then 
        tweenShaderProperty('greyscale', 'strength', 1, 0.8, 'backIn')
    elseif curStep == 1024 then 
        tweenShaderProperty('greyscale', 'strength', 0, 0.001, 'backIn')
    elseif curStep == 1252 then 
        tweenShaderProperty('greyscale', 'strength', 1, 0.5, 'backIn')
    elseif curStep == 1280 then 
        tweenShaderProperty('greyscale', 'strength', 0, 3.2, 'backIn')
    elseif curStep == 2340 then 
        tweenShaderProperty('greyscale', 'strength', 1, 0.5, 'backIn')
    elseif curStep == 2368 then 
        tweenShaderProperty('greyscale', 'strength', 0, 0.001, 'backIn')
    elseif curStep == 2608 then 
        tweenShaderProperty('greyscale', 'strength', 1, 0.8, 'backIn')
    elseif curStep == 2624 then 
        tweenShaderProperty('greyscale', 'strength', 0, 0.001, 'backIn')
    end
end

function playerTwoSing(data, time, type)
    if getHealth() - 0.008 > 0.09 then
        setHealth(getHealth() - 0.008)
    else
        setHealth(0.035)
    end
end