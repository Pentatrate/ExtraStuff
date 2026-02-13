RadialListStat = class("RadialListStat", OptionsList)

function RadialListStat:initialize(params)
    self.radius = project.res.cy
    self.topText = true
    self.circleWidth = 0

    self.activeArc    = math.pi
    self.iconDistance = math.pi/6

    self.control = {
        fwd  = "menu_right",
        back = "menu_left",
        inc  = "menu_up",
        dec  = "menu_down"
    }

    self.updateTransform = true

    self.tapRotate = 0

    -- Animated selection angle (interpolated via flux.to)
    self.animAngle   = 0
    self.targetAngle = 0

    self.icons = {
        main = {}
    }

    OptionsList.initialize(self, params)
end

function RadialListStat:recalcLayout()
    local count = #self.options[self.submenu]
    if count == 0 then return end
    self.iconDistance = (math.pi * 2) / count
    self.activeArc = math.pi + self.iconDistance * 0.5
end

function RadialListStat:slotAngle(i)
    return -math.pi / 2 + self.iconDistance * (i - 1)
end

-- Animate the selection indicator to the angle of slot i.
-- Chooses the shortest arc so it never spins the long way around.
function RadialListStat:animateToSlot(i)
    local target = self:slotAngle(i)
    -- Normalise current animated angle into [-π, π] relative to target
    local diff = ((target - self.animAngle) + math.pi) % (math.pi * 2) - math.pi
    self.targetAngle = self.animAngle + diff
    flux.to(self, 0.18, { animAngle = self.targetAngle })
        :ease("quadout")
end

function RadialListStat:addText(text, y, locvars, icon)
    table.insert(self.icons[self.submenu], icon or sprites.menu.fallback)
    OptionsList.addText(self, text, y, locvars)
    self:recalcLayout()
end

function RadialListStat:addOption(text, func, y, locvars, icon)
    table.insert(self.icons[self.submenu], icon or sprites.menu.fallback)
    OptionsList.addOption(self, text, func, y, locvars)
    self:recalcLayout()
end

function RadialListStat:addBoolean(text, object, value, y, func, icon)
    table.insert(self.icons[self.submenu], icon or sprites.menu.fallback)
    OptionsList.addBoolean(self, text, object, value, y, func)
    self:recalcLayout()
end

function RadialListStat:addNumber(text, object, value, y, increment, clamp, func, icon)
    table.insert(self.icons[self.submenu], icon or sprites.menu.fallback)
    OptionsList.addNumber(self, text, object, value, y, increment, clamp, func)
    self:recalcLayout()
end

function RadialListStat:addCustom(text, y, extraWidth, icon)
    table.insert(self.icons[self.submenu], icon or sprites.menu.fallback)
    OptionsList.addCustom(self, text, y, extraWidth)
    self:recalcLayout()
end

function RadialListStat:addColors(width, y, icon)
    table.insert(self.icons[self.submenu], icon or sprites.menu.fallback)
    OptionsList.addColors(self, width, y)
    self:recalcLayout()
end

function RadialListStat:addEnum(textStart, textValues, object, value, y, func, id, icon)
    table.insert(self.icons[self.submenu], icon or sprites.menu.fallback)
    OptionsList.addEnum(self, textStart, textValues, object, value, y, func, id)
    self:recalcLayout()
end

-- Returns the slot index (1-based) that the mouse is currently hovering over,
-- or nil if the cursor is not close enough to the ring.
function RadialListStat:hoveredSlot()
    if helpers.usingController() then return nil end

    local optionCount = #self.options[self.submenu]
    if optionCount == 0 then return nil end

    local mouseDist = helpers.distance({ mouse.rx, mouse.ry }, { self.x, self.y })
    local hitInner  = self.radius - self.circleWidth / 2
    local hitOuter  = self.radius + self.circleWidth / 2
    if self.circleWidth == 0 then
        hitInner = self.radius - 24
        hitOuter = self.radius + 24
    end

    if mouseDist < hitInner or mouseDist > hitOuter then return nil end

    local mouseAngle = math.atan2(mouse.ry - self.y, mouse.rx - self.x)
    local bestSlot   = nil
    local bestDiff   = math.huge

    for i = 1, optionCount do
        local slotAng = self:slotAngle(i)
        local diff    = ((mouseAngle - slotAng) % (math.pi * 2))
        if diff > math.pi then diff = math.pi * 2 - diff end
        if diff < bestDiff then
            bestDiff = diff
            bestSlot = i
        end
    end

    return bestSlot
