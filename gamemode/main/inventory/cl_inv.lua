local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(oldw, oldh, nw, nh) w, h = nw, nh end)
local frame = nil
function Middle()
    if frame then return end
    frame = vgui.Create("DPanel")
    frame:SetSize(530, 418)
    frame:SetPos(w * 0.33, h * 0.38)
    frame.Paint = function(me)
            surface.SetMaterial(Material("materials/ui/background.png"))
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawTexturedRect(0, 0, w, h)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawRect(0, 0, w, h)
            DrawMotionBlur(0.5,0.2,0)
        end
    local grid = vgui.Create("ThreeGrid", frame)
    grid:Dock(FILL)
    grid:DockMargin(4, 4, 4, 4)
    grid:InvalidateParent(true)
    grid:SetColumns(6)
    grid:SetHorizontalMargin(2)
    grid:SetVerticalMargin(2)
    for i = 1, 30 do
        local pnl = vgui.Create("DPanel")
        pnl:SetTall(80)
        grid:AddCell(pnl)
        pnl.Paint = function(me)
            surface.SetMaterial(Material("materials/ui/background.png"))
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawTexturedRect(0, 0, w, h)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawRect(0, 0, w, h)
        end
    end
    return frame
end

function GM:ScoreboardShow()
    if not IsValid(frame) then Middle() end
end

function GM:ScoreboardHide()
    if IsValid(frame) then
        frame:Remove()
        frame = nil
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

local DPanel = {}
function Bottom()
    local Spacing = 10
    DPanel[1] = vgui.Create("DPanel")
    DPanel[1]:SetPos(FixedWidth(0.65, 20), h * 0.85)
    DPanel[1]:SetSize(80, 80)
    DPanel[2] = vgui.Create("DPanel")
    DPanel[2]:SetPos(FixedWidth(0.73, 40), h * 0.85)
    DPanel[2]:SetSize(80, 80)
    DPanel[3] = vgui.Create("DPanel")
    DPanel[3]:SetPos(FixedWidth(0.73, 125), h * 0.85)
    DPanel[3]:SetSize(80, 80)
    DPanel[4] = vgui.Create("DPanel")
    DPanel[4]:SetPos(FixedWidth(0.73, 210), h * 0.85)
    DPanel[4]:SetSize(80, 80)
    DPanel[5] = vgui.Create("DPanel")
    DPanel[5]:SetPos(FixedWidth(0.73, 295), h * 0.85)
    DPanel[5]:SetSize(80, 80)
    DPanel[6] = vgui.Create("DPanel")
    DPanel[6]:SetPos(FixedWidth(0.73, 380), h * 0.85)
    DPanel[6]:SetSize(80, 80)
    for i = 1, 6 do
        DPanel[i].Paint = function(me)
            surface.SetMaterial(Material("materials/ui/background.png"))
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawTexturedRect(0, 0, w, h)
            surface.SetDrawColor(94, 94, 94, 150)
            surface.DrawRect(0, 0, w, h)
        end
    end
end

Bottom()