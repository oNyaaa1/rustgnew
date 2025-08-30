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

net.Receive("SendSlots", function()
    slotData = net.ReadTable()
    NextSlot = slotData or {}
end)

-- helper function
function table.KeyFromValue(tab, val)
    for k, v in pairs(tab) do
        if v == val then return k end
    end
    return nil
end

local oldSlotIdx = 0
local function DoDrop(parentPanel, panels, bDoDrop)
    if not bDoDrop then return end
    local midIndex = table.KeyFromValue(pnl, parentPanel) or 0
    local botIndex = table.KeyFromValue(DPanel, parentPanel) or 0
    local Slotidx = midIndex > 0 and midIndex or (botIndex > 0 and (botIndex + 30) or 1)
    for _, panel in ipairs(panels) do
        panel:SetParent(parentPanel)
        panel:Dock(FILL)
        NextSlot[Slotidx] = {
            NumberOnBoard = Slotidx,
            model = "materials/items/tools/rock.png",
            PanelType = midIndex > 0 and "pnl" or "DPanel",
            LastSlot = oldSlotIdx,
        }

        but[Slotidx] = panel
    end

   
    for i = 1, #NextSlot do
        NextSlot[oldSlotIdx] = {}
        NextSlot[oldSlotIdx] = nil
    end

    oldSlotIdx = Slotidx
    --PrintTable(NextSlot)
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