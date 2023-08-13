function onEvent(name, position, argument1, argument2)
    if string.lower(name) == "toggle bg dim off" then
        tweenFadeOut("bgdim", 0, 0.5, destroySprite('bgdim'))
    end
end