-- Network strings
util.AddNetworkString("SaveSlots")
util.AddNetworkString("RequestSlots")
util.AddNetworkString("SendSlots")
util.AddNetworkString("DropASlot")
-- Directory for slot data
local slotDir = "slots"
if not file.IsDir(slotDir, "DATA") then file.CreateDir(slotDir) end
-- Save player slots to file
local function SavePlayerSlots(ply, data)
    local sid = ply:SteamID64()
    if not sid then return end
    file.Write(slotDir .. "/" .. sid .. ".txt", util.TableToJSON(data, true))
end

-- Load player slots from file
local function LoadPlayerSlots(ply)
    local sid = ply:SteamID64()
    if not sid then return {} end
    local path = slotDir .. "/" .. sid .. ".txt"
    if file.Exists(path, "DATA") then return util.JSONToTable(file.Read(path, "DATA")) or {} end
    return {}
end

-- Receive slots from client and save
net.Receive("SaveSlots", function(len, ply)
    local data = net.ReadTable() -- Consider using net.ReadString() + util.JSONToTable for safety
    SavePlayerSlots(ply, data)
end)

-- Client requests slots
net.Receive("RequestSlots", function(len, ply)
    local data = LoadPlayerSlots(ply)
    net.Start("SendSlots")
    net.WriteTable(data) -- Consider net.WriteString(util.TableToJSON(data))
    net.Send(ply)
end)

local Inventory = FindMetaTable("Player")
function Inventory:AddItem(wep, slot)
    local data = LoadPlayerSlots(self) or {}
    -- Add a rock to the first slot if empty
    data[1] = {
        NumberOnBoard = 1,
        model = "materials/items/tools/rock.png",
        PanelType = "pnl",
    }

    self:Give("weapon_rock")
    -- Save to file
    SavePlayerSlots(self, data)
    -- Send to client
    net.Start("SendSlots")
    net.WriteTable(data)
    net.Send(self)
end

net.Receive("DropASlot", function(len, ply)
    local tbl = net.ReadTable()
    PrintTable(tbl)
    --ply:DropWeapon(ply:GetWeapon(tbl))
end)

hook.Add("PlayerSpawn", "SendSlotsOnSpawn", function(ply)
    if not IsValid(ply) then return end
    local data = LoadPlayerSlots(ply)
    -- Ensure at least a rock exists
    if not data[1] then
        ply:AddItem()
        data = LoadPlayerSlots(ply)
    end

    net.Start("SendSlots")
    net.WriteTable(data)
    net.Send(ply)
end)