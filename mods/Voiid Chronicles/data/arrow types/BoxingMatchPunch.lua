local ang = {90, 0, 180, -90}
function createPost()
	local noteCount = getUnspawnNotes()
    for i = 0,noteCount-1 do 
        local nt = getUnspawnedNoteNoteType(i)
        local st = getUnspawnedNoteStrumtime(i)
        if not getUnspawnedNoteSustainNote(i) then 
			if nt == 'BoxingMatchPunch' then 
				local d = getSingDirectionID(getUnspawnedNoteNoteData(i))
				setUnspawnedNoteAngle(i, ang[d+1])
			end
        end
		if nt == 'BoxingMatchPunch' then 
			setUnspawnedNoteSingAnimPrefix(i, 'dodge')
		end
    end
end