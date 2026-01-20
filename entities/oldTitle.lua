oldTitle = class('oldTitle', Entity)

function oldTitle:initialize(params)
  self.layer = -100      -- draw behind everything
  self.upLayer = -100    -- update early
  self.x = 0    -- update early
  self.y = 0    -- update early

  self.i = 0
  self.pstext = loc.get("pressspace")

  Entity.initialize(self, params)
end

function oldTitle:update(dt)
  self.i = self.i + 1

  if self.i % 2 == 0 then
    em.init("TitleParticle", {
      x = math.random(-8, 608),
      y = -8,
      dx = (math.random() * 2) - 1,
      dy = 2 + math.random() * 2
    })
  end
end

function oldTitle:draw()
end

return oldTitle
