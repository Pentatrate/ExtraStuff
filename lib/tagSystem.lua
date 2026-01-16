tags = {}
tags.UndoneTags = {"Difficulty"}

tags.vfxevents = {
	ease = true, 
	setBoolean = true, 
	setCol = true, 
	setBgCol = true, 
	easeSequence = true,
	songNameOverride = true,
	aft = true,
	advancetextdeco = true,
	deco = true,
	forcePlayerSprite = true,
	hom = true,
	loadCustomFont = true,
	noise = true,
	outline = true,
	playSound = true,
	setJoystickColor = true,
	textdeco = true,
	initobject = true,
	multiPulse = true,
	playMidi = true,
	setBG = true,
	videoBG = true,
	singlePulse = true,
	forceMidiNote = true,
	shader_uniform = true,
	shader_background = true,
	ParallaxBackground = true
}

function tags.modifierFromRatio(r, canOnly)
	if r >= 1 and canOnly then return "Only" end
	if r == 0 then return "No" end
	if r < 0.05 then return "Minimal" end
	if r < 0.15 then return "Low" end
	if r < 0.30 then return "Medium" end
	if r < 0.50 then return "High" end
	return "Extreme"
end

function tags.scrollSpeedModifier(number)
	if number < 30 then return "Very Low" end
	if number < 50 then return "Low" end
	if number < 90 then return "Normal" end
	if number < 110 then return "High" end
	if number < 130 then return "Very High" end
	return "Extreme"
end

function tags.addTag(out, mod, name)
	if mod ~= "" then
		table.insert(out, mod .. " " .. name)
	else
		table.insert(out, name)
	end
end

