--[[local st = Gamestate:new('OldMenu')

st:setInit(function(self)
	em.clear({self.bg})

	shuv.resetPal()
	shuv.pal[2] = {r= 205, g=205, b=205}
	shuv.pal[3] = {r= 255, g=52, b=50}
	shuv.pal[4] = {r= 224, g=227, b=0}
	shuv.pal[5] = {r= 44, g=255, b=57}
	shuv.pal[6] = {r= 0, g=222, b=229}
	shuv.pal[7] = {r= 63, g=38, b=255}
	shuv.showBadColors = true
	self.panEase = nil
	self.x = 1
	self.logoY = 0

	self.animatingout = false
	
	self.tutorialPopup = false
	
	local marathonOffset = 0
	local marathonEnabled = false
	
	local playedLevelsJson = LevelManager:loadPlayedLevels()
	
	marathonEnabled = UnlockManager.isLevelPassed({
		level = "Finished levels/lawrence/",
		percent = 80,
	})
	if marathonEnabled then
		marathonOffset = 1
	end

	cs.blockInteraction = false
	
	self.mainMenu = em.init('RadialList',{allowInput = true, circleWidth = 72})
	self.mainMenu:addOption('playGame',function()
		self.animatingout = true
		self.mainMenu.allowInput = false
		self.mainMenu.updateTransform = false
		flux.to(self, 15, {logoY = -300}):ease("inOutSine")
		flux.to(self.mainMenu, 15, {y = project.res.cy}):ease("inOutSine"):oncomplete(function ()
			cs = bs.load('AtomMap')
			self.menuMusicManager:clearOnBeatHooks()
			self:leave()
			cs.menuMusicManager = self.menuMusicManager
			cs.allowEditor = false
			cs.bg = self.bg
			cs:init()
		end)
	end, 0, nil, sprites.menu.play)

		self.mainMenu:addOption('playSelect',function()
		self.animatingout = true
		self.mainMenu.allowInput = false
		self.mainMenu.updateTransform = false
		flux.to(self, 15, {logoY = -300}):ease("inOutSine")
		flux.to(self.mainMenu, 15, {y = project.res.cy}):ease("inOutSine"):oncomplete(function ()
			cs = bs.load('SongSelect')
			self.menuMusicManager:clearOnBeatHooks()
			self:leave()
			cs.menuMusicManager = self.menuMusicManager
			cs.topDirectory = 'levels/Songwheel/'
			cs.allowEditor = false
			cs.bg = self.bg
			cs.bg.skipRender = false
			
			cs:init()
		end)
		
	end, 0, nil, sprites.menu.levels)
	
	local goToCustoms = function()
		if not love.filesystem.getInfo('Custom Levels','directory') then
			love.filesystem.createDirectory('Custom Levels')
		end
		cs = bs.load('SongSelect')
		self.menuMusicManager:clearOnBeatHooks()
		self:leave()
		cs.menuMusicManager = self.menuMusicManager
		cs.topDirectory = 'Custom Levels/'
		cs.allowEditor = true
		cs:init()
	end	
	
	local goToCustomsWorkshop = function()
		cs = bs.load('SongSelect')
		self.menuMusicManager:clearOnBeatHooks()
		self:leave()
		cs.menuMusicManager = self.menuMusicManager
		cs.topDirectory = 'Workshop/'
		if project.release then
			cs.allowEditor = false
		end
		cs:init()
	end
	
	self.mainMenu:addOption('customs',function()
		self:checkTutorials(goToCustoms)
		
	end, 17, nil, sprites.menu.customs)
	if project.useSteamAPI then
		self.mainMenu:addOption('customsWorkshop',function()
			self:checkTutorials(function()
				if project.mountedWorkshop then
					goToCustomsWorkshop()
				else
					PopupManager.queuePopup('menuWorkshopTitle', 'menuWorkshop', 60, {{label='popupGoBack'},{label='popupViewWorkshop',func = function()
						steam.friends.activateGameOverlayToWebPage('https://steamcommunity.com/app/3045200/workshop/')
					end}})
				end
				
			end)
			
		end, 17, nil, sprites.menu.workshop)
	end

	-- NOTE: Marathon will probably actually be elsewhere in the final game.
	-- I'm just adding it back here for parity with the old menu.
	-- -DPS
	if marathonEnabled then

	self.mainMenu:addOption('marathon',function()
		cs = bs.load('SongSelect')
		self.menuMusicManager:clearOnBeatHooks()
		self:leave()
		cs.menuMusicManager = self.menuMusicManager
		cs.topDirectory = 'levels/Marathon/'
		cs.allowEditor = false
		cs:init()
		
	end, 17, nil, sprites.menu.marathon)


	end
	self.mainMenu:addOption('achievements',function()
			cs = bs.load('AchievementViewer')
			
			self.menuMusicManager:clearOnBeatHooks()
			self:leave()
			cs.menuMusicManager = self.menuMusicManager
			cs.bg = self.bg

			cs:init()
		end, 17*5, nil, sprites.menu.achievements)
	self.mainMenu:addOption('costumes',function()
		cs = bs.load('Costumes')
		self.menuMusicManager:clearOnBeatHooks()
		self:leave()
		cs.menuMusicManager = self.menuMusicManager
		cs:init()
	end, 17*3, nil, sprites.menu.costumes)

	self.mainMenu:addOption('settings',function()
		
		self.mainMenu.allowInput = false
		self.optionsMenu.allowInput = true
		self.panEase = flux.to(self,60,{x = -1}):ease('outExpo')
		
	end, 17*4, nil, sprites.menu.settings)
	
	self.mainMenu:addOption('Mods', function()
		cs = bs.load('Mods')
		self.menuMusicManager:clearOnBeatHooks()
		self:leave()
		cs.menuMusicManager = self.menuMusicManager
		cs:init()
	end, 17 * 3, nil, sprites.menu.mods)
	
	for i = 1, 4 do
		self.mainMenu.options.main[i].y = self.mainMenu.options.main[i].y - 17
	end
	self.mainMenu:addOption('credits',function()
			cs = bs.load('Credits')
			self:leave()
			self.menuMusicManager:stop()
			--cs.menuMusicManager = self.menuMusicManager
			--cs.topDirectory = 'levels/'
			cs:init()
		end, 17*5, nil, sprites.menu.credits)

	self.mainMenu:addOption('exitgame',function()
		love.event.quit()
	end, 17*6, nil, sprites.menu.quit)
	if not project.release then
		
		self.mainMenu:addOption('devLevelSelect',function()
			cs = bs.load('SongSelect')
			self:leave()
			self.menuMusicManager:clearOnBeatHooks()
			cs.menuMusicManager = self.menuMusicManager
			cs.topDirectory = 'levels/'
			cs:init()
		end, 17*7, nil, sprites.menu.developer)
	else
		self.mainMenu:addOption('discordLink',function()
			love.system.openURL('https://discord.gg/MAXGRYPMSw')
		end, 17*7, nil, sprites.menu.discord)
		
	end

	self.mainMenu:setSelection(_G['mainMenuSelection'] or 1)
	self.mainMenu.visualSelection = _G['mainMenuSelection'] or 1
	local optionsHeight = 17
	self.optionsMenu = em.init('OptionsList',{allowInput = false})
	
	--remove language option while the only one we have other than english is a joke
	--self.optionsMenu:addOption('optionsLanguage','language',optionsHeight*1)
	self.optionsMenu:defineSubmenu('language')
		local langOption = self.optionsMenu:addCustom('language',optionsHeight*1,30)
		
		langOption.languages = {'en','owo'}
		for _, language in ipairs(customLanguages) do
			if not bbp.utils.tableContains(langOption.languages, language) then
				table.insert(langOption.languages, language)
			end
		end
		langOption.languageIndex = 0
		for i,v in ipairs(langOption.languages) do
			if v == loc.lang then 
				langOption.languageIndex = i
			end
		end
		
		
		langOption.onInput = function(langSelf,x)
			langSelf.languageIndex = (langSelf.languageIndex + x - 1) % #langSelf.languages + 1
			te.play(sounds.hold,"static",'sfx',0.5)
		end
		langOption.getText = function(langSelf)
			return '[<]  ' .. loc.get('lang_'.. (langSelf.languages[langSelf.languageIndex] or 'unknown')) .. '  [>]'
		end
		
		self.optionsMenu:addOption('back',function()
			local newLanguage = langOption.languages[langOption.languageIndex]
			if loc.lang == newLanguage then
				self.optionsMenu:setSubmenu('main')
			else
				savedata.options.language = newLanguage
				sdfunc.save()
				love.event.quit('restart')
			end
		end,optionsHeight*3)
	self.optionsMenu:defineSubmenu()
	self.optionsMenu:addOption('optionsAccessibility','accessibility',optionsHeight*1)
	self.optionsMenu:defineSubmenu('accessibility')
		self.optionsMenu:addEnum('optionsVFX',{
			{'full','loc@optionsVFXFull'},
			{'decreased','loc@optionsVFXDecreased'},
			{'none','loc@optionsVFXNone'}
		},savedata.options.accessibility,'vfx',optionsHeight*0.5)
		self.optionsMenu:addEnum('optionsTaps',{
			{'default','loc@optionsNotesDefault'},
			{'lenient','loc@optionsNotesLenient'},
			{'strict','loc@optionsNotesStrict'},
			{'auto','loc@optionsNotesAuto'}
		},savedata.options.accessibility,'taps',optionsHeight*1.5)
		self.optionsMenu:addEnum('optionsSides',{
			{'default','loc@optionsNotesDefault'},
			{'lenient','loc@optionsNotesLenient'},
			{'auto','loc@optionsNotesAuto'}
		},savedata.options.accessibility,'sides',optionsHeight*2.5)
		self.optionsMenu:addEnum('optionsBarelies',{
			{'default','loc@optionsNotesDefault'},
			{'lenient','loc@optionsNotesLenient'},
			{'strict','loc@optionsNotesStrict'}
		},savedata.options.accessibility,'barelies',optionsHeight*3.5)
		self.optionsMenu:addEnum('optionsCursorMode', {
				{ 'default', 'loc@enumCursorDefault' },
				{ 'large',   'loc@enumCursorLarge' },
				{ 'invert',  'loc@enumCursorInvert' }
		}, savedata.options.game, 'cursorMode', optionsHeight * 4.5, function ()
			if savedata.options.game.customCursorInMenu and (savedata.options.game.cursorMode ~= "default") then
				love.mouse.setVisible(false)
			else
				love.mouse.setVisible(true)
			end
		end)
		self.optionsMenu:addBoolean({'optionsCustomCursorInMenu','optionsEnabled','optionsDisabled'}, savedata.options.game, "customCursorInMenu", optionsHeight * 5.5, function ()
			if savedata.options.game.customCursorInMenu and (savedata.options.game.cursorMode ~= "default") then
				love.mouse.setVisible(false)
			else
				love.mouse.setVisible(true)
			end
		end)
		self.optionsMenu:addNumber('optionsStrainReduction', savedata.options.accessibility, 'strainReduction', optionsHeight*6.5, 10, {0, 100})
		self.optionsMenu:addNumber('optionsSaturation', savedata.options.accessibility, 'saturation', optionsHeight*7.5, 10, {0, 100})
		self.optionsMenu:addColors(fonts.digitalDisco:getWidth(loc.get('optionsSaturation')), optionsHeight*8.5)
		self.optionsMenu:addOption('back','main',optionsHeight*9.5)
	self.optionsMenu:defineSubmenu()
	self.optionsMenu:addOption('optionsGraphics','graphics',optionsHeight*2)
	self.optionsMenu:defineSubmenu('graphics')
		--self.optionsMenu:addBoolean({'optionsFullscreen','optionsEnabled','optionsDisabled'},savedata.options.graphics,'fullscreen',optionsHeight*1,sdfunc.updateWindow)
		self.optionsMenu:addEnum('optionsDisplayMode',{
			{'windowed','loc@enumWindowed'},
			{'fullscreen','loc@enumFullscreen'},
			{'borderless','loc@enumBorderless'}
		},savedata.options.graphics,'displayMode',optionsHeight*1, sdfunc.updateWindow)
		self.optionsMenu:addNumber('optionsWindowScale',savedata.options.graphics,'windowScale',optionsHeight*2,1,{1,5},sdfunc.updateWindow)
		self.optionsMenu:addEnum('optionsHUD', {
					{'default', 'loc@enumHUDDefault'},
					{'expanded', 'loc@enumHUDExpanded'},
					{'expandedPlus', 'loc@enumHUDExpandedPlus'},
					{'none', 'loc@enumHUDNone'}
				}, savedata.options.graphics, 'hudStyle', optionsHeight*3)	
		self.optionsMenu:addBoolean({'optionsVSync', 'optionsEnabled', 'optionsDisabled'}, savedata.options.graphics, 'vsync', optionsHeight*4, function()
			if savedata.options.graphics.vsync then
				love.window.setVSync(-1)
			else
				love.window.setVSync(0)
			end
		end)
		self.optionsMenu:addOption('back','main',optionsHeight*6)
		
	self.optionsMenu:defineSubmenu()
	self.optionsMenu:addOption('optionsAudio','audio',optionsHeight*3)
	self.optionsMenu:defineSubmenu('audio')
	
		self.optionsMenu:addNumber('optionsMusicVolume',savedata.options.audio,'musicvolume',optionsHeight*1,1,{0,10},sdfunc.updateVol)
		self.optionsMenu:addNumber('optionsSfxVolume',savedata.options.audio,'sfxvolume',optionsHeight*2,1,{0,10},sdfunc.updateVol)
		self.optionsMenu:addBoolean({'optionsHitsounds','optionsEnabled','optionsDisabled'},savedata.options.audio,'hitsounds',optionsHeight*3,sdfunc.updateVol)
		self.optionsMenu:addBoolean({'optionsPlayMenuMusic','optionsEnabled','optionsDisabled'}, savedata.options.audio, 'playMenuMusic', optionsHeight*4,function()
			if savedata.options.audio.playMenuMusic then
				self.menuMusicManager:play()
			else
				self.menuMusicManager:stop()
			end
		end)
		self.optionsMenu:addBoolean({'optionsMuteOnFocusLoss','optionsEnabled','optionsDisabled'}, savedata.options.audio, 'muteOnFocusLoss', optionsHeight*5)
		self.optionsMenu:addOption('back','main',optionsHeight*7)
	
	self.optionsMenu:defineSubmenu()
	self.optionsMenu:addOption('optionsGameplay','gameplay',optionsHeight*4)
	self.optionsMenu:defineSubmenu('gameplay')

		self.optionsMenu:addNumber('optionsInputOffset',savedata.options.game,'inputOffset',optionsHeight*1)
		self.optionsMenu:addOption('optionsCalibrate',function()
			
			self.menuMusicManager:stop()
			cLevel = 'levels/Other/calibration/'
			returnData = {state = 'Menu', vars = {}}
			cs = bs.load('Game')
			self:leave()
			cs:init()
			
		end,optionsHeight*2)

		self.optionsMenu:addOption('resetSave',function()
			PopupManager.queuePopup('resetSave1','resetSave1_description',200,{
				{label='popupGoBack'},
				{label='popupContinue',func = function()
					-- but are you really sure?
					-- final warning!! no going back after this one!!
					-- TODO: REPLACE THIS WITH CRANKY SPINNING CONFIRMATION MINIGAME
					PopupManager.queuePopup('resetSave2','resetSave2_description',200,{
						{label='popupGoBack'},
						{label='popupContinue',func = function()
							--print("alright, run the time loop. this iteration's over.")
							sdfunc.resetData()
							love.event.quit('restart')
						end}
					})
				end}
		})
		end,optionsHeight*4)
		
		self.optionsMenu:addOption('back','main',optionsHeight*6)
	
		self.optionsMenu:defineSubmenu()
		self.optionsMenu:addOption('optionsKeybinds', 'keybinds', optionsHeight*5)
		self.optionsMenu:defineSubmenu('keybinds')
		self.optionsMenu:addOption('optionsKeybindsKeyboardGameplay',function()
			local ps = cs
			cs = bs.load('Keybinds')
			--self:leave() --caused the menu bg to disappear, so I commented it out :v:
			cs.ps = ps
			self.menuMusicManager:clearOnBeatHooks()
			self:leave()
			cs.menuMusicManager = self.menuMusicManager
			cs.type = 'keyboardGameplay'
			cs.keybinds = savedata.options.bindings.keyboardGameplay
			cs:init()
			cs.blockinput = true
			end, optionsHeight*1)
		self.optionsMenu:addOption('optionsKeybindsKeyboardMenu',function()
			local ps = cs
			cs = bs.load('Keybinds')
			cs.ps = ps
			self.menuMusicManager:clearOnBeatHooks()
			self:leave()
			cs.menuMusicManager = self.menuMusicManager
			cs.type = 'keyboardMenu'
			cs.keybinds = savedata.options.bindings.keyboardMenu
			cs:init()
			cs.blockinput = true
			end, optionsHeight*2)
		self.optionsMenu:addOption('optionsKeybindsKeyboardEditor',function()
			local ps = cs
			cs = bs.load('Keybinds')
			cs.ps = ps
			self.menuMusicManager:clearOnBeatHooks()
			self:leave()
			cs.menuMusicManager = self.menuMusicManager
			cs.type = 'keyboardEditor'
			cs.keybinds = savedata.options.bindings.keyboardEditor
			cs:init()
			cs.blockinput = true
			end, optionsHeight*3)
		self.optionsMenu:addOption('optionsKeybindsControllerBinds',function()
			local ps = cs
			cs = bs.load('Keybinds')
			cs.ps = ps
			self.menuMusicManager:clearOnBeatHooks()
			self:leave()
			cs.menuMusicManager = self.menuMusicManager
			cs.type = 'controllerBinds'
			cs.keybinds = savedata.options.bindings.controllerBinds
			cs:init()
			cs.blockinput = true
		end, optionsHeight*4)
		self.optionsMenu:addBoolean({'optionsControllerLights', 'optionsEnabled', 'optionsDisabled' }, savedata.options,'controllerLights', optionsHeight * 5)
		self.optionsMenu:addOption('optionsMouseSettings', 'mouseSettings', optionsHeight * 6)
		
		self.optionsMenu:addOption('back', 'main', optionsHeight * 8)

			self.optionsMenu:defineSubmenu()
			self.optionsMenu:defineSubmenu('mouseSettings', 'keybinds')
            self.optionsMenu:addEnum('optionsCircleSnap', {
				{ 'disabled', 'loc@enumCircleSnapDisabled' },
				{ 'stiff',   'loc@enumCircleSnapStiff' },
				{ 'snappy',  'loc@enumCircleSnapSnappy' },
                { 'dome',  'loc@enumCircleSnapDome' }
			}, savedata.options.game, 'circleSnap', optionsHeight * 1)
            self.optionsMenu:addEnum('optionsCircleSnapRadius', {
                { 0.6, '60%%' },
				{ 0.7, '70%%' },
				{ 0.8, '80%%' },
                { 0.9, '90%%' },
                { 1, '100%%' },
                { 0.1, '10%%' },
                { 0.2, '20%%' },
                { 0.3, '30%%' },
                { 0.4, '40%%' },
                { 0.5, '50%%' }
			}, savedata.options.game, 'circleSnapRadius', optionsHeight * 2)
			self.optionsMenu:addBoolean({ 'optionsForceMouseKeyboard', 'optionsEnabled', 'optionsDisabled' }, savedata.options
			.game, 'forceMouseKeyboard', optionsHeight * 3)
			self.optionsMenu:addBoolean({ 'optionsLockToWindow', 'optionsEnabled', 'optionsDisabled' }, savedata.options.game,
				'lockMouseToWindow', optionsHeight * 4)
			
			self.optionsMenu:addBoolean({'optionsDisableClick', 'optionsEnabled', 'optionsDisabled'}, savedata.options.game, 'disableClick', optionsHeight*5)
		self.optionsMenu:addOption('back','keybinds',optionsHeight*7)

	self.optionsMenu:defineSubmenu('main')
	self.optionsMenu:setSelection(1)
	
	
	
	local returnToMainMenu = function()
		sdfunc.save()
		self.mainMenu.allowInput = true
		self.optionsMenu.allowInput = false
		self.panEase = flux.to(self,60,{x = 1}):ease('outExpo')
	end
	
	self.optionsMenu:addOption('back',returnToMainMenu,optionsHeight*7)

	self.optionsMenu.returnLoc['main'] = returnToMainMenu
	self.optionsMenu:setSubmenu('main')
	
	if not self.menuMusicManager then
		self.menuMusicManager = em.init('MenuMusicManager')
		self.menuMusicManager:play()
	end


	self.logoEase = nil
	self.logoZoom = 1
	
	
	self.menuMusicManager:addOnBeatHook(function(b)
		if b % 2 == 0 then
			--self.logoZoom = 1.03
		else
			self.logoZoom = 1.1
		end
		self.logoEase = flux.to(self,60,{logoZoom=1}):ease("outExpo")
	end)

	self.bgparams = {}
	if extrasavedata.moreMMenuCustomization and extrasavedata.moreMMenuCustomization.enabled and em.entities[extrasavedata.moreMMenuCustomization.backgroundEntity] then
		shuv.resetPal()
		local palette = extrasavedata.moreMMenuCustomization.palette
		for i = 0, 7 do
			local key = tostring(i)
			shuv.pal[i] = { 
				r = palette[key].r,
				g = palette[key].g,
				b = palette[key].b
			}
		end
		self.bgparams = extrasavedata.moreMMenuCustomization.bgParams
		self.bg = self.bg or em.init(extrasavedata.moreMMenuCustomization.backgroundEntity,extrasavedata.moreMMenuCustomization.bgParams)
	else
		self.bg = self.bg or em.init('MenuBackground')
	end
	self.bg.skipUpdate = true
	self.bg.delete = false

	if self.fromMap then
		self.logoY = -300
		self.mainMenu.allowInput = false
		self.mainMenu.updateTransform = false
		self.mainMenu.x = project.res.cx
		self.mainMenu.y = project.res.cy
		self.mainMenu.radius = 500 

		self.panEase = flux.to(self, 15, {logoY = 0}):ease("inOutSine")
		flux.to(self.mainMenu, 15, {y = 750}):ease("inOutSine"):oncomplete(function ()
			self.mainMenu.allowInput = true
			self.mainMenu.updateTransform = true
		end)

	end
	UnlockManager.checkMapUnlocks("levels/AtomMap.json")
	
	if not savedata.seenIntroPopups then
		PopupManager.queuePopup('menuWelcomeTitle', 'menuWelcome1', 60, {
			{label='popupYes',func = function()
				PopupManager.queuePopup(nil, 'menuWelcome2', 60, {{label='popupOK'}})
				PopupManager.queuePopup(nil, 'menuWelcome3', 60, {{label='popupOK'}})
				PopupManager.queuePopup(nil, 'menuWelcome4', 60, {{label='popupOK'}})
				PopupManager.queuePopup(nil, 'menuWelcome5', 60, {{label='popupOK'}})
			end},
			{label='popupNo',func = function() 
				PopupManager.queuePopup(nil, 'menuWelcomeNo', 60, {{label='popupOK'}})
			end}
		})
		savedata.seenIntroPopups = true
		sdfunc.save()
	end
		self.mainMenu:reorderToIds(extrasavedata.mainMenuList)
		self.mainMenu:addHidden(extrasavedata.disabledMainOptions)
		
		if extrasavedata.randomizeMenuOnStart then
			for i = #extrasavedata.mainMenuList, 2, -1 do
				local j = love.math.random(i)
				extrasavedata.mainMenuList[i], extrasavedata.mainMenuList[j] = extrasavedata.mainMenuList[j], extrasavedata.mainMenuList[i]
			end
			self.mainMenu:reorderToIds(extrasavedata.mainMenuList)
		end
end)

function st:checkTutorials(func)
	local tutorialPlayed = UnlockManager.isLevelPassed({
		level = 'Finished levels/tutorial/',
		percent = 0,
	})
	if not tutorialPlayed then
		print('didnt play the tutorial lol')
		
		PopupManager.queuePopup('tutorialNagTitle', 'tutorialNag', 60, {{label='popupOK'}})
	else
		
		local mechanicsPlayed = UnlockManager.isLevelPassed({
			level = 'Finished levels/cobblestonecounterpoint/',
			percent = 0
		})
		mechanicsPlayed = mechanicsPlayed and UnlockManager.isLevelPassed({
			level = 'Finished levels/ladybugCastle/',
			percent = 0
		})
		mechanicsPlayed = mechanicsPlayed and UnlockManager.isLevelPassed({
			level = 'Finished levels/publicocautivo/',
			percent = 0
		})
		mechanicsPlayed = mechanicsPlayed and UnlockManager.isLevelPassed({
			level = 'Finished levels/staticNew/',
			percent = 0
		})
		
		if mechanicsPlayed then
			func()
		else
			PopupManager.queuePopup('tutorialNagAltTitle', 'tutorialNagAlt', 60, {{label='popupGoBack'},{label='popupContinue',func = function() func() end}})
		end
	end
	
	
end

function st:leave()
	_G['mainMenuSelection'] = self.mainMenu.selection
	shuv.showBadColors = false
	self.bg.delete = true
end

st:setUpdate(function(self,dt)
	
	self.menuMusicManager:update()
	if not self.blockInteraction then
		local ranFunction = self.mainMenu:update(dt)
		if not ranFunction then
			self.optionsMenu:update()
		end

		if maininput:pressed('back') or mouse.altpress == -1 then
			self.optionsMenu:callReturn()
		end
	else
		if (maininput:pressed('back') or maininput:pressed('accept') or mouse.pressed == 1) and self.tutorialPopup then
			self.tutorialPopup = false
			self.blockInteraction = false
			te.play(sounds.hold,"static",'sfx',0.5)
		end
	end
	
	if self.bg then
		self.bg:update(dt)
	end
	
end)

st:setBgDraw(function(self)
	
	color(0)
	love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)
	
end)

st:setFgDraw(function(self)

if maininput:down("f9") then
	self.editMenu = true
end

if self.chimaera then
	self.menuMusicManager:stop()
	

		
	cs = bs.load('WorldState')
	self.bg.delete = true
	cs:init('Mods/ExtraStuff/rooms/EraChimaeraRoom.json')
end

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = love.math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

if self.editMenu then
	self.editMenu = imgui.Begin("Edit Menu", true)

	imguiextra.DrawReorderableRadialList(self.mainMenu, "mainMenu", {imgui.GetContentRegionAvail().x, 24})

	if imgui.Button("Reset") then
		self.mainMenu:restoreHidden(extraDefaultSave.disabledMainOptions)
		extrasavedata.disabledMainOptions = extraDefaultSave.disabledMainOptions
		self.mainMenu:reorderToIds(extraDefaultSave.mainMenuList)
	end

	imgui.SameLine()

	if imgui.Button("Randomize") then
		shuffle(extrasavedata.mainMenuList)
		self.mainMenu:reorderToIds(extrasavedata.mainMenuList)
	end

	self.mainMenu:saveList(self.mainMenu, "mainMenuList", "disabledMainOptions")
	
	imguiextra.LabeledSeparator("More Customization", 1)
	if not extrasavedata.moreMMenuCustomization then
		extrasavedata.moreMMenuCustomization = helpers.copytable(extraDefaultSave.moreMMenuCustomization)
	end
	if extrasavedata.moreMMenuCustomization then
		extrasavedata.moreMMenuCustomization.enabled = helpers.InputBool("More Customization", (extrasavedata.moreMMenuCustomization.enabled or false))
		if extrasavedata.moreMMenuCustomization.enabled then
			--local backgroundEntities = {"MenuBackground", "oldTitle", "CreditsBG", "cbackground", "TutorialBG", "ShinamonBG", "Rain", "HoleBackground", "TrumpetGirl", "Plasma", "SineWaves", "LawrenceBG", "DamoclismBG", "SpiralBG", "DecoAtomMap", "MonitorTheme"}
			local backgroundEntities = {"MenuBackground", "oldTitle", "CreditsBG", "cbackground", "TutorialBG", "ShinamonBG", "Rain", "HoleBackground", "Plasma", "SineWaves", "LawrenceBG", "DamoclismBG", "SpiralBG", "Player"}
			
			imguiextra.LabeledSeparator("Background Entity", 1)
			if imgui.BeginCombo("", extrasavedata.moreMMenuCustomization.backgroundEntity) then
				for i, v in ipairs(backgroundEntities) do
					local isSelected = (v == extrasavedata.moreMMenuCustomization.backgroundEntity)
					if imgui.Selectable_Bool(v, isSelected) then
						extrasavedata.moreMMenuCustomization.backgroundEntity = v
						local param = em.init(v)
						self.bgparams = helpers.copytable(param)
						param.delete = true
					end
				end
				imgui.EndCombo()
			end
			if imgui.CollapsingHeader_TreeNodeFlags("Parameters") then
				if type(self.bgparams or nil) == "table" then
					imguiHelp.drawTable(self.bgparams, {boolean = true, number = true, string = true}, {skipRender = true, skipUpdate = true, delete = true})
					local function extractValues(tbl, allowedTypes)
						local result = {}
						for k, v in pairs(tbl) do
							local t = type(v)
							if allowedTypes[t] then
								result[k] = v
							end
						end
						return result
					end
					extrasavedata.moreMMenuCustomization.bgParams = extractValues(self.bgparams, {boolean = true, number = true, string = true})
				else
					self.bgparams = helpers.copy(extrasavedata.moreMMenuCustomization.bgParams)
				end
				imgui.TextWrapped("If you crash your game after reloading. Go to savedata\\extraMod.sav")
				if imgui.Button("Clear Params") then
					self.clearBGParams = true
					extrasavedata.moreMMenuCustomization.bgParams = {}
				end
			end
			
			imguiextra.LabeledSeparator("Colors", 1)
			for i = 0, 7 do
				local color = extrasavedata.moreMMenuCustomization.palette[tostring(i)]
				color.r, color.g, color.b = helpers.imguiColor(tostring(i), color.r, color.g, color.b)
				shuv.pal[i] = helpers.copy(color)
			end
			if imgui.Button("Reset Colors") then
				shuv.resetPal()
				shuv.pal[2] = {r= 205, g=205, b=205}
				shuv.pal[3] = {r= 255, g=52, b=50}
				shuv.pal[4] = {r= 224, g=227, b=0}
				shuv.pal[5] = {r= 44, g=255, b=57}
				shuv.pal[6] = {r= 0, g=222, b=229}
				shuv.pal[7] = {r= 63, g=38, b=255}
				for i = 0, 7 do
					local color = shuv.pal[i]
					extrasavedata.moreMMenuCustomization.palette[tostring(i)] = helpers.copy(color)
				end
			end
		end
	end
	imgui.Separator()
	if imgui.Button("Reload") then
		if self.clearBGParams then
			extrasavedata.moreMMenuCustomization.bgParams = {}
		end
		cs = bs.load('Menu')
		self.menuMusicManager:clearOnBeatHooks()
		cs.menuMusicManager = self.menuMusicManager
		cs:init()

		-- return to ingame cursor if the settings say so
		if savedata.options.game.customCursorInMenu and (savedata.options.game.cursorMode ~= "default") then
			love.mouse.setVisible(false)
		end
	end
	
	imgui.End()
	
	if imgui.love.GetWantCaptureMouse() then
		love.mouse.setVisible(true)
	elseif savedata.options.game.customCursorInMenu and (savedata.options.game.cursorMode ~= "default") then
		love.mouse.setVisible(false)
	end
	
end

	love.graphics.setFont(fonts.digitalDisco)
	color()

	self.mainMenu:draw(self.x * project.res.cx, 750, 500)
	self.mainMenu.circleWidth = 72 * self.logoZoom
	self.optionsMenu:draw(project.res.x + self.x * project.res.cx, 180)
	love.graphics.printf(loc.get('optionsHint'),project.res.cx + self.x * project.res.cx, 160,project.res.x,'center')
	
	
	love.graphics.print(loc.get('twitterPlug'),project.res.cx * -1 + 10 + self.x * project.res.cx,6+self.logoY )
	
	color(0)
	love.graphics.draw(sprites.title.logo,project.res.cx,100+ self.logoY,0,self.logoZoom, self.logoZoom,170,32)

	if self.tutorialPopup then
		local w,h = 330,130
		love.graphics.rectangle('fill',project.res.cx - w*0.5,project.res.cy - h*0.5,w,h)
		love.graphics.setLineWidth(2)
		color(1)
		love.graphics.rectangle('line',project.res.cx - w*0.5,project.res.cy - h*0.5,w,h)
		
		love.graphics.printf(loc.get('tutorialNag'),project.res.cx - w*0.5,150,w,'center')
		local locString = 'pressToContinue_mouse'
		if helpers.usingController() then 
			locString = 'pressToContinue_controller'
		end
		love.graphics.printf(loc.get(locString),project.res.cx - w*0.5,200,w,'center')
	end

	color('black')
	love.graphics.print(version, project.res.cx * 2 - fonts.digitalDisco:getWidth(version) - 10 ,6 + self.logoY )
	color()
	
end)


return st]]

