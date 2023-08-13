local songTable = {
    --song, composer, charter, og song composer

    --Tutorial
    -- :(

    --Wiik 1
    {"Light It Up", "ImPaper", "ScottFlux", "TheOnlyVolume", 6620},
    {"Ruckus", "Singular and Lord Voiid", "Ushear", "TheOnlyVolume", 8170},
    {"Target Practice", "Lord Voiid", "ScottFlux", "TheOnlyVolume"},
    
    --Wiik 2
    {"Burnout", "Lord Voiid", "ScottFlux", ""},
    {"Sporting", "Invalid", "Ushear", "Biddle3"},
    {"Boxing Match", "Lord Voiid", "Official_YS", "TheOnlyVolume", 11330},

    --Matt With Hair
    {"Flaming Glove", "ImPaper", "ScottFlux", ""},

    --Wiik 3
    {"Fisticuffs", "Lord Voiid", "RhysRJJ and Lord Voiid", "HamillUn"},
    {"Blastout", "Revilo", "ScottFlux", ""},
    {"Immortal", "Hippo0824 and Lord Voiid", "RhysRJJ", ""},
    {"King Hit", "Lord Voiid", "ScottFlux and RhysRJJ", "TheOnlyVolume"},
    --{"King Hit Wawa", "Lord Voiid", "Official_YS", "TheOnlyVolume"},
    {"TKO", "Lord Voiid and Invalid", "ScottFlux", "HamillUn and Shteque"},

    --Wiik 100
    {"Mat", "Joa (Inst) and Hippo0824 (Voices)", "ScottFlux", "st4rcannon"},
    {"Banger", "Lord Voiid", "bruvDiego", "st4rcannon"},
    {"Edgy", "Lord Voiid (Voices) and MLOM (Inst)", "RhysRJJ", "st4rcannon", 18460},

    --Extras
    {"Sport Swinging", "Ushear", "ScottFlux", "Biddle3"},
    {"Boxing Gladiators", "Ushear", "RhysRJJ", "TheOnlyVolume"},
    {"Rejected", "Lord Voiid", "Official_YS", "CrazyCake", 11320},
    {"Alter Ego", "Lord Voiid and Revilo", "ScottFlux", ""},
    {"Average Voiid Song", "Fallnnn", "Ushear", ""},    
}
local song = {"Song Not Found", "", "", ""}
function createPost()
    for i = 1,#songTable do 
        if songLower == string.lower(songTable[i][1]) then 
            song = songTable[i]
            --trace(song)
        end
    end

    local songFont = "dumbnerd.ttf"

    makeSprite('songBG', 'songPopupThingy')
    setActorScroll(0,0,'songBG')
    setObjectCamera('songBG', 'hud')
    actorScreenCenter('songBG')
    makeText("songText", song[1], 0, 0, 128)
    setActorFont("songText", songFont)
    setActorScroll(0,0,'songText')
    setObjectCamera('songText', 'hud')
    actorScreenCenter('songText')
    setActorY(getActorY("songText")-15, 'songText')
    local textShit = "Composer: "..song[2].."      Charter: "..song[3]
    if song[4] ~= "" then
        textShit = textShit.."      Original Song: "..song[4]
    end
    --trace(textShit)
    local textSize = 24 
    makeText("extraText", textShit, 0, 0, textSize)
    setActorFont("extraText", "Contb___.ttf")
    setActorScroll(0,0,'extraText')
     setObjectCamera('extraText', 'hud')
    actorScreenCenter('extraText')
    setActorY(getActorY("extraText")+60, 'extraText')
    setActorOutlineColor('extraText', "0xFFFFFFFF")
    setProperty('extraText', 'borderSize', 30)
    setActorOutlineColor('songText', "0xFFFFFFFF")

    --setActorTextColor("songText", "0xFF6A17EB")
    --setActorTextColor("extraText", "0xFF6A17EB")
    setActorTextColor("songText", "0xFF000000")
    setActorTextColor("extraText", "0xFF000000")

    setActorX(getActorX("songBG")+2000, 'songBG')
    setActorX(getActorX("songText")+2000, 'songText')
    setActorX(getActorX("extraText")+2000, 'extraText')
end
local showedPopups = false
function songStart()
    if song[5] == nil then 
        showedPopups = true
        tweenActorProperty("songBG", 'x', getActorX("songBG")-2000, crochet*0.001*8, 'expoOut')
        tweenActorProperty("songText", 'x', getActorX("songText")-2000, crochet*0.001*8, 'expoOut')
        tweenActorProperty("extraText", 'x', getActorX("extraText")-2000, crochet*0.001*8, 'expoOut')
    end
end

local hiddenPopups = false 
local killedPopups = false
function stepHit()
    local delay = 0
    if song[5] ~= nil then  --delay timer thingy
        delay = song[5]
        if songPos > song[5] and not showedPopups then 
            showedPopups = true
            tweenActorProperty("songBG", 'x', getActorX("songBG")-2000, crochet*0.001*8, 'expoOut')
            tweenActorProperty("songText", 'x', getActorX("songText")-2000, crochet*0.001*8, 'expoOut')
            tweenActorProperty("extraText", 'x', getActorX("extraText")-2000, crochet*0.001*8, 'expoOut')
        end
    end
    if songPos > 5000+delay and not hiddenPopups then 
        hiddenPopups = true
        tweenActorProperty("songBG", 'x', getActorX("songBG")-2000, crochet*0.001*4, 'expoIn')
        tweenActorProperty("songText", 'x', getActorX("songText")-2000, crochet*0.001*4, 'expoIn')
        tweenActorProperty("extraText", 'x', getActorX("extraText")-2000, crochet*0.001*4, 'expoIn')
    elseif songPos > 10000+delay and not killedPopups then 
        killedPopups = true 
        destroySprite("songBG")
        destroySprite("songText")
        destroySprite("extraText")
    end
end