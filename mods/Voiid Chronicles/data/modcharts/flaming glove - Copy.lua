 -- this gets called starts when the level loads.
 function setDefault(id)
    _G['defaultStrum'..id..'X'] = getActorX(id)
end


function start(song) -- arguments, the song name
    if middlescroll == false then
        for i=0,3 do -- fade out the first 4 receptors (the ai receptors)
        tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 1000,getActorAngle(i) + 1000, 0.5, 'setDefault')
        end
        for i = 4, 7 do -- go to the center
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 300,getActorAngle(i) + 360, 0.5, 'setDefault')
        end
	end
end

function stepHit(curStep)
     if curStep == 1 then  
        for i = 0, 3 do 
			tweenFadeOut(i, 0.5, (crochet/1000)*32)
		end