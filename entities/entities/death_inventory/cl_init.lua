include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

net.Receive("ent_close", function()
    if IsValid(inventory.Menu) then inventory.Menu:Remove() end
end)

net.Receive("ent_open", function()
    local ply = LocalPlayer()

    local plyinv = net.ReadTable()
    if not plyinv then return end
    if IsValid(inventory.Menu) then inventory.Menu:Remove() end

    local scrw, scrh = ScrW(), ScrH()
    local height = 40
    inventory.Menu = vgui.Create("DFrame")
    inventory.Menu:SetSize(scrw * 0.5, scrh * 0.6)
    inventory.Menu:Center()
    inventory.Menu:SetTitle("")
    inventory.Menu:MakePopup(true)
    inventory.Menu:SetDraggable(true)
    inventory.Menu:ShowCloseButton(false)
    inventory.Menu.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 220)
        surface.DrawRect(0, 0, w, h)
        surface.DrawRect(0, 0, w, height)
        if config.max >= 0 then 
            draw.SimpleText("Death Inventory" .. tostring(number_item) .. "/" .. tostring(config.max), "Prototype_sb_42", 10, 2, Color(255, 255, 255),  TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        else 
            draw.SimpleText("Death Inventory ", "Prototype_sb_42", 10, 2, Color(255, 255, 255),  TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        end
    end

    local x, y = inventory.Menu:GetSize()

    local posX_scroll = 20
    local posY_scroll = 60

    local scroll = vgui.Create("DScrollPanel", inventory.Menu)
    scroll:SetSize(inventory.Menu:GetWide() - posX_scroll * 2, inventory.Menu:GetTall() - height * 2)
    scroll:SetPos(scroll:GetX() + posX_scroll, scroll:GetY() + posY_scroll)

    local sbar = scroll:GetVBar()
    function sbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
    end
    function sbar.btnUp:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255))
    end
    function sbar.btnDown:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255))
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255))
    end 

    local panel_setting

    local buttonClose = vgui.Create("DButton", inventory.Menu)
    buttonClose:SetText("")
    buttonClose:SetSize(60, 25)
    buttonClose:DockMargin(10, 10, 10 ,10)
    buttonClose:SetPos(x - 65, 7)
    buttonClose.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("X", "Prototype_sb_28", w / 2, h / 2, Color(200, 0, 0),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    buttonClose.DoClick = function()
        inventory.Menu:Close()
        if IsValid(panel_setting) then panel_setting:Close() end
    end

    local button_setting = vgui.Create("DButton", inventory.Menu)
    button_setting:SetText("")
    button_setting:SetSize(25, 25)
    button_setting:DockMargin(10, 10, 10 ,10)
    button_setting:SetPos(x - 95, 7)
    button_setting.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("+", "Prototype_sb_28", w / 2, h / 2, Color(200, 200, 200),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    button_setting.DoClick = function()
        if IsValid(panel_setting) then panel_setting:Close() end

        panel_setting = vgui.Create("DFrame")
        panel_setting:SetSize(x * 0.5, y * 0.7)
        panel_setting:Center()
        panel_setting:SetTitle("")
        panel_setting:MakePopup(true)
        panel_setting:SetDraggable(true)
        panel_setting:ShowCloseButton(false)
        panel_setting.Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 220)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("Key for open inventory", "Prototype_sb_28", 180, 45, Color(255, 255, 255))
            draw.SimpleText("Key for take item in inventory", "Prototype_sb_28", 180, 85, Color(255, 255, 255))
        end
        local button_open = vgui.Create("DBinder", panel_setting)
        button_open:SetSize(150, 30)
        button_open:SetPos(20, 40)
        button_open:SetValue(key_open)
        button_open:SetFont("Prototype_sb_28")
        button_open.Paint = function(self, w, h)
            surface.SetDrawColor(200, 200, 200, 255)
            surface.DrawRect(0, 0, w, h)
        end
        function button_open:OnChange(num)
            key_open = num
            net.Start("key_new")
            net.WriteString("key_open," .. num)
            net.SendToServer()
        end

        local button_take = vgui.Create("DBinder", panel_setting)
        button_take:SetSize(150, 30)
        button_take:SetPos(20, 80)
        button_take:SetValue(key_take)
        button_take:SetFont("Prototype_sb_28")
        button_take.Paint = function(self, w, h)
            surface.SetDrawColor(200, 200, 200, 255)
            surface.DrawRect(0, 0, w, h)
        end
        function button_take:OnChange(num)
            key_take = num
            net.Start("key_new")
            net.WriteString("key_take," .. num)
            net.SendToServer()
        end
        local button_close_setting = vgui.Create("DButton", panel_setting)
        button_close_setting:SetText("")
        button_close_setting:SetSize(60, 25)
        button_close_setting:SetPos(x * 0.5 - 60, 0)
        button_close_setting.Paint = function(self, w, h)
            surface.SetDrawColor(200, 200, 200, 255)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("X", "Prototype_sb_28", w / 2, h / 2, Color(0, 0, 0),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        button_close_setting.DoClick = function()
            panel_setting:Close()
        end
    end

    local size = config.size
    if config.relative_item then size = x * (config.relative_size / 10) end
    local number_case_by_line = math.floor(((x * 0.9) / size))  
    local clicked = false
    local x_item = config.x_item
    local y_item = config.y_item
    local gap_x = config.gap_x
    local gap_y = config.gap_y
    local name
    local takeButton
    local item_clicked

    local i = 0
    for k, itemData in pairs(plyinv) do

        i = i + 1
        local itemPanel = vgui.Create("DButton", scroll)
        itemPanel:SetSize(size, size)
        itemPanel:SetPos(x_item, y_item)
        itemPanel:SetText("")
        x_item = x_item + size + gap_x
        if (i % number_case_by_line == 0) then
            y_item = y_item + size + gap_y
            x_item = 0
        end
        itemPanel.Paint = function(self, w, h)
            surface.SetDrawColor(200, 200, 200, 200)
            surface.DrawRect(0, 0, w, 2)
            surface.DrawRect(0, 0, 2, h)
            surface.DrawRect(w - 2, 0, w, h)
            surface.DrawRect(0, h - 2, w, h)
            surface.SetDrawColor(0, 0, 0, 225)
            surface.DrawRect(2, 2, w - 4, h - 4)
        end

        itemPanel.DoClick = function()
            if clicked then 
                if IsValid(name) then name:Remove() end
                if IsValid(takeButton) then takeButton:Remove() end
                clicked = false     
                if (item_clicked == k) then return end
            end
            item_clicked = k
            clicked = true

            if itemData.name then
                local x, y = itemPanel:GetPos()
                name = vgui.Create("DPanel", itemPanel)
                name:SetText(itemData.name)
                local width = 10 + string.len(itemData.name) * 5
                name:SetSize(width, 20)
                name:Center()
                name.Paint = function(self, w, h)
                    surface.SetDrawColor(255, 255, 255, 10)
                    surface.DrawRect(0, 0, w, h)
                    draw.SimpleText(itemData.name, "Prototype_sb_14", w / 2, h / 2, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end

        itemPanel.DoRightClick = function()
            if clicked then 
                if IsValid(name) then name:Remove() end
                if IsValid(takeButton) then takeButton:Remove() end
                clicked = false     
                if (item_clicked == k) then return end
            end
            clicked = true
            item_clicked = k

            takeButton = vgui.Create("DButton", itemPanel)
            takeButton:SetSize(60, 30)
            takeButton:Center()
            takeButton:SetPos(takeButton:GetX(), takeButton:GetY())
            takeButton:SetText("")
            takeButton.Paint = function(self, w, h)
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawRect(0, 0, w, h)
                draw.SimpleText("Take", "Prototype_sb_28", w / 2, h / 2, Color(255, 255, 255),  TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            takeButton.DoClick = function()
                net.Start("ent_take")
                net.WriteInt(k, 32)
                net.SendToServer()
                takeButton:Remove()
            end
 
        end

        local icon = vgui.Create( "DModelPanel", itemPanel)
        icon:SetSize(size, size)
        icon:SetModel(itemData.model)
        icon:SetMouseInputEnabled( false )
        icon.Entity:SetPos(icon.Entity:GetPos() - Vector(2, 1, -1))

        local num = 0.5
        local min, max = icon.Entity:GetRenderBounds()
        icon:SetCamPos(min:Distance(max) * Vector(num, num, num))
        icon:SetLookAt((max + min) / 2)

        function icon:LayoutEntity( Entity ) return end
        
    end
end)