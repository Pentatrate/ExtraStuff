config = extrasavedata

local function versionCheck(version, actualversion)
	local function splitVersion(v)
		local t = {}
		for part in string.gmatch(v, "[^%.]+") do
			t[#t+1] = tonumber(part) or 0
		end
		return t
	end

	local v1 = splitVersion(version)
	local v2 = splitVersion(actualversion)

	local maxLen = math.max(#v1, #v2)

	for i = 1, maxLen do
		local a = v1[i] or 0
		local b = v2[i] or 0

		if a > b then
			return 1
		elseif a < b then
			return -1
		end
	end

	return 0
end

imgui.Separator()

seeUnfinished = seeUnfinished or false

if config then
	seeUnfinished = helpers.InputBool("See Unfinished Options", (seeUnfinished or false))

	if seeUnfinished then
		if imgui.Button("Chimaera Fight") then
			cs:loadMainMenu()
			cs.chimaera = true
			
			if savedata.options.game.customCursorInMenu
			and (savedata.options.game.cursorMode ~= "default") then
				love.mouse.setVisible(false)
			end
		end
		if imgui.Button("Blow A Fuse Transition") then
			local state = bs.load('BlowAFuseIntro')
			cs.rateMod = 1
			state:init()
		end
		--_G.seeBAFintro = helpers.InputBool("See Blow A Fuse Intro on next Results", (_G.seeBAFintro or false))
		config.coydressReplaceFoxy = helpers.InputBool("Coydress Instead of Foxy", (config.coydressReplaceFoxy or false))
		config.alwaysLoadWorkshop = helpers.InputBool("Always load workshop", (config.alwaysLoadWorkshop or true))
		config.showTags = helpers.InputBool("Show Generated Tags for Levels", (config.showTags or false))
		config.playingCrank = helpers.InputBool("BotCranky Plays", (config.playingCrank or false))
		
		imgui.Text("Chimaera Fight - not done?\nCoydress Instead of Foxy - does nothing\nAlways Load Workshop - not sure if possible\nShow Gen. Tags - works but I don't know \nhow to implement it yet\nBotCraanky Plays - real time cranking (no mines)")
	end
	
	imguiextra.LabeledSeparator("Main Menu", 1)
	
	if imgui.Button("Edit Main Menu") then
		cs:loadMainMenu()
		cs.editMenu = true

		-- return to ingame cursor if the settings say so
		if savedata.options.game.customCursorInMenu
		and (savedata.options.game.cursorMode ~= "default") then
			love.mouse.setVisible(false)
		end
	end
	imgui.SameLine()
	config.randomizeMenuOnStart = helpers.InputBool("Randomize Menu On Start", (config.randomizeMenuOnStart or false))
	imgui.Text("Press F9 to edit the menu if Mods is hidden.")
	config.splashText = helpers.InputBool("Splash Text", (config.splashText or false))
	config.splashTextLeft = helpers.InputBool("Move Splash Text to Left", (config.splashTextLeft or false))
	
	imguiextra.LabeledSeparator("Songselect", 1)
	
	if not config.chartinfoplus then
		config.chartinfoplus = helpers.copy(extraDefaultSave.chartinfoplus)
	end
	config.chartinfoplus.enabled = helpers.InputBool("More Chart Info", (config.chartinfoplus.enabled or false))
	if config.chartinfoplus.enabled then
		config.chartinfoplus.levelLength = helpers.InputBool("Show Level Length", (config.chartinfoplus.levelLength or false))
		config.chartinfoplus.fullCombo = helpers.InputBool("Show Full Combo", (config.chartinfoplus.fullCombo or false))
		imgui.Separator()
	end
	
	config.openDemoLevelWarning = helpers.InputBool("Editing Demo Warning", (config.openDemoLevelWarning or false))

	config.randomLevelButton = helpers.InputBool("Random Level Picker (Press R)", (config.randomLevelButton or false))
	config.allowRandomLevelFolder = helpers.InputBool("Allow Entering Folder for Random Level", (config.allowRandomLevelFolder or false))
	
	imguiextra.LabeledSeparator("In Game", 1)
	
	if type(config.randomSongs) == "nil" then
		config.randomSongs = true
	end
	config.randomSongs = helpers.InputBool("Allow Random Song", (config.randomSongs or false))
	
	config.showAccessibility = helpers.InputBool("Show Accessibility", (config.showAccessibility or false))
	config.showAccessibilityOnPause = helpers.InputBool("Only Show Accessibility on Pause", (config.showAccessibilityOnPause or false))

	local positions = {"topLeft", "topRight", "bottomLeft", "bottomRight"}

	if imgui.BeginCombo("Accessibility Position", config.accessibilityPos) then
        for i, v in ipairs(positions) do
            local isSelected = (v == config.accessibilityPos)
            if imgui.Selectable_Bool(v, isSelected) then
                config.accessibilityPos = v
            end
        end
        imgui.EndCombo()
    end 
	
	if not config.allowedEases then
		config.allowedEases = {}
	end
	
	imguiextra.drawStringList(
		"Allowed Eases in No VFX:",
		config.allowedEases,
		{
			inputWidth = 200, addText = " + ", removeText = " - "
		}
	)
	
	imguiextra.LabeledSeparator("Fishing", 1)
	
	if type(config.replayFish) == 'nil' then config.replayFish = true end
	config.replayFish = helpers.InputBool("Replay Fish Dialogue", (config.replayFish or false))
	config.fishingBookText = helpers.InputBool("Book Texture", (config.fishingBookText or false))
	
	--local fishPerPageBuf = ffi.new("int[1]", config.fishPerPage or 4)

	--if imgui.InputInt("Fish Per Page", fishPerPageBuf) then
	--	config.fishPerPage = helpers.clamp(fishPerPageBuf[0], 1, 16)
	--end
	config.fishPerPage = helpers.clamp(imguiextra.IntInput("Fish Per Page", config.fishPerPage or 4), 1, 16)
	
	imguiextra.LabeledSeparator("Fun Stuff", 1)
	imguiextra.LabeledSeparator("-  Arrow Keys", 1)
	
	config.arrowKeyControls = helpers.InputBool("Arrow Key Controls", (config.arrowKeyControls or false))
	config.onlyArrowKeys = helpers.InputBool("Only Arrow Key Controls", (config.onlyArrowKeys or false))
	
	imguiextra.LabeledSeparator("-  Cranky Moves Towards the Mouse", 1)
	
	config.movesTowardsMouse = helpers.InputBool("Cranky Moves Towards the Mouse", (config.movesTowardsMouse or false))
	config.moveToRadiusCranky = helpers.InputFloat("Distance Cranky Stops", (config.moveToRadiusCranky or 25))
	config.crankySpeedToMouse = helpers.InputFloat("Cranky Time to Reach Mouse", (config.moveToRadiusCranky or 5))
	
	imguiextra.LabeledSeparator("-  Foxy Jumpscare", 1)
	
	config.foxyJumpscare = helpers.InputBool("Do Jumpscare", (config.foxyJumpscare or false))
	config.foxyJumpscareChance = helpers.InputFloat("Chance (in Percent)", (config.foxyJumpscareChance or 0.1))

	imguiextra.LabeledSeparator("-  Ads", 1)
	
	config.robloxAds = helpers.InputBool("Ads on the sides", (config.robloxAds or false))
	imgui.Text("ads are made by noob_y")
	
	imguiextra.LabeledSeparator("-  Modifiers", 1)
	
	config.alwaysNegativeSC = helpers.InputBool("Always Negative Scrollspeed", (config.alwaysNegativeSC or false))
	
	config.allInverse = helpers.InputBool("All Inverses", (config.allInverse or false))
	--config.allMine = helpers.InputBool("All Mines", (config.allMine or false))
	config.allTap = helpers.InputBool("All Taps", (config.allTap or false))
	
	imguiextra.LabeledSeparator("Extra Configs", 1)

	config.extraConfigOtherMods = helpers.InputBool("Extra Config for Other Mods?", (config.extraConfigOtherMods or false))
	
	if config.extraConfigOtherMods then
		if mods["DetailedAcc"] then
			if imgui.CollapsingHeader_TreeNodeFlags("Detailed Accuracy by TGTM") then
				config.detailedacc = config.detailedacc or {}
				if versionCheck(mods["DetailedAcc"].version, "2.0.0") >= 0 then
					if type(config.detailedacc.moveTapDisplayLeft) == "boolean" then
						mods["DetailedAcc"].config.KeyPressesRight = not config.detailedacc.moveTapDisplayLeft
						config.detailedacc.moveTapDisplayLeft = nil
					end
				else
					config.detailedacc.moveTapDisplayLeft = helpers.InputBool("Move the Tap Display to the Left", (config.detailedacc.moveTapDisplayLeft or false))
				end
				config.detailedacc.moveTapErrorMeterTop = helpers.InputBool("Move the Tap Error Meter to the Top", (config.detailedacc.moveTapErrorMeterTop or false))
				
				local positions = {"topLeft", "topRight", "bottomLeft", "bottomRight"}
				
				if imgui.BeginCombo("Section Timer Position", config.detailedacc.sectionTimerPos) then
					for i, v in ipairs(positions) do
						local isSelected = (v == config.detailedacc.sectionTimerPos)
						if imgui.Selectable_Bool(v, isSelected) then
							config.detailedacc.sectionTimerPos = v
						end
					end
					imgui.EndCombo()
				end 
			end
		end
	end
	
	imgui.Separator()
	dpf.saveJson("savedata/extraMod.sav", extrasavedata)
else
	imgui.Text("ENABLE TO SEE CONFIGS!")
end