local st = Gamestate:new('OldMenu')

st:setInit(function(self)
	entities = {}

	shuv.resetPal()
	shuv.pal[2] = {r= 226, g=0, b=226}
	shuv.pal[3] = {r= 255, g=52, b=50}
	shuv.pal[4] = {r= 224, g=227, b=0}
	shuv.pal[5] = {r= 44, g=255, b=57}
	shuv.pal[6] = {r= 0, g=222, b=229}
	shuv.pal[7] = {r= 63, g=38, b=255}
	
	self.panEase = nil
	self.x = 1
	
	self.tutorialPopup = false
	
	local marathonOffset = 0
	local marathonEnabled = false
	
	local playedLevelsJson = LevelManager:loadPlayedLevels()
	
	local marathonLevels = {
		{'tutorial','easy'},
		{'grittedstrings'},
		{'sostressed','easy'},
		{'publicocautivo','Easy'},
		{'ILOVEYOUvbs','normal'},
		{'lawrence','normal'},
		{'TerabyteConnection'},
	}
	
	local sRanks = 0
	for i,v in ipairs(marathonLevels) do
		local levelData = LevelManager:getRank(playedLevelsJson,'levels/Finished levels/'..v[1]..'/',v[2])
		if levelData then 
			print(v[1]..': '..levelData.pctGrade)
			if levelData.pctGrade >= 90 then
				sRanks = sRanks + 1
			end
		else
			print(v[1]..' no data found')
		end
	end
	
	if sRanks >= (#marathonLevels - 1) then
		print('Found 6 A ranks, marathon enabled!')
		marathonEnabled = true
	end
	
	if marathonEnabled then
		marathonOffset = 1
	end
	
	self.mainMenu = em.init('OptionsList',{allowInput = true})
	self.mainMenu:addOption('playdemolevels',function()
		cs = bs.load('SongSelect')
		self.menuMusicManager:clearOnBeatHooks()
		cs.menuMusicManager = self.menuMusicManager
		cs.topDirectory = 'levels/Demo/'
		cs.allowEditor = false
		cs:init()
	end, 0)
	self.mainMenu:addOption('customs',function()
		
		if playedLevelsJson['Tutorial_CV35W_CV35W_easy'] or playedLevelsJson['Tutorial_CV35W_DPS2004'] then
			if not love.filesystem.getInfo('Custom Levels','directory') then
				love.filesystem.createDirectory('Custom Levels')
			end
			cs = bs.load('SongSelect')
			self.menuMusicManager:clearOnBeatHooks()
			cs.menuMusicManager = self.menuMusicManager
			cs.topDirectory = 'Custom Levels/'
			cs.allowEditor = true
			cs:init()
		else
			print('didnt play the tutorial lol')
			self.tutorialPopup = true
		end
		
	end, 17)
	if marathonEnabled then
		self.mainMenu:addOption('marathon',function()
				
			self.menuMusicManager:stop()
			
			returnData = {state = 'Menu', vars = {}}
			cs = bs.load('Marathon')
			cs.marathonData = {
				levelQueue = marathonLevels,
				originalLevelQueue = helpers.copy(marathonLevels),
				allARanks = true,
				currentLevel = 0,
				misses = {},
				barelies = {},
				grades = {},
				offsets = {},
				bg = {},
				names = {},
				missesTotal = 0,
				bareliesTotal = 0,
			}
			cs:init()
			
		end, 17*2)
	end
	self.mainMenu:addOption('settings',function()
		
		self.mainMenu.allowInput = false
		self.optionsMenu.allowInput = true
		self.panEase = flux.to(self,60,{x = -1}):ease('outExpo')
		
	end, 17*(2+marathonOffset))
	self.mainMenu:addOption('credits',function()
			cs = bs.load('Credits')
			self.menuMusicManager:stop()
			--cs.menuMusicManager = self.menuMusicManager
			--cs.topDirectory = 'levels/'
			cs:init()
		end, 17*(3+marathonOffset))

	self.mainMenu:addOption('exitgame',function()
		love.event.quit()
	end, 17*(4+marathonOffset))
	if not project.release then
		
		self.mainMenu:addOption('devLevelSelect',function()
			cs = bs.load('SongSelect')
			self.menuMusicManager:clearOnBeatHooks()
			cs.menuMusicManager = self.menuMusicManager
			cs.topDirectory = 'levels/'
			cs:init()
		end, 17*(5.5+marathonOffset))
	else
		self.mainMenu:addOption('discordLink',function()
			love.system.openURL('https://discord.gg/MAXGRYPMSw')
		end, 17*(5.5+marathonOffset))
		
	end

	self.mainMenu:setSelection(1)
	
	local optionsHeight = 17
	self.optionsMenu = em.init('OptionsList',{allowInput = false})
	
	self.optionsMenu:addOption('optionsLanguage','language',optionsHeight*1)
	self.optionsMenu:defineSubmenu('language')
		local langOption = self.optionsMenu:addCustom('language',optionsHeight*1,30)
		
		langOption.languages = {'en','owo'}
		langOption.languageIndex = 0
		for i,v in ipairs(langOption.languages) do
			if v == loc.lang then 
				langOption.languageIndex = i
			end
		end
		
		
		langOption.onInput = function(langSelf,x)
			langSelf.languageIndex = (langSelf.languageIndex + x - 1) % #langSelf.languages + 1
			te.play(sounds.hold,"static",'sfx',0.5)
		end
		langOption.getText = function(langSelf)
			return '[-]  ' .. loc.get('lang_'..langSelf.languages[langSelf.languageIndex]) .. '  [+]'
		end
		
		self.optionsMenu:addOption('back',function()
			local newLanguage = langOption.languages[langOption.languageIndex]
			if loc.lang == newLanguage then
				self.optionsMenu:setSubmenu('main')
			else
				savedata.options.language = newLanguage
				sdfunc.save()
				love.event.quit('restart')
			end
		end,optionsHeight*3)
	self.optionsMenu:defineSubmenu()
	self.optionsMenu:addOption('optionsAccessibility','accessibility',optionsHeight*2)
	self.optionsMenu:defineSubmenu('accessibility')
		self.optionsMenu:addEnum('optionsVFX',{
			{'full','loc@optionsVFXFull'},
			{'decreased','loc@optionsVFXDecreased'},
			{'none','loc@optionsVFXNone'}
		},savedata.options.accessibility,'vfx',optionsHeight*1)
		self.optionsMenu:addEnum('optionsTaps',{
			{'default','loc@optionsNotesDefault'},
			{'lenient','loc@optionsNotesLenient'},
			{'auto','loc@optionsNotesAuto'}
		},savedata.options.accessibility,'taps',optionsHeight*2)
		self.optionsMenu:addEnum('optionsSides',{
			{'default','loc@optionsNotesDefault'},
			{'lenient','loc@optionsNotesLenient'},
			{'auto','loc@optionsNotesAuto'}
		},savedata.options.accessibility,'sides',optionsHeight*3)
		self.optionsMenu:addNumber('optionsStrainReduction', savedata.options.accessibility, 'strainReduction', optionsHeight*4, 10, {0, 100})
		self.optionsMenu:addNumber('optionsSaturation', savedata.options.accessibility, 'saturation', optionsHeight*5, 10, {0, 100})
		self.optionsMenu:addColors(fonts.digitalDisco:getWidth(loc.get('optionsSaturation')), optionsHeight*6)
		self.optionsMenu:addOption('back','main',optionsHeight*7)
	self.optionsMenu:defineSubmenu()
	self.optionsMenu:addOption('optionsGraphics','graphics',optionsHeight*3)
	self.optionsMenu:defineSubmenu('graphics')
		--self.optionsMenu:addBoolean({'optionsFullscreen','optionsEnabled','optionsDisabled'},savedata.options.graphics,'fullscreen',optionsHeight*1,sdfunc.updateWindow)
		self.optionsMenu:addEnum('optionsDisplayMode',{
			{'windowed','loc@enumWindowed'},
			{'fullscreen','loc@enumFullscreen'},
			{'borderless','loc@enumBorderless'}
		},savedata.options.graphics,'displayMode',optionsHeight*1, sdfunc.updateWindow)
		self.optionsMenu:addNumber('optionsWindowScale',savedata.options.graphics,'windowScale',optionsHeight*2,1,{1,5},sdfunc.updateWindow)
		self.optionsMenu:addEnum('optionsHUD', {
					{'default', 'loc@enumHUDDefault'},
					{'expanded', 'loc@enumHUDExpanded'},
					{'expandedPlus', 'loc@enumHUDExpandedPlus'},
					{'none', 'loc@enumHUDNone'}
				}, savedata.options.graphics, 'hudStyle', optionsHeight*3)	
		self.optionsMenu:addBoolean({'optionsVSync', 'optionsEnabled', 'optionsDisabled'}, savedata.options.graphics, 'vsync', optionsHeight*4, function()
			if savedata.options.graphics.vsync then
				love.window.setVSync(-1)
			else
				love.window.setVSync(0)
			end
		end)
		--[[
		self.optionsMenu:addBoolean({'optionsMineholdStyle','enumMineholdFancy', 'enumMineholdClassic'},savedata.options.graphics, 'fancyMineholds', optionsHeight*5)
		self.optionsMenu:addText('fancyMineholdWarning',optionsHeight*6.25,nil,function() return savedata.options.graphics.fancyMineholds end)
		]]--
		self.optionsMenu:addOption('back','main',optionsHeight*6)
		
	self.optionsMenu:defineSubmenu()
	self.optionsMenu:addOption('optionsAudio','audio',optionsHeight*4)
	self.optionsMenu:defineSubmenu('audio')
	
		self.optionsMenu:addNumber('optionsMusicVolume',savedata.options.audio,'musicvolume',optionsHeight*1,1,{0,10},sdfunc.updateVol)
		self.optionsMenu:addNumber('optionsSfxVolume',savedata.options.audio,'sfxvolume',optionsHeight*2,1,{0,10},sdfunc.updateVol)
		self.optionsMenu:addBoolean({'optionsHitsounds','optionsEnabled','optionsDisabled'},savedata.options.audio,'hitsounds',optionsHeight*3,sdfunc.updateVol)
		self.optionsMenu:addBoolean({'optionsPlayMenuMusic','optionsEnabled','optionsDisabled'}, savedata.options.audio, 'playMenuMusic', optionsHeight*4,function()
			if savedata.options.audio.playMenuMusic then
				self.menuMusicManager:play()
			else
				self.menuMusicManager:stop()
			end
		end)
		self.optionsMenu:addBoolean({'optionsMuteOnFocusLoss','optionsEnabled','optionsDisabled'}, savedata.options.audio, 'muteOnFocusLoss', optionsHeight*5)
		self.optionsMenu:addOption('back','main',optionsHeight*7)
	
	self.optionsMenu:defineSubmenu()
	self.optionsMenu:addOption('optionsGameplay','gameplay',optionsHeight*5)
	self.optionsMenu:defineSubmenu('gameplay')

		self.optionsMenu:addNumber('optionsInputOffset',savedata.options.game,'inputOffset',optionsHeight*1)
		self.optionsMenu:addOption('optionsCalibrate',function()
			
			self.menuMusicManager:stop()
			cLevel = 'levels/Other/calibration/'
			returnData = {state = 'Menu', vars = {}}
			cs = bs.load('Game')
			cs:init()
			
		end,optionsHeight*2)
		
		self.optionsMenu:addOption('back','main',optionsHeight*6)
	
		self.optionsMenu:defineSubmenu()
		self.optionsMenu:addOption('optionsKeybinds', 'keybinds', optionsHeight*6)
		self.optionsMenu:defineSubmenu('keybinds')
		self.optionsMenu:addOption('optionsKeybindsKeyboardGameplay',function()
			local ps = cs
			cs = bs.load('Keybinds')
			cs.ps = ps
			self.menuMusicManager:clearOnBeatHooks()
			cs.menuMusicManager = self.menuMusicManager
			cs.type = 'keyboardGameplay'
			cs.keybinds = savedata.options.bindings.keyboardGameplay
			cs:init()
			end, optionsHeight*1)
		self.optionsMenu:addOption('optionsKeybindsKeyboardMenu',function()
			local ps = cs
			cs = bs.load('Keybinds')
			cs.ps = ps
			self.menuMusicManager:clearOnBeatHooks()
			cs.menuMusicManager = self.menuMusicManager
			cs.type = 'keyboardMenu'
			cs.keybinds = savedata.options.bindings.keyboardMenu
			cs:init()
			end, optionsHeight*2)
		self.optionsMenu:addOption('optionsKeybindsKeyboardEditor',function()
			local ps = cs
			cs = bs.load('Keybinds')
			cs.ps = ps
			self.menuMusicManager:clearOnBeatHooks()
			cs.menuMusicManager = self.menuMusicManager
			cs.type = 'keyboardEditor'
			cs.keybinds = savedata.options.bindings.keyboardEditor
			cs:init()
			end, optionsHeight*3)
		self.optionsMenu:addOption('optionsKeybindsControllerBinds',function()
			local ps = cs
			cs = bs.load('Keybinds')
			cs.ps = ps
			self.menuMusicManager:clearOnBeatHooks()
			cs.menuMusicManager = self.menuMusicManager
			cs.type = 'controllerBinds'
			cs.keybinds = savedata.options.bindings.controllerBinds
			cs:init()
			end, optionsHeight*4)
		self.optionsMenu:addOption('optionsMouseSettings', 'mouseSettings', optionsHeight * 5)
		self.optionsMenu:addOption('back', 'main', optionsHeight * 7)

			self.optionsMenu:defineSubmenu()
			self.optionsMenu:defineSubmenu('mouseSettings', 'keybinds')
			self.optionsMenu:addBoolean({ 'optionsCircleSnap', 'optionsEnabled', 'optionsDisabled' }, savedata.options.game,
				'circleSnap', optionsHeight * 1)
			self.optionsMenu:addBoolean({ 'optionsForceMouseKeyboard', 'optionsEnabled', 'optionsDisabled' }, savedata.options
			.game, 'forceMouseKeyboard', optionsHeight * 2)
			self.optionsMenu:addBoolean({ 'optionsLockToWindow', 'optionsEnabled', 'optionsDisabled' }, savedata.options.game,
				'lockMouseToWindow', optionsHeight * 3)
			self.optionsMenu:addEnum('optionsCursorMode', {
				{ 'default', 'loc@enumCursorDefault' },
				{ 'large',   'loc@enumCursorLarge' },
				{ 'invert',  'loc@enumCursorInvert' }
			}, savedata.options.game, 'cursorMode', optionsHeight * 4)
			self.optionsMenu:addBoolean({'optionsDisableClick', 'optionsEnabled', 'optionsDisabled'}, savedata.options.game, 'disableClick', optionsHeight*5)
		self.optionsMenu:addOption('back','keybinds',optionsHeight*7)

	self.optionsMenu:defineSubmenu('main')
	self.optionsMenu:setSelection(1)
	
	
	
	--[[
	enumTestValue = enumTestValue or 'enumOne'
	self.optionsMenu:addEnum('optionsTestEnum',{'enumOne','enumTwo','enumThree'},_G,'enumTestValue',optionsHeight*4)
	]]--
	local returnToMainMenu = function()
		sdfunc.save()
		self.mainMenu.allowInput = true
		self.optionsMenu.allowInput = false
		self.panEase = flux.to(self,60,{x = 1}):ease('outExpo')
	end
	
	--[[
	self.optionsMenu:addOption('cheat at fishing',function()
		savedata.fishing.fishingPower = 100
	end,optionsHeight*7)
	]]--
	
	self.optionsMenu:addOption('back',returnToMainMenu,optionsHeight*8)

	self.optionsMenu.returnLoc['main'] = returnToMainMenu
	self.optionsMenu:setSubmenu('main')
	
	--[[
	if #te.findTag('music') == 0 then
		te.playLooping('assets/music/menuloop.ogg','stream','music')
	end
	]]
	if not self.menuMusicManager then
		self.menuMusicManager = em.init('MenuMusicManager')
		self.menuMusicManager:play()
	end


	self.logoEase = nil
	self.logoZoom = 1
	
	
	self.menuMusicManager:addOnBeatHook(function(b)
		if b % 2 == 0 then
			--self.logoZoom = 1.03
		else
			self.logoZoom = 1.1
		end
		self.logoEase = flux.to(self,60,{logoZoom=1}):ease("outExpo")
	end)

end)

st:setUpdate(function(self,dt)

	self.menuMusicManager:update()
	if not self.tutorialPopup then
		local ranFunction = self.mainMenu:update()
		if not ranFunction then
			self.optionsMenu:update()
		end

		if maininput:pressed('back') then
			self.optionsMenu:callReturn()
		end
	else
		if maininput:pressed('back') or maininput:pressed('accept') or mouse.pressed == 1 then
			self.tutorialPopup = false
			te.play(sounds.hold,"static",'sfx',0.5)
		end
	end
end)


st:setBgDraw(function(self)

	love.graphics.setFont(fonts.digitalDisco)
	
	color(0)
	love.graphics.rectangle('fill',0,0,project.res.x,project.res.y)

	self.mainMenu:draw(0 + self.x * project.res.cx, 200)
	self.optionsMenu:draw(project.res.x + self.x * project.res.cx, 180)
	love.graphics.printf(loc.get('optionsHint'),project.res.cx + self.x * project.res.cx, 160,project.res.x,'center')
	
	
	love.graphics.print(loc.get('twitterPlug'),project.res.cx * -1 + 10 + self.x * project.res.cx,336)
	
	color(0)
	love.graphics.draw(sprites.title.logo,project.res.cx,100,0,self.logoZoom, self.logoZoom,170,32)

	if self.tutorialPopup then
		local w,h = 330,130
		love.graphics.rectangle('fill',project.res.cx - w*0.5,project.res.cy - h*0.5,w,h)
		love.graphics.setLineWidth(2)
		color(1)
		love.graphics.rectangle('line',project.res.cx - w*0.5,project.res.cy - h*0.5,w,h)
		
		love.graphics.printf(loc.get('tutorialNag'),project.res.cx - w*0.5,150,w,'center')
		local locString = 'pressToContinue_mouse'
		if helpers.usingController() then 
			locString = 'pressToContinue_controller'
		end
		love.graphics.printf(loc.get(locString),project.res.cx - w*0.5,200,w,'center')
	end

	color('black')
	love.graphics.print(version, project.res.cx * 2 - fonts.digitalDisco:getWidth(version) - 10 ,336)
	color()

end)


return st