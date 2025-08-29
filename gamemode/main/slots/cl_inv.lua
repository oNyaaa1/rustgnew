local PANEL = {}
AccessorFunc(PANEL, "m_ItemPanel", "ItemPanel")
AccessorFunc(PANEL, "m_Color", "Color")
function PANEL:Init()
    self.m_Coords = {
        x = 0,
        y = 0
    }

    self:SetSize(30, 30)
    self:SetColor(Color(200, 200, 200))
    self:SetItemPanel(false)
    self:Receiver("invitem", function(pnl, item, drop, i, x, y)
        --Drag-drop functionality
        if drop then
            item = item[1]
            local x1, y1 = pnl:GetPos()
            local x2, y2 = item:GetPos()
            if math.Dist(x1, y1, x2, y2) <= 30 and not pnl:GetItemPanel() then --Find the top left slot.
                local itm = item:GetItem()
                local x, y = pnl:GetCoords()
                local itmw, itmh = itm:GetSize() --GetSize needs to be a function in your items system.
                local full = false
                for i1 = x, (x + itmw) - 1 do
                    if full then break end
                    for i2 = y, (y + itmh) - 1 do
                        if LocalPlayer():GetInvItem(i1, i2):GetItemPanel() then --check if the panels in the area are full.
                            full = true
                            break
                        end
                    end

                    if not full then --If none of them are full then
                        for i1 = x, (x + itmw) - 1 do
                            for i2 = y, (y + itmh) - 1 do
                                LocalPlayer():GetInvItem(i1, i2):SetItemPanel(item) -- Tell all the things below it that they are now full of this item.
                            end
                        end

                        item:SetRoot(pnl) --like a parent, but not a parent.
                        item:SetPos(pnl:GetPos()) --move the item.
                    end
                end
            end
        else
            --Something about coloring of hovered slots.
        end
    end, {})
end

function PANEL:SetCoords(x, y)
    self.m_Coords.x = x
    self.m_Coords.y = y
end

function PANEL:GetCoords()
    return self.m_Coords.x, self.m_Coords.y
end

local col
function PANEL:Paint(w, h)
    draw.NoTexture()
    col = self:GetColor()
    surface.SetDrawColor(col.r, col.g, col.b, 255)
    surface.DrawRect(0, 0, w - 2, h - 2) --main square
    surface.SetDrawColor(70, 70, 70, 255)
    surface.DrawRect(w - 2, 0, h, 2) --borders
    surface.DrawRect(0, h - 2, 2, w) -- ^
end

vgui.Register("InvSlot", PANEL, "DPanel")