
local doChrom = true
function create()
	
	local blackListedSongs = 
	{
		'final destination' --dont use on fd (god) because its too distracting
	} 

	for i = 0,#blackListedSongs-1 do 
		if songLower == blackListedSongs[i+1] then 
			doChrom = false
		end
	end
	if doChrom then 
		triggerEvent('ca burst', '0', '') --make sure its loaded
	end
	
end
function createPost()
	local noteCount = getUnspawnNotes()
    for i = 0,noteCount-1 do 
        local nt = getUnspawnedNoteNoteType(i)
		if nt == 'RevSword' then 
			setUnspawnedNoteSingAnimPrefix(i, 'dodge')
		end
    end
end
function playerOneSing(data, time, noteType) --the
	if noteType == 'RevSword' then
		if doChrom then 
			triggerEvent('ca burst', '0.007', '0.01')
		end
	end
end