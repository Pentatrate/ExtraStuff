chimaeraBoss = class('chimaeraBoss', Entity)

function chimaeraBoss:initialize(params)
	self.ogx = 467
	self.ogy = 153
	self.x = self.ogx
	self.y = self.ogy
	self.ox = 83.5
	self.oy = 76.5
	self.s = 2
	
	self.alpha = 1
	self.spr0 = sprites.fight.chimaera0
	self.spr1 = sprites.fight.chimaera1
	self.spr = self.spr1
	self.name = "Chimaera"
	
	self.attacks = {
		bite = {
			name = "Bite",
			damage = 12,
			stunChance = 0.25,
			duration = 30,
			block = 0.18,
			parry = 0.07,
			counter = 0.025,
		},

		charge = {
			name = "Charge",
			damage = 20,
			stunChance = 0.45,
			duration = 35,
			block = 0.14,
			parry = 0.05,
			counter = 0.02,
		},

		feint = {
			name = "Feint",
			damage = 8,
			stunChance = 0.15,
			
			duration = 35,
			block = 0.12,
			parry = 0.04,
			counter = 0.015,
		},
		swipe = {
			name = "Swipe",
			damage = 6,
			stunChance = 0.1,
			duration = 25,
			block = 0.25,
			parry = 0.1,
			counter = 0.03
		}
	}
	
	self.hp = 66666 --ok this might be ridiculous, if you do 30 damage and counter for 20 damage every turn (as a second) it would take 22.22 minutes
	self.dead = false
	self.readyForDelete = false
	
	self.roaring = false
	self.hurtTimer = 0
	self.roarTimer = 0
	self.roarDuration = 36
	self.roarShakeTime = 0
	self.idleTimes = 0
	Entity.initialize(self, params)
end

function chimaeraBoss:anim(anim)
	if anim == "startFight" then
		self:anim("roar")
	end

	if anim == "roar" then
		self.spr = self.spr0
		self.roaring = true
		self.roarTimer = 0
		self.roarShakeTime = 0
	elseif anim == "idle" then
		self.roaring = false
		self.x = self.ogx
		self.y = self.ogy
		self.spr = self.spr1
	elseif anim == "hurt" then
		self.hurtTimer = 20
	elseif anim == "death" then
		self.dead = true
		self.x = self.ogx + math.sin(self.roarTimer * 40) * 4
		self.alpha = self.alpha - 0.01
	end
end

function chimaeraBoss:update(dt)
	self.y = self.ogy
	self.x = self.ogx
	if self.roaring then
		self.roarTimer = self.roarTimer + dt
		self.roarShakeTime = self.roarShakeTime + dt

		if self.roarShakeTime >= 3 then
			self.roarShakeTime = 0
			self.idleTimes = self.idleTimes + 1

			self.x = self.ogx + math.sin(self.roarTimer * 40) * 4
		end

		if self.roarTimer >= self.roarDuration then
			self:anim("idle")
		end
	end
	
	if self.hurtTimer > 0 then
		self.hurtTimer = self.hurtTimer - dt
		self.y = self.ogy + math.sin(self.hurtTimer * 40) * 5
	end
	
	if self.hp <= 0 then
		self:anim("death")
	end
end

function chimaeraBoss:draw()
	love.graphics.setColor(1,1,1,self.alpha)
    love.graphics.draw(self.spr, self.x, self.y, 0, self.s, self.s, self.ox, self.oy)
	
end

return chimaeraBoss
