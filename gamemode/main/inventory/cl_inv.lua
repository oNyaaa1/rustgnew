local w, h = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FixEdWidTh", function(oldw, oldh, nw, nh) w, h = nw, nh end)
function Middle()
end

function IsValidPanel(d)
    if type(d) == "Panel" then return true end
    return false
end

local DPanel = {}
function Bottom()
    local Panel = {}
    Panel.Amount = 6
    for i = 1, Panel.Amount do
        print(i)
        DPanel[i] = vgui.Create("DPanel")
        DPanel[i]:SetPos(w * 0.5 * i / 0.5, h * 0.85)
        DPanel[i]:SetSize(80, 80)
    end
end

Bottom()