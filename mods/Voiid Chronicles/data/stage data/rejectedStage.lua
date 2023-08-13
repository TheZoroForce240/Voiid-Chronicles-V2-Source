local floatShit = 0
local rockY = 0
local bfY = 0
local mattY = 0
function createPost()
	bfY = getActorY('boyfriend')
	mattY = getActorY('dad')
	rockY = getActorY('undefinedSprite3')
end


function update(elapsed)
	floatShit = 150*math.sin(songPos*0.002)
    --setActorX(getActorX('iconP1') + 50, 'boyfriend')
	setActorY(bfY + floatShit, 'boyfriend')
	setActorY(mattY + floatShit, 'dad')
	setActorY(rockY + floatShit, 'undefinedSprite3')
    
end