cbackground = class('cbackground', Entity)

function cbackground:initialize(params)
	self.x = 0
	self.y = 0
	self.staticx = 300
	self.staticy = 180
	self.staticox = 300
	self.staticoy = 180

	self.scrollx = 0
	self.scrolly = 180
	self.scrollSpeed = 50

	self.staticspr = sprites.fight.bg
	self.scrollspr = sprites.fight.bgscroll

	self.scrollW = self.scrollspr:getWidth()
	
	self.glitchTimer = 0
	self.glitchDuration = 20
	self.glitchActive = false
	self.glitchCooldown = 0

	Entity.initialize(self, params)
	self:anim("anim")
	
	if not shuv.showBadColors then
		shuv.showBadColors = true
	end
end

function cbackground:startGlitch()
	if self.glitchActive then return end

	self.glitchActive = true
	self.glitchTimer = self.glitchDuration
	self.glitchCooldown = self.glitchDuration + 3 -- duration + buffer
end


function cbackground:anim(anim)
	if anim == "anim" then
		-- kill any existing loop
		if self.scrollTween then
			self.scrollTween:stop()
			self.scrollTween = nil
		end

		local function loop()
			-- stay fast for a bit
			self.scrollTween =
				flux.to(self, 2, {}):oncomplete(function()

					-- slow down
					self.scrollTween = flux.to(self, 80, { scrollSpeed = 5 })
						:ease("inOutSine")
						:oncomplete(function()

							-- speed back up
							self.scrollTween = flux.to(self, 80, { scrollSpeed = 20 })
								:ease("inOutSine")
								:oncomplete(loop)
						end)
				end)
		end

		loop()
	elseif anim == "fast" then
		if self.scrollTween then
			self.scrollTween:stop()
			self.scrollTween = nil
		end
		
		self.scrollTween = flux.to(self, 2, {scrollSpeed = 30}):oncomplete(function() 
			self:anim("anim")
		end)
	elseif anim == "glitch" then
		self:startGlitch()
	end
end

function cbackground:update(dt)
	if not shuv.showBadColors then
		shuv.showBadColors = true
	end
	-- scrolling
	self.scrollx = self.scrollx - self.scrollSpeed * dt
	if self.scrollx <= -self.scrollW then
		self.scrollx = self.scrollx + self.scrollW
	end

	-- cooldown before next glitch
	if self.glitchCooldown > 0 then
		self.glitchCooldown = self.glitchCooldown - dt
	end

	-- glitch timer
	if self.glitchActive then
		self.glitchTimer = self.glitchTimer - dt
		if self.glitchTimer <= 0 then
			self.glitchActive = false
		end
	end
end

function cbackground:draw()
	local jitterX, jitterY = 0, 0

	if self.glitchActive then
		jitterX = love.math.random(-3, 3)
		jitterY = love.math.random(-2, 2)
	end

	if self.glitchActive then
		love.graphics.setColor(1, 0.8, 0.8)
	end

	love.graphics.draw(
		self.staticspr,
		self.staticx + jitterX,
		self.staticy + jitterY,
		0,
		1,
		1,
		self.staticox,
		self.staticoy
	)

	love.graphics.setColor(1, 1, 1)

	for i = 0, 1 do
		local x = self.scrollx + i * self.scrollW

		if self.glitchActive then
			-- rgb split
			love.graphics.setColor(1, 0, 0)
			love.graphics.draw(self.scrollspr, x + 2, self.scrolly, 0, 1, 1, 0, self.scrollspr:getHeight() / 2)

			love.graphics.setColor(0, 1, 1)
			love.graphics.draw(self.scrollspr, x - 2, self.scrolly, 0, 1, 1, 0, self.scrollspr:getHeight() / 2)
		end

		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(
			self.scrollspr,
			x + jitterX,
			self.scrolly + jitterY,
			0,
			1,
			1,
			0,
			self.scrollspr:getHeight() / 2
		)
	end

	love.graphics.setColor(1, 1, 1)
end

return cbackground
