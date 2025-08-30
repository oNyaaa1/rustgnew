AddCSLuaFile("shared.lua")
AddCSLuaFile("config.lua")
include("shared.lua")
include("config.lua")
AddCSLuaFile("lang/cl_english.lua")
include("lang/cl_english.lua")
Logger("Disabling motd message")
game.ConsoleCommand("ulx_motddisabledmessage 1\n")
timer.Create("MetaBolism", 30, 0, function()
    for k, v in pairs(player.GetAll()) do
        if v:Health() <= 0 and v:Alive() then v:Kill() end
        if v:GetHunger() then v:SetHunger(v:GetHunger() - 1) end
        if v:GetThirst() then v:SetThirst(v:GetThirst() - 1) end
        if v:GetHunger() <= 0 and v:GetThirst() <= 0 and v:Alive() then
            v:Kill()
        elseif v:GetThirst() <= 0 then
            v:SetHealth(v:Health() - math.random(1, 3))
        end
    end
end)

function GM:PlayerSpawn(pl)
    pl:SetHunger(math.random(30, 50))
    pl:SetThirst(math.random(60, 70))
    pl:SetModel("models/player/Group01/Male_01.mdl")
    ply:SetupHands()
end

-- Choose the model for hands according to their player model.
function GM:PlayerSetHandsModel(ply, ent)
    local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
    local info = player_manager.TranslatePlayerHands(simplemodel)
    if info then
        ent:SetModel(info.model)
        ent:SetSkin(info.skin)
        ent:SetBodyGroups(info.body)
    end
end

hook.Add("InitPostEntity", "WipeStart", function() if game.GetMap() ~= "rust_highland_v1_3a" then game.ConsoleCommand("changelevel rust_highland_v1_3a\n") end end)