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
    local data = net.ReadTable()
    SavePlayerSlots(ply, data)
end)

-- Client requests slots
net.Receive("RequestSlots", function(len, ply)
    local data = LoadPlayerSlots(ply)
    net.Start("SendSlots")
    net.WriteTable(data)
    net.Send(ply)
end)

local Inventory = FindMetaTable("Player")
function Inventory:AddItem(wep, names)
    local data = LoadPlayerSlots(self) or {}
    -- Check if player already has items to prevent duplicates
    local hasItems = false
    for i, item in pairs(data) do
        if item and item.NumberOnBoard then
            hasItems = true
            break
        end
    end

    -- Only add starter item if player has no items
    if not hasItems then
        -- Find the first empty slot
        local emptySlot = 1
        for i = 1, 30 do
            local slotOccupied = false
            for _, item in pairs(data) do
                if item.NumberOnBoard == i then
                    slotOccupied = true
                    break
                end
            end

            if not slotOccupied then
                emptySlot = i
                break
            end
        end

        -- Add starter item to first empty slot
        table.insert(data, {
            NumberOnBoard = emptySlot,
            model = "materials/items/tools/rock.png",
            PanelType = emptySlot <= 6 and "DPanel" or "pnl",
            Type = wep,
            Name = names,
            Bar = "active",
        })

        self:Give(wep)
        -- Save to file
        SavePlayerSlots(self, data)
    end

    -- Always send current data to client
    net.Start("SendSlots")
    net.WriteTable(data)
    net.Send(self)
end

net.Receive("DropASlot", function(len, ply)
    local tbl = net.ReadString()
    ply:SelectWeapon(tbl)
end)

-- Track if player has already been given starter items this session
local playersInitialized = {}
hook.Add("PlayerSpawn", "SendSlotsOnSpawn", function(ply)
    if not IsValid(ply) then return end
    ply:AddItem("tfa_rustalpha_rocktool", "rock")
end)

hook.Add("PlayerDeath", "DEathFDelte", function(ply)
    local data = LoadPlayerSlots(ply)
    table.Empty(data)
    SavePlayerSlots(ply, data)
end)

-- Clean up tracking when player disconnects
hook.Add("PlayerDisconnected", "CleanupSlotTracking", function(ply)
    local steamID = ply:SteamID64()
    if steamID then playersInitialized[steamID] = nil end
end)