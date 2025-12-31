config = extrasavedata

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
		imgui.Text("Chimaera Fight - not done\nCoydress Instead of Foxy - does nothing\nAlways Load Workshop - not sure if possible")
	end

	imgui.Separator()
	
	if imgui.Button("Edit Main Menu Options") then
		cs:loadMainMenu()
		cs.reorderMenu = true

		-- return to ingame cursor if the settings say so
		if savedata.options.game.customCursorInMenu
		and (savedata.options.game.cursorMode ~= "default") then
			love.mouse.setVisible(false)
		end
	end
	imgui.SameLine()
	config.randomizeMenuOnStart = helpers.InputBool("Randomize Menu On Start", (config.randomizeMenuOnStart or false))

	imgui.Separator()

	config.showAccessibility = helpers.InputBool("Show Accessibility", (config.showAccessibility or false))
	config.showAccessibilityOnPause = helpers.InputBool("Only Show Accessibility on Pause", (config.showAccessibilityOnPause or false))

	local positions = {"topLeft", "topRight", "bottomLeft", "bottomRight"}

	config.accessibilityPos =
		imguiextra.Dropdown(
			"Accessibility Position:",
			positions,
			config.accessibilityPos or "bottomLeft"
		)

	imgui.Separator()

	config.openDemoLevelWarning = helpers.InputBool("Editing Demo Warning", (config.openDemoLevelWarning or false))

	imgui.Separator()

	config.randomLevelButton = helpers.InputBool("Random Level Picker (Press R)", (config.randomLevelButton or false))
	config.allowRandomLevelFolder = helpers.InputBool("Allow Entering Folder for Random Level", (config.allowRandomLevelFolder or false))
	
	imgui.Separator()
	
	config.arrowKeyControls = helpers.InputBool("Arrow Key Controls", (config.arrowKeyControls or false))
	config.onlyArrowKeys = helpers.InputBool("Only Arrow Key Controls", (config.onlyArrowKeys or false))
	
	imgui.Separator()
	
	config.movesTowardsMouse = helpers.InputBool("Cranky Moves Towards the Mouse", (config.movesTowardsMouse or false))
	config.moveToRadiusCranky = helpers.InputFloat("Distance Cranky Stops", (config.moveToRadiusCranky or 25))
	
	imgui.Separator()
	
	config.foxyJumpscare = helpers.InputBool("Withered Foxy Jumpscare", (config.foxyJumpscare or false))
	config.foxyJumpscareChance = helpers.InputFloat("Chance (in Percent)", (config.foxyJumpscareChance or 0.1))

	imgui.Separator()
	
	config.robloxAds = helpers.InputBool("Ads on the sides", (config.robloxAds or false))
		imgui.Text("ads are made by noob_y")
	
	imgui.Separator()

	config.extraConfigOtherMods = helpers.InputBool("Extra Config for Other Mods?", (config.extraConfigOtherMods or false))
	
	if config.extraConfigOtherMods then
		if mods["DetailedAcc"] then
			if imgui.CollapsingHeader_TreeNodeFlags("Detailed Accuracy by TGTM") then
				config.detailedacc = config.detailedacc or {}
				config.detailedacc.moveTapDisplayLeft = helpers.InputBool("Move the Tap Display to the Left", (config.detailedacc.moveTapDisplayLeft or false))
				config.detailedacc.moveTapErrorMeterTop = helpers.InputBool("Move the Tap Error Meter to the Top", (config.detailedacc.moveTapErrorMeterTop or false))
				
				local positions = {"topLeft", "topRight", "bottomLeft", "bottomRight"}
				config.detailedacc.sectionTimerPos =
					imguiextra.Dropdown(
						"Section Timer Position:",
						positions,
						config.detailedacc.sectionTimerPos or "topLeft"
					)
			end
		end
		
		imgui.Separator()
	end
	
	dpf.saveJson("savedata/extraMod.sav", extrasavedata)
else
	imgui.Text("ENABLE TO SEE CONFIGS!")
end
