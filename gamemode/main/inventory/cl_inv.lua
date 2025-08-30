local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(oldw, oldh, nw, nh) w, h = nw, nh end)
local frame = nil
local pnl = {}
local but = {}
local DPanel = {}
local slotData = {}
local NextSlot = {}
-- Function to clear all buttons
local function ClearAllButtons()
    for i = 1, 50 do -- Clear more than needed to be safe
        if IsValid(but[i]) then
            but[i]:Remove()
            but[i] = nil
        end
    end
end

-- Function to populate slots from NextSlot data
local function PopulateSlots()
    ClearAllButtons() -- Always clear first
    for _, v in pairs(NextSlot) do
        if v.NumberOnBoard then
            local slotNum = v.NumberOnBoard
            local parentPanel = nil
            -- Determine which parent panel to use
            if slotNum <= 30 and IsValid(pnl[slotNum]) then
                parentPanel = pnl[slotNum]
            elseif slotNum > 30 and IsValid(DPanel[slotNum - 30]) then
                parentPanel = DPanel[slotNum - 30]
            end

            -- Create button only if we have a valid parent
            if parentPanel then
                but[slotNum] = vgui.Create('DImageButton')
                but[slotNum]:SetImage(v.model or "materials/items/tools/rock.png")
                but[slotNum]:Dock(FILL)
                but[slotNum]:SetParent(parentPanel)
                but[slotNum]:Droppable("myDNDname")
            end
        end
    end
end

-- Network receive - this is where duplication was happening
net.Receive("SendSlots", function()
    slotData = net.ReadTable()
    NextSlot = slotData or {}
    -- Always populate when we receive data, regardless of UI state
    -- This ensures we have the latest data when UI opens
    if IsValid(frame) and #pnl > 0 and #DPanel > 0 then PopulateSlots() end
end)

-- helper function
function table.KeyFromValue(tab, val)
    for k, v in pairs(tab) do
        if v == val then return k end
    end
    return nil
end

-- example DoDrop, same one you use in Middle()
local function DoDrop(parentPanel, panels, bDoDrop)
    if not bDoDrop then return end
    table.Empty(NextSlot)
    local midIndex = table.KeyFromValue(pnl, parentPanel) or 0
    local botIndex = table.KeyFromValue(DPanel, parentPanel) or 0
    -- figure out which slot this panel used to belong to
    local Slotidx = midIndex > 0 and midIndex or (botIndex > 0 and (botIndex + 30) or 1)
    for _, panel in ipairs(panels) do
        if panel.oldSlotIdx == nil then panel.oldSlotIdx = 0 end
        -- find which slot we dropped into
        -- Find the old slot this panel came from
        -- Remove any existing panel in the target slot
        if IsValid(but[Slotidx]) then
            but[Slotidx]:Remove()
            but[Slotidx] = nil
        end

        -- Update NextSlot - remove old entry if it exists
        -- Add new slot data
        NextSlot[Slotidx] = {
            NumberOnBoard = Slotidx,
            model = "materials/items/tools/rock.png",
            PanelType = midIndex > 0 and "pnl" or "DPanel",
            LastSlot = panel.oldSlotIdx,
        }

        -- reparent the panel so it visually sticks
        panel:SetParent(parentPanel)
        panel:Dock(FILL)
        but[Slotidx] = panel
        panel.oldSlotIdx = Slotidx
        if panel.oldSlotIdx > 0 then
            for i = #NextSlot, 1, -1 do
                if i == panel.oldSlotIdx then table.remove(NextSlot, panel.oldSlotIdx) end
            end
        end
    end

    PrintTable(NextSlot)
    net.Start("SaveSlots")
    net.WriteTable(NextSlot)
    net.SendToServer()
end

function Middle(data)
    if frame then return end
    frame = vgui.Create("DPanel")
    frame:SetSize(530, 418)
    frame:SetPos(w * 0.34, h * 0.38)
    frame.Paint = function(me, fw, fh)
        surface.SetMaterial(Material("materials/ui/background.png"))
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRect(0, 0, fw, fh)
        surface.SetDrawColor(94, 94, 94, 150)
        surface.DrawRect(0, 0, fw, fh)
    end

    local grid = vgui.Create("ThreeGrid", frame)
    grid:Dock(FILL)
    grid:DockMargin(4, 4, 4, 4)
    grid:InvalidateParent(true)
    grid:SetColumns(6)
    grid:SetHorizontalMargin(2)
    grid:SetVerticalMargin(2)
    -- Create empty slots only
    for i = 1, 30 do
        if not IsValid(pnl[i]) then
            pnl[i] = vgui.Create("DPanel")
            pnl[i]:SetTall(80)
            pnl[i]:Receiver("myDNDname", DoDrop)
            grid:AddCell(pnl[i])
            pnl[i].Paint = function(me, pw, ph)
                surface.SetMaterial(Material("materials/ui/background.png"))
                surface.SetDrawColor(0, 0, 0, 100)
                surface.DrawTexturedRect(0, 0, pw, ph)
                surface.SetDrawColor(94, 94, 94, 150)
                surface.DrawRect(0, 0, pw, ph)
            end
        end
    end
    -- Don't populate here - wait for network data
end

function GM:ScoreboardShow()
    if not IsValid(frame) then
        net.Start("RequestSlots")
        net.SendToServer()
        Middle()
        gui.EnableScreenClicker(true)
    end
end

function GM:ScoreboardHide()
    if IsValid(frame) then
        frame:Remove()
        frame = nil
        gui.EnableScreenClicker(false)
    end

    -- Clean up bottom panels
    ClearAllButtons()
end

local function FixedWidth(ww, ex)
    ex = ex or 0
    return w / 2 * ww + ex
end

local function IsValidPanel(d)
    if type(d) == "Panel" then return true end
    return false
end

function Bottom()
    local h = ScrH()
    local w = ScrW()
    -- clear old NumberOnBoard
    for i = 1, #DPanel do
        if IsValid(DPanel[i]) then DPanel[i]:Remove() end
    end

    DPanel = {}
    -- create 6 NumberOnBoard
    for i = 1, 6 do
        DPanel[i] = vgui.Create("DPanel")
        DPanel[i]:SetSize(80, 80)
        DPanel[i]:SetPos(w * 0.35 + ((i - 1) * 85), h * 0.85) -- spaced horizontally
        DPanel[i].Paint = function(me, pw, ph)
            surface.SetMaterial(Material("materials/ui/background.png"))
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawTexturedRect(0, 0, pw, ph)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawRect(0, 0, pw, ph)
        end

        DPanel[i]:Receiver("myDNDname", DoDrop)
    end
    -- Don't populate here - PopulateSlots() will handle it
end

Bottom()