local PANEL = {}

AccessorFunc(PANEL, "m_Item", "Item")
AccessorFunc(PANEL, "m_Root", "Root")

function PANEL:Init()
     self:SetSize(30,30)
     self:SetItem(false) --false means no item.
     self:SetColor(Color(100,100,100))
     self:SetDroppable("invitem")
end

function PANEL:PaintOver(w,h)
     draw.NoTexture()
     if self:GetItem() then
          surface.SetMaterial(self:GetItem():GetIcon()) --Your items must have a GetIcon method.
          surface.DrawTexturedRect(0,0,w,h)
     end
end

local col
function PANEL:Paint(w,h)
     draw.NoTexture()
     col = self:GetColor()
     surface.SetDrawColor(col.r,col.g,col.b,180)
     surface.DrawRect(0,0,w,h) --background square
end
vgui.Register("InvItem", PANEL, "DPanel")