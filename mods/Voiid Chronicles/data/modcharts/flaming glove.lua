function start(song)
	triggerEvent('Add Camera Zoom','0.20','0')
	if not middlescroll then
		for i = 0,3 do
			tweenPosOut(0,80,getActorY(i),1) 
			tweenPosOut(1,192,getActorY(i),1)
			tweenPosOut(2,972,getActorY(i),1)
			tweenPosOut(3,1085,getActorY(i),1)
			setActorAlpha(0.3,i)
		end
		for i = 4,7 do
			tweenPosOut(4,420,getActorY(i),1)
			tweenPosOut(5,532,getActorY(i),1)
			tweenPosOut(6,644,getActorY(i),1)
			tweenPosOut(7,756,getActorY(i),1)
		end
	end
end

function update(elapsed)
	if curStep == 512 then --psych midscroll on
        if not middlescroll then
            for i = 0,1 do
                tweenPosOut(0,-1180,getActorY(i),1) 
                tweenPosOut(1,-1192,getActorY(i),1)
            end
        end
    end
	if curStep == 514 then --psych midscroll on
        if not middlescroll then
            for i = 2,3 do
                tweenPosOut(2,1972,getActorY(i),1)
                tweenPosOut(3,2085,getActorY(i),1)
            end
        end
    end
	if curStep == 1296 then --tween to default
        if not middlescroll then
            for i = 0,7 do
                tweenPosOut(i,_G['defaultStrum'..i..'X'],_G['defaultStrum'..i..'Y'],1.5)
                setActorAlpha(1,i)
            end
        end
    end
	if curStep == 1408 then --force middlescroll tween
        if not middlescroll then
            for i = 0,3 do
                tweenPosOut(0,-1420,getActorY(i),1)
                tweenPosOut(1,-1532,getActorY(i),1)
                tweenPosOut(2,-1644,getActorY(i),1)
                tweenPosOut(3,-1756,getActorY(i),1)
                setActorAlpha(0.3,i)
            end
            for i = 4,7 do
                tweenPosOut(4,1420,getActorY(i),1)
                tweenPosOut(5,1532,getActorY(i),1)
                tweenPosOut(6,1644,getActorY(i),1)
                tweenPosOut(7,1756,getActorY(i),1)
            end
        end
    end
end

function stepHit(curStep)
	if cutStep == 192 then
		triggerEvent('Set Camera Zoom','1','1')
	end

	if cutStep == 256 then
		triggerEvent('Set Camera Zoom','1.1','1')
	end

	if cutStep == 288 then
		triggerEvent('Set Camera Zoom','0.8','1')
	end

	if curStep == 512 then
		triggerEvent('Set Camera Zoom','0.9','1')
	end

	if curStep == 514 then
		triggerEvent('Set Camera Zoom','1','1')
	end

	if curStep == 640 then
		triggerEvent('Set Camera Zoom','0.8','1')
        triggerEvent('Camera Flash','#FFFFFF','1')
		showOnlyStrums = false
	end

	if curStep == 896 then
		triggerEvent('Camera Flash','#FFFFFF','1')
	end
end