end

function RadialListStat:update(dt)
    prof.push("RadialListStat update")

    self.tapRotate = (self.tapRotate + (dt or 0)) % 360

    if not self.allowInput then
        prof.pop("RadialListStat update")
        return
    end

    local moved          = false
    local oldSelection   = self.selection
    local optionCount    = #self.options[self.submenu]

    -- ── Keyboard / controller navigation ─────────────────────────────────────
    if maininput:pressed(self.control.back) then
        self.selection = self.selection - 1
        if self.options[self.submenu][((self.selection - 1) % optionCount) + 1] and
           self.options[self.submenu][((self.selection - 1) % optionCount) + 1].blocked then
            self.selection = self.selection - 1
        end
        moved = true
    end
    if maininput:pressed(self.control.fwd) then
        self.selection = self.selection + 1
        if self.options[self.submenu][((self.selection - 1) % optionCount) + 1] and
           self.options[self.submenu][((self.selection - 1) % optionCount) + 1].blocked then
            self.selection = self.selection + 1
        end
        moved = true
    end

    -- ── Mouse / touch navigation ──────────────────────────────────────────────
    local clickedOnItem = false

    if not helpers.usingController() then
        -- Scroll wheel
        if mouse.syInteger and mouse.syInteger ~= 0 then
            self.selection = self.selection - helpers.clamp(mouse.syInteger, -1, 1)
            moved = true
        end

        -- Hover-to-select: move the selection when the cursor slides over an icon
        local hovered = self:hoveredSlot()
        if hovered and hovered ~= self.selection then
            self.selection = hovered
            moved = true
        end

        -- Click to confirm (or click to jump if we somehow hit a different slot)
        if mouse.pressed == 1 then
            local mouseDist = helpers.distance({ mouse.rx, mouse.ry }, { self.x, self.y })
            local hitInner  = self.radius - self.circleWidth / 2
            local hitOuter  = self.radius + self.circleWidth / 2
            if self.circleWidth == 0 then
                hitInner = self.radius - 24
                hitOuter = self.radius + 24
            end

            if mouseDist >= hitInner and mouseDist <= hitOuter then
                local mouseAngle = math.atan2(mouse.ry - self.y, mouse.rx - self.x)

                local bestSlot = self.selection
                local bestDiff = math.huge
                for i = 1, optionCount do
                    local slotAng = self:slotAngle(i)
                    local diff = ((mouseAngle - slotAng) % (math.pi * 2))
                    if diff > math.pi then diff = math.pi * 2 - diff end
                    if diff < bestDiff then
                        bestDiff = diff
                        bestSlot = i
                    end
                end

                if bestSlot == self.selection then
                    clickedOnItem = true
                else
                    self.selection = bestSlot
                    moved = true
                end
            end
        end
    end

    -- Wrap selection and trigger animation when it changed
    self.selection = (self.selection - 1) % optionCount + 1

    if self.selection ~= oldSelection then
        if moved and not clickedOnItem then
            te.play(sounds.click, "static", 'sfx', 0.5)
        end
        self:animateToSlot(self.selection)
    end

    -- ── Option interaction ────────────────────────────────────────────────────
    local ranFunction = false
    local option      = self.options[self.submenu][self.selection]

    if maininput:pressed('accept') or clickedOnItem then
        if option.type == 'option' then
            te.play(sounds.hold, "static", 'sfx', 0.5)
            option.func()
            ranFunction = true
        elseif option.type == 'boolean' then
            te.play(sounds.hold, "static", 'sfx', 0.5)
            option.object[option.value] = not option.object[option.value]
            if option.func then option.func() end
        end
    end

    if option.type == 'boolean' then
        if maininput:pressed(self.control.inc) or maininput:pressed(self.control.dec) then
            te.play(sounds.hold, "static", 'sfx', 0.5)
            option.object[option.value] = not option.object[option.value]
            if option.func then option.func() end
        end
    end

    if option.type == 'number' then
        local changed = false
        if maininput:pressed(self.control.dec) then
            option.object[option.value] = option.object[option.value] - option.increment
            changed = true
        elseif maininput:pressed(self.control.inc) then
            option.object[option.value] = option.object[option.value] + option.increment
            changed = true
        end
        if changed then
            if option.clamp then
                option.object[option.value] = helpers.clamp(
                    option.object[option.value], option.clamp[1], option.clamp[2])
            end
            te.play(sounds.hold, "static", 'sfx', 0.5)
            option.width = fonts.digitalDisco:getWidth(
                self:numberSelectedText(loc.get(option.text, { option.object[option.value] })))
            self.width = option.width
            if option.func then option.func() end
        end
    end

    if option.type == 'custom' then
        local optionX = 0
        local changed = false
        if maininput:pressed(self.control.dec) then
            optionX = -1
            changed = true
        elseif maininput:pressed(self.control.inc) then
            optionX = 1
            changed = true
        end
        if changed or maininput:pressed('accept') or clickedOnItem then
            option:onInput(optionX)
        end
    end

    if option.type == 'enum' then
        local enumInt = 1
        for i, v in ipairs(option.textValues) do
            if v == option.object[option.value] then enumInt = i end
        end
        local changed = false
        if maininput:pressed(self.control.dec) then
            enumInt = enumInt - 1
            changed = true
        elseif maininput:pressed(self.control.inc) then
            enumInt = enumInt + 1
            changed = true
        end
        enumInt = ((enumInt - 1) % #option.textValues) + 1
        if changed then
            te.play(sounds.hold, "static", 'sfx', 0.5)
            option.object[option.value] = option.textValues[enumInt]
            if option.func then option.func() end
        end
    end

    prof.pop("RadialListStat update")
    return ranFunction
end

function RadialListStat:draw(x, y, r)
    prof.push("RadialListStat draw")

    if self.updateTransform then
        self.x      = x or self.x
        self.y      = y or self.y
        self.radius = r or self.radius
    end

    -- Use the animated angle (interpolated by flux) instead of the snapped slot angle
    local selectPos  = self.animAngle
    local sel_x      = self.x + math.cos(selectPos) * self.radius
    local sel_y      = self.y + math.sin(selectPos) * self.radius

    color(0)
    love.graphics.setLineWidth(self.circleWidth)
    love.graphics.circle("line", self.x, self.y, self.radius)

    color(1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", self.x, self.y, self.radius - self.circleWidth / 2)
    love.graphics.circle("line", self.x, self.y, self.radius + self.circleWidth / 2)

    local radius1 = 50 * (cs.logoZoom or 2)
    local radius2 = 60 * (cs.logoZoom or 2)

    love.graphics.push()
    color(1)
    love.graphics.translate(sel_x + 0.5, sel_y + 0.5)
    love.graphics.rotate(math.rad(self.tapRotate))
    love.graphics.rectangle('line', -radius1, -radius1, radius1 * 2 - 1, radius1 * 2 - 1)
    love.graphics.pop()

    love.graphics.push()
    color(1)
    love.graphics.translate(sel_x + 0.5, sel_y + 0.5)
    love.graphics.rotate(math.rad(-self.tapRotate))
    love.graphics.rectangle('line', -radius2, -radius2, radius2 * 2 - 1, radius2 * 2 - 1)
    love.graphics.pop()

    local optionCount = #self.options[self.submenu]
    for i = 1, optionCount do
        local icon    = self.icons[self.submenu][i]
        local v       = self.options[self.submenu][i]
        if not v then error(tostring(i)) end

        local drawPos = self:slotAngle(i)
        local ix      = self.x + math.cos(drawPos) * self.radius
        local iy      = self.y + math.sin(drawPos) * self.radius

        local textX = math.floor(ix - v.width * (.5 + math.cos(drawPos) / 2)
                                    - math.cos(drawPos) * icon:getWidth()  / 2)
        local textY = math.floor(iy - fonts.digitalDisco:getHeight() * (.5 + math.sin(drawPos) / 2)
                                    - math.sin(drawPos) * (icon:getHeight() + 2) / 2)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(icon, ix, iy, 0, 1, 1,
                           icon:getWidth() / 2, icon:getHeight() / 2)

        if self.allowInput then
            local isSelected = (self.selection == i)

            if v.type == "option" or v.type == "text" then
                color(isSelected and 1 or 0)
                love.graphics.rectangle("fill",
                    textX - 2, textY - 2,
                    v.width + 4, fonts.digitalDisco:getHeight() + 2, 4)
                color(isSelected and 0 or 1)
                love.graphics.print(v.text, textX, textY)

            elseif v.type == "boolean" then
                local text = v.object[v.value] and v.textTrue or v.textFalse
                love.graphics.print(v.text, textX, textY)

            elseif v.type == "number" then
            elseif v.type == "custom" then
            elseif v.type == "enum"   then
            elseif v.type == "color"  then
            end
        end
    end

    prof.pop("RadialListStat draw")
end

return RadialListStat