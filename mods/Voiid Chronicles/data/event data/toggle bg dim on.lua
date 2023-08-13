local dimToggled = false
function onEvent(name, position, argument1, argument2)
    if string.lower(name) == "toggle bg dim on" then
        dimToggled = not dimToggled
        makeSprite('bgdim', '', -500, -500);
        makeGraphic('bgdim', 3000, 2000, '0xFF000000')
        setActorScroll(0, 0, 'bgdim');
        setActorAlpha(0, 'bgdim')
        tweenFadeIn("bgdim", 0.5, 0.5)
    end
end