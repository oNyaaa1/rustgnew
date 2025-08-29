-- Network strings
util.AddNetworkString("SaveSlots")
util.AddNetworkString("RequestSlots")
util.AddNetworkString("SendSlots")

-- Directory for slot data
local slotDir = "slots"
if not file.IsDir(slotDir, "DATA") then
    file.CreateDir(slotDir)
end

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
    if file.Exists(path, "DATA") then
        return util.JSONToTable(file.Read(path, "DATA")) or {}
    end
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

-- Send slots on spawn
hook.Add("PlayerSpawn", "SendSlotsOnSpawn", function(ply)
    if not IsValid(ply) then return end
    local data = LoadPlayerSlots(ply)
    net.Start("SendSlots")
    net.WriteTable(data) -- Consider net.WriteString(util.TableToJSON(data))
    net.Send(ply)
end)

-- Player inventory meta
local Inventory = FindMetaTable("Player")

function Inventory:AddProgression()
    -- TODO: Implement progression logic
end
