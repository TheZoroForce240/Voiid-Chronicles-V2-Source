function onEvent(name, position, value1, value2)
        if value1 == '1' then 
            if not middlescroll then
                for i = 0,3 do
                    tweenPosOut(0,420,getActorY(i),1) --middlescroll for opponent
                    tweenPosOut(1,532,getActorY(i),1)
                    tweenPosOut(2,644,getActorY(i),1)
                    tweenPosOut(3,756,getActorY(i),1)
                    setActorAlpha(0.3,i)
                end
                for i = 4,7 do
                    tweenPosOut(4,420,getActorY(i),1) --middlescroll for boof
                    tweenPosOut(5,532,getActorY(i),1)
                    tweenPosOut(6,644,getActorY(i),1)
                    tweenPosOut(7,756,getActorY(i),1)
                end
            end
        elseif value2 == '2' then --psych midscroll on
            if not middlescroll then
                for i = 0,3 do
                    tweenPosOut(0,80,getActorY(i),1) 
                    tweenPosOut(1,192,getActorY(i),1)
                    tweenPosOut(2,972,getActorY(i),1)
                    tweenPosOut(3,1085,getActorY(i),1)
                end
            end
        elseif value2 == '3' then --psych midscroll off
            if not middlescroll then
                for i = 0,3 do
                    tweenPosOut(0,420,getActorY(i),1)
                    tweenPosOut(1,532,getActorY(i),1)
                    tweenPosOut(2,644,getActorY(i),1)
                    tweenPosOut(3,756,getActorY(i),1)
                end
            end
        elseif value2 == '4' then --tween to default
            if not middlescroll then
                for i = 0,7 do
                    tweenPosOut(i,_G['defaultStrum'..i..'X'],_G['defaultStrum'..i..'Y'],1)
                    setActorAlpha(1,i)
                end
            end
        end
    end