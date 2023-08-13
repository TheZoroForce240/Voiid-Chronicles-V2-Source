local ang = {90, 0, 180, -90}
function createPost()
	local noteCount = getUnspawnNotes()
    for i = 0,noteCount-1 do 
        local nt = getUnspawnedNoteNoteType(i)
        local st = getUnspawnedNoteStrumtime(i)
        if not getUnspawnedNoteSustainNote(i) then 
			if nt == 'Wiik3Punch' then 
				local d = getSingDirectionID(getUnspawnedNoteNoteData(i))
				setUnspawnedNoteAngle(i, ang[d+1])
			end
        end
		if nt == 'Wiik3Punch' then 
			setUnspawnedNoteSingAnimPrefix(i, 'dodge')
		end
    end
end
local doChrom = true
function create()
	
	local blackListedSongs = 
	{
		'final destination', --dont use on fd (god) because its too distracting
		'king hit'
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
function playerOneSing(data, time, noteType) --the
	
	
	if noteType == 'Wiik3Punch' then
		--playCharacterAnimation('boyfriend', 'dodge', true)		
		if doChrom then 
			triggerEvent('ca burst', '0.007', '0.01')
		end
	end
end