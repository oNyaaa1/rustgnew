local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(oldw, oldh, nw, nh) w, h = nw, nh end)
function MoveSlot()
end

local frame = nil
local pnl = {}
local but = {}
local DPanel = {}
local slotData = {}
local NextSlot = {}
net.Receive("SendSlots", function() slotData = net.ReadTable() end)
-- example DoDrop, same one you use in Middle()
local function DoDrop(parentPanel, panels, bDoDrop)
    if not bDoDrop then return end
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

                if IsValid(but[i]) and but[i] ~= panel then
                    but[i]:Remove()
                    but[i] = nil
                end

                -- but[Slotidx] = vgui.Create('DImageButton')
                if IsValid(pnl[i]) then
                    but[i] = vgui.Create('DImageButton')
                    but[i]:SetImage("materials/items/tools/rock.png")
                    but[i]:Dock(FILL)
                    but[i]:SetParent(parentPanel)
                    but[i]:Droppable("myDNDname")
                end
            end

            -- reparent the panel so it visually sticks
            panel:SetParent(parentPanel)
            panel:Dock(FILL)
        end
    end

    net.Start("SaveSlots")
    net.WriteTable(slotData)
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

    for i = 1, #slotData do
        for k, v in pairs(slotData) do
            if IsValid(but[i]) and but[i] ~= pnl[i] then
                but[i]:Remove()
                but[i] = nil
            end

            if v.NumberOnBoard == nil then v.NumberOnBoard = 1 end
            if IsValid(pnl[v.NumberOnBoard]) and but[i] ~= pnl[i] then
                slotData[v.NumberOnBoard] = {
                    NumberOnBoard = v.NumberOnBoard,
                    model = v.model,
                    PanelType = v.PanelType,
                }

                but[v.NumberOnBoard] = vgui.Create('DImageButton')
                but[v.NumberOnBoard]:SetImage(v.model)
                but[v.NumberOnBoard]:Dock(FILL)
                but[v.NumberOnBoard]:SetParent(pnl[v.NumberOnBoard])
                but[v.NumberOnBoard]:Droppable("myDNDname")
            end
        end
    end

    net.Start("SaveSlots")
    net.WriteTable(slotData)
    net.SendToServer()
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