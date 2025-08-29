local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(oldw, oldh, nw, nh) w, h = nw, nh end)
function Middle()
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
    DPanel[1]:SetPos(FixedWidth(0.7), h * 0.85)
    DPanel[1]:SetSize(80, 80)
    DPanel[2] = vgui.Create("DPanel")
    DPanel[2]:SetPos(FixedWidth(0.81), h * 0.85)
    DPanel[2]:SetSize(80, 80)
    DPanel[3] = vgui.Create("DPanel")
    DPanel[3]:SetPos(FixedWidth(0.82, 80), h * 0.85)
    DPanel[3]:SetSize(80, 80)
    DPanel[4] = vgui.Create("DPanel")
    DPanel[4]:SetPos(FixedWidth(0.82, 80 * 2 + Spacing), h * 0.85)
    DPanel[4]:SetSize(80, 80)
    DPanel[5] = vgui.Create("DPanel")
    DPanel[5]:SetPos(FixedWidth(0.82, 80 * 3 + Spacing + 10), h * 0.85)
    DPanel[5]:SetSize(80, 80)
    DPanel[6] = vgui.Create("DPanel")
    DPanel[6]:SetPos(FixedWidth(0.82, 80 * 4 + Spacing + 20), h * 0.85)
    DPanel[6]:SetSize(80, 80)
end

Bottom()