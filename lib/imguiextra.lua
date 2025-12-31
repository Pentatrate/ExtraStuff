imguiHelp = {}

local function swap(t, a, b)
    t[a], t[b] = t[b], t[a]
end

function imguiHelp.DrawReorderableList(imgui, items, list_id, size)
    list_id = list_id or "reorder"
	local bsize = size or {30, 16}

    for i = 1, #items do
        local label = items[i] .. "##" .. list_id .. "_" .. i

        imgui.Button(label, bsize)

        if imgui.BeginDragDropSource() then
            local payload = ffi.new("int[1]", i)
            imgui.SetDragDropPayload(
                "REORDER_ITEM",
                payload,
                ffi.sizeof(payload)
            )
            imgui.Text(items[i])
            imgui.EndDragDropSource()
        end

        if imgui.BeginDragDropTarget() then
            local payload = imgui.AcceptDragDropPayload("REORDER_ITEM")
            if payload ~= nil then
                local src = ffi.cast("int*", payload.Data)[0]
                if src ~= i then
                    swap(items, src, i)
                end
            end
            imgui.EndDragDropTarget()
        end
    end
end

local function swapRadialOption(list, a, b)
    swap(list.options[list.submenu], a, b)
    swap(list.icons[list.submenu], a, b)
end

function imguiHelp.DrawReorderableRadialList(imgui, radialList, list_id, buttonSize)
    list_id = list_id or "radialList"
    buttonSize = buttonSize or {120, 24}

    local options = radialList.options[radialList.submenu]
    local hiddenOptions = radialList.hiddenOptions or {}

    imgui.Text("Enabled Options")
    for i, opt in ipairs(options) do
        local label = opt.text .. "##" .. list_id .. "_enabled_" .. i
        imgui.Button(label, buttonSize)

        if imgui.BeginDragDropSource() then
            local payload = ffi.new("int[2]", {i, 0})
            imgui.SetDragDropPayload("REORDER_RADIAL_ITEM", payload, ffi.sizeof(payload))
            imgui.Text(opt.text)
            imgui.EndDragDropSource()
        end

        if imgui.BeginDragDropTarget() then
            local payload = imgui.AcceptDragDropPayload("REORDER_RADIAL_ITEM")
            if payload ~= nil then
                local data = ffi.cast("int*", payload.Data)
                local srcIndex = data[0]
                local srcHidden = data[1] == 1

                if srcHidden then
                    local id = hiddenOptions[srcIndex]._id
                    radialList:restoreHidden({id})
                elseif srcIndex ~= i then
                    swapRadialOption(radialList, srcIndex, i)
                end
            end
            imgui.EndDragDropTarget()
        end
    end

    imgui.Separator()
    imgui.Text("Hidden Options")

    if #hiddenOptions == 0 then
        local dummySize = {buttonSize[1], buttonSize[2]}
        imgui.InvisibleButton("EmptyHiddenTarget##"..list_id, dummySize)

        if imgui.BeginDragDropTarget() then
            local payload = imgui.AcceptDragDropPayload("REORDER_RADIAL_ITEM")
            if payload ~= nil then
                local data = ffi.cast("int*", payload.Data)
                local srcIndex = data[0]
                local srcHidden = data[1] == 1

                if not srcHidden and #options > 1 then
                    local id = options[srcIndex]._id
                    radialList:addHidden({id})
                end
            end
            imgui.EndDragDropTarget()
        end
    else
        for i, opt in ipairs(hiddenOptions) do
            local label = opt.text .. " (hidden)##" .. list_id .. "_hidden_" .. i
            imgui.Button(label, buttonSize)

            if imgui.BeginDragDropSource() then
                local payload = ffi.new("int[2]", {i, 1})
                imgui.SetDragDropPayload("REORDER_RADIAL_ITEM", payload, ffi.sizeof(payload))
                imgui.Text(opt.text)
                imgui.EndDragDropSource()
            end

            if imgui.BeginDragDropTarget() then
                local payload = imgui.AcceptDragDropPayload("REORDER_RADIAL_ITEM")
                if payload ~= nil then
                    local data = ffi.cast("int*", payload.Data)
                    local srcIndex = data[0]
                    local srcHidden = data[1] == 1

                    if srcHidden and srcIndex ~= i then
                        swap(hiddenOptions, srcIndex, i)
                    elseif not srcHidden and #options > 1 then
                        local id = options[srcIndex]._id
                        radialList:addHidden({id})
                    end
                end
                imgui.EndDragDropTarget()
            end
        end
    end
end

local function find_value(tbl, val_to_find)
    for key, value in pairs(tbl) do
        if value == val_to_find then
            return key
        end
    end
    return nil
end

function imguiHelp.Dropdown(label, positions, currentValue)
    local selectedIndex = find_value(positions, currentValue) or 1

    imgui.Text(label)

    if imgui.BeginCombo("##" .. label, positions[selectedIndex], true) then
        for i, pos in ipairs(positions) do
            local disabled = (selectedIndex == i)

            if disabled then
                imgui.BeginDisabled()
            end

            if imgui.Button(pos) then
                selectedIndex = i
            end

            if disabled then
                imgui.EndDisabled()
            end
        end
        imgui.EndCombo()
    end

    return positions[selectedIndex]
end

return imguiHelp