function tags.generateTags(leveldata, testSave)
    local returnedTags = {}
    
    local maxTime = 0
    local endBeat = 0
    local count = {
        blocks = 0,
        mines = 0,
        holds = 0,
        mineholds = 0,
        traces = 0,
        sides = 0,
        bounces = 0,
        inverses = 0,
        taps = 0
    }
    local vfxnum = 0
    local jumpBeatableNotes = {}
    
    local BPMs = {}
    local scrollSpeeds = {}
    local objectRotations = {}
    local noteTimes = {}
    local editsPaddle = false
    local damoclismGimmick = false
    
    -- process events
    for i, ev in ipairs(leveldata.events) do
        if ev.time and ev.time > maxTime then
            maxTime = ev.time
        end
		
		if ev.objectName == "Damoclism" then
			damoclismGimmick = true
			goto continue
		end
        
        if ev.var then
            if ev.var == "scrollSpeed" then
                table.insert(scrollSpeeds, {time = ev.time, value = ev.value})
            elseif ev.var == "objectRotation" then
                table.insert(objectRotations, ev.value)
            end
        end
    
        if tags.vfxevents[ev.type] then
            vfxnum = vfxnum + 1
            goto continue
        end
        
		if ev.type == "paddles" then
            editsPaddle = true
            goto continue
        end
		
        if ev.type == "showResults" then
            endBeat = ev.time
            goto continue
        end
        
        if ev.type == "play" or ev.type == "setBPM" then
            table.insert(BPMs, ev.bpm)
            goto continue
        end
        
        if ev.type == "extraTap" or ev.tap or ev.endTap
            or ev.type == "block"
            or ev.type == "mine"
            or ev.type == "inverse"
            or ev.type == "hold"
            or ev.type == "mineHold"
            or ev.type == "bounce"
            or ev.type == "side"
        then
            table.insert(noteTimes, ev.time)
            if ev.type == "block" or ev.type == "hold" or ev.type == "inverse" or ev.type == "bounce" then
                table.insert(jumpBeatableNotes, {
                    time = ev.time,
                    angle = ev.angle
                })
            end
        end
        
        if ev.type == "extraTap" or ev.tap or ev.endTap then
            count.taps = count.taps + 1
        end
        if ev.type == "block" then
            count.blocks = count.blocks + 1
            goto continue
        end
        if ev.type == "mine" then
            count.mines = count.mines + 1
            goto continue
        end
        if ev.type == "inverse" then
            count.inverses = count.inverses + 1
            goto continue
        end
        if ev.type == "hold" then
            count.holds = count.holds + 1
            goto continue
        end
		if ev.type == "trace" then
            count.traces = count.traces + 1
            goto continue
        end
        if ev.type == "mineHold" then
            count.mineholds = count.mineholds + 1
            goto continue
        end
        if ev.type == "bounce" then
            count.bounces = count.bounces + 1
            goto continue
        end
        if ev.type == "side" then
            count.sides = count.sides + 1
            goto continue
        end
        
        ::continue::
    end
    
    endBeat = endBeat > 0 and endBeat or maxTime or 1
    
    -- calculations
	
    local scrollMin, scrollMax, scrollAvg = nil, nil, 0
    local scrollTotalTime = 0
    table.sort(scrollSpeeds, function(a,b) return a.time < b.time end)
    
    for i, spd in ipairs(scrollSpeeds) do
        local startTime = spd.time or 0
        local duration = 0
        
        if i < #scrollSpeeds then
            duration = scrollSpeeds[i+1].time - startTime
        else
            duration = endBeat - startTime
        end
        duration = math.max(duration, 0)
        
        scrollAvg = scrollAvg + spd.value * duration
        scrollTotalTime = scrollTotalTime + duration
        
        scrollMin = scrollMin and math.min(scrollMin, spd.value) or spd.value
        scrollMax = scrollMax and math.max(scrollMax, spd.value) or spd.value
    end
    
    if scrollTotalTime > 0 then
        scrollAvg = scrollAvg / scrollTotalTime
    end
    
    local ttlNotes = 0
    local gpNotes = 0
    for _, num in pairs(count) do ttlNotes = ttlNotes + num end
    gpNotes = ttlNotes - count.traces
    
    local avgBPM = 0
    for _, num in pairs(BPMs) do avgBPM = avgBPM + num end
    avgBPM = #BPMs > 0 and (avgBPM / #BPMs) or 100
    
    table.sort(jumpBeatableNotes, function(a, b) return a.time < b.time end)
    
    local maxJumpTime = 1
    local minAngleDiff = 50
    local function angleDiff(a, b)
        local diff = math.abs(a - b) % 360
        return diff > 180 and (360 - diff) or diff
    end
    
    local jumpbeatTime = 0
    local activeTime = 0
    for i = 2, #jumpBeatableNotes do
        local dt = jumpBeatableNotes[i].time - jumpBeatableNotes[i-1].time
        if dt > 0 then
            activeTime = activeTime + dt
            local da = angleDiff(jumpBeatableNotes[i].angle, jumpBeatableNotes[i-1].angle)
            if dt <= maxJumpTime and da >= minAngleDiff then
                jumpbeatTime = jumpbeatTime + dt
            end
        end
    end
    
    local jumpbeatRatio = activeTime > 0 and (jumpbeatTime / activeTime) or 0
    
    table.sort(noteTimes)
    local avgNoteDist = nil
    if #noteTimes >= 2 then
        local totalDist = 0
        for i = 2, #noteTimes do
            totalDist = totalDist + (noteTimes[i] - noteTimes[i-1])
        end
        avgNoteDist = totalDist / (#noteTimes - 1)
    end
    
    local isScrollVaried = false
    if scrollMin and scrollMax and scrollAvg > 0 then
        isScrollVaried = (scrollMax - scrollMin) / scrollAvg > 0.15
    end
    
    if gpNotes > 0 then
        tags.addTag(returnedTags, tags.modifierFromRatio(count.mines/gpNotes, true), "Mines")
        tags.addTag(returnedTags, tags.modifierFromRatio(count.holds/gpNotes, true), "Holds")
        tags.addTag(returnedTags, tags.modifierFromRatio(count.mineholds/gpNotes, true), "MineHolds")
        tags.addTag(returnedTags, tags.modifierFromRatio(count.blocks/gpNotes, true), "Blocks")
        tags.addTag(returnedTags, tags.modifierFromRatio(count.sides/gpNotes, true), "Sides")
        tags.addTag(returnedTags, tags.modifierFromRatio(count.bounces/gpNotes, true), "Bounces")
        tags.addTag(returnedTags, tags.modifierFromRatio(count.inverses/gpNotes, true), "Inverses")
        tags.addTag(returnedTags, tags.modifierFromRatio(count.taps/gpNotes, true), "Taps")
		if avgNoteDist then
			tags.addTag(returnedTags, tags.modifierFromRatio(1/(4*avgNoteDist), false), "Note Density")
		else
			tags.addTag(returnedTags, "Literaly", "One Note")
		end
        tags.addTag(returnedTags, tags.modifierFromRatio(jumpbeatRatio, false), "Jumpbeats")
    else
        tags.addTag(returnedTags, "No", "Gameplay")
    end
	if ttlNotes > 0 then
		tags.addTag(returnedTags, tags.modifierFromRatio(count.traces/ttlNotes, true), "Traces")
	end
    
    local vfxRatio = vfxnum / (endBeat * 2)
    tags.addTag(returnedTags, tags.modifierFromRatio(vfxRatio, false), "VFX")
    
    local lvlLen = (endBeat / avgBPM) * 60
    if lvlLen <= 60 then tags.addTag(returnedTags, "Tiny", "Length")
    elseif lvlLen <= 120 then tags.addTag(returnedTags, "Small", "Length")
    elseif lvlLen <= 180 then tags.addTag(returnedTags, "Medium", "Length")
    elseif lvlLen <= 240 then tags.addTag(returnedTags, "Big", "Length")
    elseif lvlLen <= 300 then tags.addTag(returnedTags, "Large", "Length")
    else tags.addTag(returnedTags, "Insane", "Length") end
    
    if #BPMs > 1 then tags.addTag(returnedTags, "Varied", "BPM")
    else tags.addTag(returnedTags, "Static", "BPM") end
    
    if scrollAvg > 0 then
        tags.addTag(returnedTags, tags.scrollSpeedModifier(scrollAvg * (leveldata.properties.speed or 70)), "Scroll Speed")
        if isScrollVaried then
            tags.addTag(returnedTags, "Varied", "Scroll Speed")
        else
			tags.addTag(returnedTags, "Static", "Scroll Speed")
		end
    end
	
	if #objectRotations == 0 then
		tags.addTag(returnedTags, "No", "Object Rotation")
	elseif #objectRotations < 0.01 * endBeat then
		tags.addTag(returnedTags, "Minimal", "Object Rotation")
	elseif #objectRotations < 0.05 * endBeat then
		tags.addTag(returnedTags, "Some", "Object Rotation")
	elseif #objectRotations < 0.1 * endBeat then
		tags.addTag(returnedTags, "Low", "Object Rotation")
	elseif #objectRotations < 0.2 * endBeat then
		tags.addTag(returnedTags, "Med", "Object Rotation")
	elseif #objectRotations < 0.4 * endBeat then
		tags.addTag(returnedTags, "High", "Object Rotation")
	elseif #objectRotations < 0.6 * endBeat then
		tags.addTag(returnedTags, "Very High", "Object Rotation")
	elseif #objectRotations < 0.8 * endBeat then
		tags.addTag(returnedTags, "Extreme", "Object Rotation")
	else
		tags.addTag(returnedTags, "Unplayable", "Object Rotation")
	end
	
	if damoclismGimmick then tags.addTag(returnedTags, "", "Damoclism Gimmick") end
	if editsPaddle then tags.addTag(returnedTags, "", "Changes Paddle") end
	
	
	if testSave then
		--[[local saveName = LevelManager:getMenuItemSaveName(cs.menuItems[cs.selection], cs:getVariantInfo(cs.menuItems[cs.selection],cs.menuItems[cs.selection].currVariant))
		if cs.playedLevelsJson[saveName] then
			cs.playedLevelsJson[saveName].tags = {}
			cs.playedLevelsJson[saveName].tags.generated = helpers.copytable(returnedTags)
			dpf.saveJson("savedata/playedlevels.json", cs.playedLevelsJson)
			print("tried saving tags")
		end]]
	end
    
    return returnedTags
end

function tags.generateTagFile(leveldata, path)
	local data = ""
	
	local tagList = tags.generateTags(leveldata)
	for _, tag in ipairs(tagList) do
		data = data .. tag .. "\n"
	end
	love.filesystem.write(path, data)
end

return tags