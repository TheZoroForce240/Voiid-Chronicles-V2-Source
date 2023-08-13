local currentSong = ""
function switchSpamSong(s)
    currentSong = s
    if currentSong == "Fisticuffs" then 
        playCharacterAnimation('dad', 'destrans', true)
    end
end
local forcePowerup = false
function stepHit()
    if currentSong == "Boxing Match" then 
        if curBeat == 1000 then 
            setCharacterShouldDance('dad', false)
            playCharacterAnimation('dad', 'trans', true)
        elseif curBeat == 1008 then 
            setCharacterShouldDance('dad', true)
        elseif curBeat == 1004 then 
            flashCamera('game', '#B700ff', crochet/100)
            triggerEvent('screen shake', ((crochet/1000)*8)..',0.02', '0,0')
        end
    end
    if currentSong == "TKO" then 
        if curBeat == 376 then 
            setCharacterShouldDance('dad', false)
            playCharacterAnimation('dad', 'trans', true)
        elseif curBeat == 384 then 
            setCharacterShouldDance('dad', true)
            forcePowerup = true
        elseif curBeat == 380 then 
            flashCamera('game', '#B700ff', crochet/100)
            triggerEvent('screen shake', ((crochet/1000)*8)..',0.02', '0,0')
        end
    end

end
function update(elapsed)
    if forcePowerup then 
        setProperty('', 'altAnim', '-alt')
    end
end
