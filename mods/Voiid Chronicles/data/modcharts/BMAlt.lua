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

local beatinSteps = {128,140,152,176,184,192,204,216,256,268,280,288,300,312,320,332,344,352,364,376,384,396,408,416,428,440,448,460,472,480,492,504,512,524,536,544,556,568,576,588,600,608,620,632,640,652,664,672,684,696,704,716,728,736,748,760,768,780,792,800,812,824,832,844,856,864,876,888,896,908,920,928,940,952,960,972,984,992,1004,1016,1024,1036,1048,1056,1068,1080,1088,1100,1112,1120,1132,1144,1152,1164,1176,1184,1196,1208,1216,1228,1240,1248,1260,1272,1280,1292,1300,1308,1324,1336,1344,1364,1376,1388,1400,1408,1420,1428,1436,1452,1464,1472,1492,1504,1516,1528,1536,1548,1556,1564,1580,1592,1600,1620,1632,1644,1656,1664,1676,1684,1692,1708,1720,1728,1748,1760,1772,1784,1868,1880,1888,1900,1912,1920,1932,1944,1952,1964,1976,1984,1996,2008,2016,2028,2040,2048,2060,2072,2080,2092,2104,2112,2124,2136,2144,2156,2168,2176,2188,2200,2208,2220,2232,2240,2252,2264,2272,2284,2296,2304,2316,2328,2368,2380,2388,2396,2400,2412,2420,2428,2432,2444,2452,2460,2464,2476,2484,2492,2496,2508,2516,2524,2528,2540,2548,2556,2560,2572,2580,2588,2592,2604,2612,2620,2624,2636,2644,2652,2656,2668,2676,2684,2688,2700,2708,2716,2720,2732,2740,2748,2752,2764,2772,2780,2784,2796,2804,2812,2816,2828,2836,2844,2848,2860,2868,2876,2944,2956,2968,2976,2988,3000,3008,3020,3032,3040,3052,3064,3072,3084,3096,3104,3116,3128,3136,3148,3160,3168,3180,3192,3200,3212,3224,3232,3244,3256,3264,3276,3288,3296,3308,3320,3328,3340,3352,3360,3372,3384,3392,3404,3416,3424,3436,3448}
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

    if curStep == 84 then 
        tweenShaderProperty('greyscale', 'strength', 0.5, 0.5, 'cubeOut')
    elseif curStep == 120 then 
        tweenShaderProperty('greyscale', 'strength', 0, 0.3, 'cubeOut')
    elseif curStep == 1088 then 
        tweenShaderProperty('pixel', 'strength', 6.0, 0.001, 'backIn')
    elseif curStep == 1104 then 
        tweenShaderProperty('pixel', 'strength', 1, 0.001, 'backIn')
    elseif curStep == 1112 then 
        tweenShaderProperty('pixel', 'strength', 6.0, 0.001, 'backIn')
    elseif curStep == 1124 then 
        tweenShaderProperty('pixel', 'strength', 1, 0.001, 'backIn')
    elseif curStep == 1220 then 
        tweenShaderProperty('greyscale', 'strength', 1, 0.5, 'backIn')
    elseif curStep == 1280 then 
        tweenShaderProperty('greyscale', 'strength', 0, 0.001, 'backIn')
    elseif curStep == 1792 then 
        tweenShaderProperty('greyscale', 'strength', 1, 0.001, 'backIn')
    elseif curStep == 1848 then 
        tweenShaderProperty('greyscale', 'strength', 0, 0.34, 'backIn')
        tweenShaderProperty('barrel', 'zoom', 0.8, 0.34, 'cubeIn')
        if not opponentPlay then 
            tweenActorProperty('barrelOffset', 'angle', 360, 0.34, 'cubeInOut')
        end
        
    elseif curStep == 1856 then 
        tweenShaderProperty('barrel', 'zoom', 1, crochet*0.001*3.8, 'cubeOut')
        setActorAngle(0, 'barrelOffset')
    elseif curStep == 2352 then 
        tweenShaderProperty('greyscale', 'strength', 1, 0.65, 'backIn')
    elseif curStep == 2368 then 
        tweenShaderProperty('greyscale', 'strength', 0, 0.001, 'backIn')
    elseif curStep == 2864 then 
        tweenShaderProperty('greyscale', 'strength', 0.5, 0.001, 'backIn')
    elseif curStep == 2928 then 
        tweenShaderProperty('greyscale', 'strength', 1, 0.65, 'backIn')
    elseif curStep == 2944 then 
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