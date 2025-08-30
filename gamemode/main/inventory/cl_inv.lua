local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(oldw, oldh, nw, nh) w, h = nw, nh end)
function MoveSlot()
end

local frame = nil
local pnl = {}
local but = {}
local DPanel = {}
local slotData = {}
local temp_Tbl = {}
local NextSlot = {}
net.Receive("SendSlots", function() slotData = net.ReadTable() or {} end)
-- example DoDrop, same one you use in Middle()
local function DoDrop(parentPanel, panels, bDoDrop)
    if not bDoDrop then return end
    temp_Tbl = temp_Tbl or {}
    for _, panel in ipairs(panels) do
        -- find which slot we dropped into
        local midIndex = table.KeyFromValue(pnl, parentPanel) or 0
        local botIndex = table.KeyFromValue(DPanel, parentPanel) or 0
        -- figure out which slot this panel used to belong to
        local Slotidx = midIndex > 0 and midIndex or botIndex > 0 and botIndex or 1
        for i = 1, #pnl do
            if but[i] == panel then
                slotData[Slotidx] = {
                    NumberOnBoard = Slotidx,
                    model = "materials/items/tools/rock.png",
                    PanelType = midIndex > 0 and "pnl" or "DPanel",
                }

                if IsValid(but[Slotidx]) then but[Slotidx]:SetParent(Slotidx) end
            end

            -- reparent the panel so it visually sticks
            panel:SetParent(parentPanel)
            panel:Dock(FILL)
        end
    end

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

function Middle(data)
    net.Start("RequestSlots")
    net.SendToServer()
    if not slotData then return end
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
        if not IsValid(pnl[i]) then
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
    end

    for k, v in pairs(slotData) do
        if v.Slots == nil then v.Slots = 1 end
        but[v.Slots] = vgui.Create('DImageButton')
        but[v.Slots]:SetImage(v.model)
        but[v.Slots]:Dock(FILL)
        but[v.Slots]:SetParent(pnl[v.NumberOnBoard])
        but[v.Slots]:Droppable("myDNDname")
    end
end

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
            surface.SetMaterial(Material("materials/ui/background.png"))
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawTexturedRect(0, 0, w, h)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawRect(0, 0, w, h)
        end

        DPanel[i]:Receiver("myDNDname", DoDrop)
    end
end

Bottom()