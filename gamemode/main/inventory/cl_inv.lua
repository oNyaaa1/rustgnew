local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(oldw, oldh, nw, nh) w, h = nw, nh end)
function MoveSlot()
end

local frame = nil
local pnl = {}
local but = {}
local DPanel = {}
local slotData = {}
local function ApplySavedSlots(data)
    if not data then return end
    for slotIndex, buttonIndex in pairs(data) do
        if pnl[slotIndex] and but[buttonIndex] then
            but[buttonIndex]:SetParent(pnl[slotIndex])
            but[buttonIndex]:Dock(FILL)
        end
    end
end

local temp_Tbl = {}
-- example DoDrop, same one you use in Middle()
local function DoDrop(parentPanel, panels, bDoDrop)
    if not bDoDrop then return end
    temp_Tbl = temp_Tbl or {}
    panels[1]:SetParent(parentPanel)
    for _, panel in ipairs(panels) do
        -- find DPanel index
        local dpanelIndex = table.KeyFromValue(DPanel, parentPanel) or 0
        local dpanelIndex2 = table.KeyFromValue(pnl, parentPanel) or 0
        for i = 1, #pnl do
            if but[i] == panel or DPanel[i] == panel then
                if dpanelIndex > 0 then
                    temp_Tbl[i] = {
                        Slots = i,
                        NumberOnBoard = dpanelIndex,
                    }
                elseif dpanelIndex2 > 0 then
                    temp_Tbl[i] = {
                        Slots = i,
                        NumberOnBoard = dpanelIndex2,
                    }
                end
            end
        end
    end

    --PrintTable(temp_Tbl)
    net.Start("SaveSlots")
    net.WriteTable(temp_Tbl)
    net.SendToServer()
end

-- helper function
function table.KeyFromValue(tab, val)
    for k, v in pairs(tab) do
        if v == val then return k end
    end
    return nil
end

function Middle()
    if frame then return end
    frame = vgui.Create("DPanel")
    frame:SetSize(530, 418)
    frame:SetPos(w * 0.34, h * 0.38)
    frame.Paint = function(me)
        surface.SetMaterial(Material("materials/ui/background.png"))
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(94, 94, 94, 150)
        surface.DrawRect(0, 0, w, h)
    end

    local grid = vgui.Create("ThreeGrid", frame)
    grid:Dock(FILL)
    grid:DockMargin(4, 4, 4, 4)
    grid:InvalidateParent(true)
    grid:SetColumns(6)
    grid:SetHorizontalMargin(2)
    grid:SetVerticalMargin(2)
    -- Define restricted numbers
    for i = 1, 30 do
        pnl[i] = vgui.Create("DPanel")
        pnl[i]:SetTall(80)
        pnl[i]:Receiver("myDNDname", DoDrop)
        grid:AddCell(pnl[i])
        pnl[i].Paint = function(me)
            surface.SetMaterial(Material("materials/ui/background.png"))
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawTexturedRect(0, 0, w, h)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawRect(0, 0, w, h)
        end
    end

    for k, v in pairs(slotData) do
        if not IsValid(but[v.Slots]) then
            but[v.Slots] = vgui.Create("DButton")
            but[v.Slots]:SetText(v.Slots)
            but[v.Slots]:Dock(FILL)
            but[v.Slots]:Droppable("myDNDname")
            but[v.Slots]:SetParent(pnl[v.NumberOnBoard])
        end
    end
end

net.Receive("SendSlots", function()
    slotData = net.ReadTable() or {}
    net.Start("RequestSlots")
    net.SendToServer()
    --ApplySavedSlots(slotData)
    --Bottom()
end)

function GM:ScoreboardShow()
    if not IsValid(frame) then
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
    -- clear old slots
    for i = 1, #DPanel do
        if IsValid(DPanel[i]) then DPanel[i]:Remove() end
    end

    DPanel = {}
    -- create 6 slots
    for i = 1, 6 do
        DPanel[i] = vgui.Create("DPanel")
        DPanel[i]:SetSize(80, 80)
        DPanel[i]:SetPos(w * 0.35 + ((i - 1) * 85), h * 0.85) -- spaced horizontally
        DPanel[i].Paint = function(me, w, h)
            surface.SetMaterial(Material("ui/background.png"))
            surface.SetDrawColor(255, 255, 255, 40)
            surface.DrawTexturedRect(0, 0, w, h)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        DPanel[i]:Receiver("myDNDname", DoDrop)
    end
end

Bottom()