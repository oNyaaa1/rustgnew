local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(oldw, oldh, nw, nh) w, h = nw, nh end)
local frame = nil
local pnl = {}
local but = {}
local DPanel = {}
local slotData = {}
local NextSlot = {}
local btn = {}

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
local ParentPanel2 = nil
local function DoDrop(parentPanel, panels, bDoDrop)
    if not bDoDrop then return end
    parentPanel2 = parentPanel
    
    for _, panel in ipairs(panels) do
        panel:SetParent(parentPanel)
        panel:Dock(FILL)
    end

    for i = 1, 55 do
        if IsValid(but[i]) then
            but[i]:Remove()
            but[i] = nil
        end
    end

    for i = 1, 30 do
        if Slotidx ~= i then table.remove(NextSlot, i) end
    end
    net.Start("SaveSlots")
    net.WriteTable(slotData)
    net.SendToServer()
    oldSlotIdx = Slotidx
end

local MyTime = 0
function UpdateSus()
    if CurTime() < MyTime then return end
    MyTime = CurTime() + 5
    for k, v in pairs(slotData) do
        for i = 1, 30 do
            if v.NumberOnBoard == i then
                -- Create the button
                btn[i] = vgui.Create("DImageButton")
                btn[i]:SetImage("materials/items/tools/rock.png")
                btn[i]:Dock(FILL)
                btn[i]:Droppable("myDNDname")
                btn[i].DoClick = function()
                    net.Start("DropASlot")
                    net.WriteString("rust_rocknew")
                    net.SendToServer()
                end

                print(v.Bar)
                -- Parent to the correct slot type
                if v.PanelType == "pnl" and IsValid(pnl[v.NumberOnBoard]) then
                    btn[i]:SetParent(pnl[v.NumberOnBoard])
                    -- clear the matching DPanel slot at this index
                end

                if v.PanelType == "DPanel" and IsValid(DPanel[v.NumberOnBoard]) then
                    btn[i]:SetParent(DPanel[v.NumberOnBoard])
                    -- clear the matching pnl slot at this index
                end
            end
        end
    end
    gui.EnableScreenClicker(true)
end
timer.Simple(5, function() UpdateSus() end)
local function UpdateBtn()
    for i = 1, 55 do
        if IsValid(but[i]) then
            but[i]:Remove()
            //but[i] = nil
        end
    end
end

function Bottom()
    -- clear old NumberOnBoard
    -- create 6 NumberOnBoard
    for i = 1, 6 do
        if not IsValid(DPanel[i]) then
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
    end
    -- Don't populate here - PopulateSlots() will handle it
end

Bottom()

function Middle(fe)
    if not fe then return end
    fe:Show()
    UpdateSus()
    timer.Create("update", 0.02, 0, function()
        if IsValid(fe) then
            if fe:IsVisible() then 
                UpdateBtn()
                gui.EnableScreenClicker(true) 
            end
        end
    end)

    gui.EnableScreenClicker(true)
end

function GM:ScoreboardShow()
    if not frame then
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
    net.Start("RequestSlots")
    net.SendToServer()
    Middle(frame)
end

function GM:ScoreboardHide()
    if IsValid(frame) then
        frame:Hide()
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

