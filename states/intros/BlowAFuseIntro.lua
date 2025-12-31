local st = Gamestate:new('BlowAFuseIntro')

st.static = {}
st.static.canvas = love.graphics.newCanvas(project.res.x, project.res.y)
st.static.explosion = ez.newjson("levels/Finished levels/blowafuse/kaboom")
st.static.audio = sounds.explosion

st:setInit(function(self, filename)
    self.timer = 0
    self.truetimer = 0
    self.skiptimer = 0
    self.goToLevel = false

    shuv.usePalette = true
    shuv.resetPal()
    shuv.pal[0] = {r=255,g=255,b=255}
    shuv.pal[1] = {r=35,g=35,b=35}
    shuv.pal[2] = {r=253,g=3,b=56}
    shuv.pal[3] = {r=145,g=0,b=55}
    shuv.pal[4] = {r=239,g=220,b=220}
    shuv.pal[5] = {r=72,g=63,b=57}
    shuv.pal[6] = {r=252,g=136,b=144}
    shuv.pal[7] = {r=73,g=0,b=24}

    self.bomb = em.init('SpinningBomb')
	local dist = 500
	local angle = math.rad(math.random(-90, 90))
	local cx, cy = project.res.x / 2, project.res.y / 2

	self.bomb.x = cx + math.cos(angle) * dist
	self.bomb.y = cy + math.sin(angle) * dist

    self.bomb.scale = 1

    self.explosion = nil

    flux.to(self.bomb, 50, {x = project.res.x/2, y = project.res.y/2, scale = 0.8})
        :delay(40)
        :ease("inOutQuad")
        :oncomplete(function()
            flux.to(self.bomb, 12, {scale = 1.2, sparkScale = 0.2, sparkSpeed = 0.5})
                :delay(50)
                :ease("inSine")
                :oncomplete(function()
                    self.bomb.scale = 0
                    te.playOne(st.static.audio, "static", "sfx", 1)
					
                    self.explosion = st.static.explosion:instance("all")
                    self.explosion:play("all", 0, function(inst)
						self.goToLevel = true
                        self.explosion = nil
                    end)
                end)
        end)
end)

st:setUpdate(function(self, dt)
    self.timer = self.timer + dt

    if maininput:down("tap1") or maininput:down("accept") or maininput:down("mouse1") then
        self.goToLevel = true
    end

    if self.skiptimer > 1 or self.goToLevel then
        cs = bs.load('Game')
        GameManager:transferStateData(cs, self)
		cs.explosion = self.explosion
        shuv.usePalette = true
        project.res.useShuv = true
        cs:init(self.filename, self.variant)
        self.bomb.delete = true
    end

    if self.explosion then
        self.explosion:update(dt)
    end

    flux.update(dt)
end)

st:setFgDraw(function(self)
    if self.bomb then
        love.graphics.draw(self.canv, 0, 0)
        love.graphics.draw(self.bgCanv, 0, 0)
        love.graphics.draw(self.fgCanv, 0, 0)
        love.graphics.draw(self.uiCanv, 0, 0)
        self.bomb:draw()
    end

    if self.explosion then
		self.explosion:draw(200, 180, 0, 2, 2, 71, 100) --(x,y,r,sx,sy,ox,oy,kx,ky)
        self.explosion:draw(450, 180, 0, 2, 2, 71, 100) --(x,y,r,sx,sy,ox,oy,kx,ky)
        self.explosion:draw(250, 180, 0, 3.5, 3.5, 71, 100) --(x,y,r,sx,sy,ox,oy,kx,ky)
    end
end)

return st
